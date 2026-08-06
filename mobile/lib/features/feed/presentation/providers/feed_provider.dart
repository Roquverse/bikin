import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/video_model.dart';
import '../../data/feed_repository.dart';

part 'feed_provider.g.dart';

@riverpod
class Feed extends _$Feed {
  @override
  FutureOr<List<VideoModel>> build() async {
    return ref.watch(feedRepositoryProvider).getFeedVideos();
  }

  Future<void> loadMore() async {
    // Basic implementation for infinite scroll, not fully wired up in UI yet
    if (state.isLoading) return;
    
    final currentVideos = state.value ?? [];
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final moreVideos = await ref.read(feedRepositoryProvider).getFeedVideos(page: 2);
      return [...currentVideos, ...moreVideos];
    });
  }
}
