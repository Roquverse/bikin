import '../models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/api/auth_api_client.dart';
import '../../data/storage/token_storage.dart';
import '../../../../core/utils/logger_util.dart';

part 'auth_repository.g.dart';

abstract class AuthRepository {
  Future<UserModel> login(String email, String password);
  Future<void> signup(String email, String password, String name, String role);
  Future<void> verifyOtp(String email, String otp);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<void> setAccountType(String accountType);
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl(this._apiClient, this._tokenStorage);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      final data = response.data;
      await _tokenStorage.saveTokens(
        accessToken: data['access_token'],
        refreshToken: data['refresh_token'],
      );
      
      return UserModel.fromJson(data['user']);
    } catch (e) {
      LoggerUtil.error('Login failed', e);
      throw Exception('Failed to login. Please check your credentials.');
    }
  }

  @override
  Future<void> signup(String email, String password, String name, String role) async {
    try {
      await _apiClient.dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'name': name,
        'role': role.toUpperCase(),
      });
    } catch (e) {
      LoggerUtil.error('Signup failed', e);
      throw Exception('Failed to create account.');
    }
  }

  @override
  Future<void> verifyOtp(String email, String otp) async {
    try {
      final response = await _apiClient.dio.post('/auth/verify-otp', data: {
        'email': email,
        'otp': otp,
      });
      
      final data = response.data;
      await _tokenStorage.saveTokens(
        accessToken: data['access_token'],
        refreshToken: data['refresh_token'],
      );
    } catch (e) {
      LoggerUtil.error('OTP verification failed', e);
      throw Exception('Invalid OTP.');
    }
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clearTokens();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null) return null;

    try {
      final response = await _apiClient.dio.get('/users/me');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      LoggerUtil.error('Failed to fetch current user', e);
      return null;
    }
  }

  @override
  Future<void> setAccountType(String accountType) async {
    try {
      await _apiClient.dio.post('/auth/account-type', data: {
        'account_type': accountType,
      });
    } catch (e) {
      LoggerUtil.error('Failed to set account type', e);
      throw Exception('Failed to update account type.');
    }
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    ref.watch(authApiClientProvider),
    ref.watch(tokenStorageProvider),
  );
}
