import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../auth/data/api/auth_api_client.dart';
import '../../../feed/domain/models/video_model.dart';
import '../../../../core/utils/logger_util.dart';

part 'profile_repository.g.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<List<VideoModel>> getUserEvents() async {
    try {
      final response = await _dio.get('/users/me/events');
      final List<dynamic> data = response.data;
      return data.map((json) => VideoModel.fromJson(json)).toList();
    } catch (e) {
      LoggerUtil.error('Failed to get user events', e);
      return [];
    }
  }

  Future<List<dynamic>> getUserTickets() async {
    try {
      final response = await _dio.get('/users/me/tickets');
      return response.data;
    } catch (e) {
      LoggerUtil.error('Failed to get user tickets', e);
      return [];
    }
  }
}

@riverpod
ProfileRepository profileRepository(Ref ref) {
  final apiClient = ref.watch(authApiClientProvider);
  return ProfileRepository(apiClient.dio);
}
