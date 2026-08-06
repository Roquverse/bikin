import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../domain/models/video_model.dart';
import '../domain/models/ticket_tier_model.dart';
import '../domain/models/comment_model.dart';
import '../../../../core/utils/logger_util.dart';
import '../../auth/data/api/auth_api_client.dart';

part 'feed_repository.g.dart';

abstract class FeedRepository {
  Future<List<VideoModel>> getFeedVideos({int page = 1});
  Future<List<TicketTierModel>> getTicketTiers(String videoId);
  Future<List<CommentModel>> getComments(String videoId);
  Future<bool> bookTickets(String videoId, Map<String, int> selectedTiers);
  Future<void> toggleLike(String videoId, bool isLiked);
  Future<void> toggleFollow(String organizerId, bool isFollowing);
}

class FeedRepositoryImpl implements FeedRepository {
  final Dio _dio;

  FeedRepositoryImpl(this._dio);

  @override
  Future<List<VideoModel>> getFeedVideos({int page = 1}) async {
    try {
      final response = await _dio.get('/feed', queryParameters: {'page': page});
      final List<dynamic> data = response.data;
      
      return data.map((json) => VideoModel.fromJson(json)).toList();
    } catch (e) {
      LoggerUtil.error('Failed to fetch feed videos: $e');
      throw Exception('Failed to fetch feed videos');
    }
  }

  @override
  Future<List<TicketTierModel>> getTicketTiers(String videoId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const TicketTierModel(id: 't1', name: 'General Admission', price: 5000.0, availableQuantity: 100),
      const TicketTierModel(id: 't2', name: 'VIP', price: 15000.0, availableQuantity: 20),
      const TicketTierModel(id: 't3', name: 'VVIP Table', price: 50000.0, availableQuantity: 2),
    ];
  }

  @override
  Future<List<CommentModel>> getComments(String videoId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      CommentModel(
        id: 'c1',
        userId: 'u1',
        userName: 'Alex',
        userAvatarUrl: 'https://i.pravatar.cc/150?u=a1',
        text: 'This looks amazing! Cant wait.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isOrganizer: false,
      ),
      CommentModel(
        id: 'c2',
        userId: 'org1',
        userName: 'Nature Walks',
        userAvatarUrl: 'https://i.pravatar.cc/150?u=org1',
        text: 'Glad you like it! Make sure to book early.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        isOrganizer: true,
      ),
    ];
  }

  @override
  Future<bool> bookTickets(String videoId, Map<String, int> selectedTiers) async {
    await Future.delayed(const Duration(seconds: 2));
    
    final bool soldOutSimulation = DateTime.now().second % 5 == 0;
    
    if (soldOutSimulation) {
      LoggerUtil.error('Server returned sold out error');
      throw Exception('Tickets sold out or unavailable.');
    }
    
    return true; 
  }

  @override
  Future<void> toggleLike(String videoId, bool isLiked) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Simulate success
  }

  @override
  Future<void> toggleFollow(String organizerId, bool isFollowing) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Simulate success
  }
}

@riverpod
FeedRepository feedRepository(Ref ref) {
  final client = ref.watch(authApiClientProvider);
  return FeedRepositoryImpl(client.dio);
}
