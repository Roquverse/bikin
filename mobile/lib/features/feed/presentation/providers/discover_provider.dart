import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/video_model.dart';
import '../../data/feed_repository.dart';

part 'discover_provider.g.dart';

@riverpod
class Discover extends _$Discover {
  @override
  FutureOr<List<VideoModel>> build() async {
    return ref.watch(feedRepositoryProvider).getDiscoverFeedVideos();
  }

  Future<void> loadMore() async {
    if (state.isLoading) return;
    
    final currentVideos = state.value ?? [];
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final moreVideos = await ref.read(feedRepositoryProvider).getDiscoverFeedVideos(page: 2);
      return [...currentVideos, ...moreVideos];
    });
  }
}
