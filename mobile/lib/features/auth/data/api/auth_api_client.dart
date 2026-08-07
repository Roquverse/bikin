import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/utils/logger_util.dart';
import '../storage/token_storage.dart';

part 'auth_api_client.g.dart';

class AuthApiClient {
  final Dio _dio;

  AuthApiClient(this._dio);

  Dio get dio => _dio;
}

@riverpod
AuthApiClient authApiClient(Ref ref) {
  final String baseUrl = Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';

  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  final tokenStorage = ref.watch(tokenStorageProvider);

  if (kReleaseMode) {
    dio.interceptors.add(CertificatePinningInterceptor());
  }

  dio.interceptors.addAll([
    // Auth Interceptor for Bearer token and 401 retries
    AuthInterceptor(dio, tokenStorage),
    // Logging Interceptor (using our custom redacted logger)
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => LoggerUtil.debug(obj.toString()),
    ),
  ]);

  return AuthApiClient(dio);
}

class CertificatePinningInterceptor extends Interceptor {
  // TODO: Replace with the actual SHA-256 hash of your production server certificate
  final List<String> allowedHashes = ['[PLACEHOLDER_HASH]'];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (kIsWeb) {
      return handler.next(options);
    }
    try {
      final secure = await HttpCertificatePinning.check(
        serverURL: options.uri.toString(),
        headerHttp: options.headers.map((k, v) => MapEntry(k, v.toString())),
        sha: SHA.SHA256,
        allowedSHAFingerprints: allowedHashes,
        timeout: 50,
      );
      if (secure.contains('CONNECTION_SECURE')) {
        handler.next(options);
      } else {
        handler.reject(DioException(
          requestOptions: options,
          error: 'Certificate Pinning Failed',
        ));
      }
    } catch (e) {
      LoggerUtil.error('Certificate Pinning Error', e);
      handler.reject(DioException(
        requestOptions: options,
        error: e.toString(),
      ));
    }
  }
}

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorage _tokenStorage;
  bool _isRefreshing = false;
  final List<RequestOptions> _failedRequests = [];

  AuthInterceptor(this._dio, this._tokenStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Handle token refresh
      final options = err.requestOptions;
      
      if (!_isRefreshing) {
        _isRefreshing = true;
        _failedRequests.add(options);
        
        final refreshToken = await _tokenStorage.getRefreshToken();
        if (refreshToken == null) {
          _isRefreshing = false;
          _forceLogout();
          return handler.next(err);
        }

        try {
          // Attempt refresh
          final response = await _dio.post(
            '/auth/refresh',
            data: {'refresh_token': refreshToken},
          );
          
          final newAccessToken = response.data['access_token'];
          final newRefreshToken = response.data['refresh_token'];
          
          if (newAccessToken != null && newRefreshToken != null) {
            await _tokenStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );
            
            // Retry all failed requests
            for (var failedOption in _failedRequests) {
              failedOption.headers['Authorization'] = 'Bearer $newAccessToken';
              final retryResponse = await _dio.fetch(failedOption);
              if (failedOption == options) {
                handler.resolve(retryResponse);
              }
            }
          } else {
            _forceLogout();
            handler.next(err);
          }
        } catch (e) {
          LoggerUtil.error('Token refresh failed', e);
          _forceLogout();
          handler.next(err);
        } finally {
          _isRefreshing = false;
          _failedRequests.clear();
        }
      } else {
        // Queue the request
        _failedRequests.add(options);
      }
    } else {
      handler.next(err);
    }
  }

  void _forceLogout() {
    LoggerUtil.info('Forcing logout due to invalid/expired refresh token.');
    _tokenStorage.clearTokens();
    // Normally we would notify a global provider to redirect to login here
  }
}
