import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../auth/data/api/auth_api_client.dart';
import '../../../feed/domain/models/video_model.dart';
import '../../../../core/utils/logger_util.dart';

part 'profile_repository.g.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await _dio.get('/users/me/stats');
      return response.data;
    } catch (e) {
      LoggerUtil.error('Failed to get user stats', e);
      return {
        'followersCount': 0,
        'followingCount': 0,
        'walletBalance': 0.0,
        'recentSales': [],
      };
    }
  }

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

  Future<void> updateProfile({String? name, String? bio, String? avatarUrl, String? role}) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (bio != null) data['bio'] = bio;
      if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
      if (role != null) data['role'] = role;

      await _dio.put('/users/me', data: data);
    } catch (e) {
      LoggerUtil.error('Failed to update profile', e);
      rethrow;
    }
  }

  Future<String?> uploadMedia(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post('/media/upload', data: formData);
      return response.data['url'];
    } catch (e) {
      LoggerUtil.error('Failed to upload media', e);
      return null;
    }
  }
}

@riverpod
ProfileRepository profileRepository(Ref ref) {
  final apiClient = ref.watch(authApiClientProvider);
  return ProfileRepository(apiClient.dio);
}
