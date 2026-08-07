import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/video_model.dart';
import '../../data/feed_repository.dart';
import 'location_provider.dart';

part 'discover_provider.g.dart';

@riverpod
class Discover extends _$Discover {
  @override
  FutureOr<List<VideoModel>> build() async {
    final location = ref.watch(selectedLocationProvider);
    return ref.watch(feedRepositoryProvider).getDiscoverFeedVideos(location: location);
  }

  Future<void> loadMore() async {
    if (state.isLoading) return;
    
    final currentVideos = state.value ?? [];
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final location = ref.read(selectedLocationProvider);
      final moreVideos = await ref.read(feedRepositoryProvider).getDiscoverFeedVideos(page: 2, location: location);
      return [...currentVideos, ...moreVideos];
    });
  }

  void updateVideo(VideoModel updatedVideo) {
    if (!state.hasValue) return;
    
    final currentList = state.value!;
    final index = currentList.indexWhere((v) => v.id == updatedVideo.id);
    
    if (index != -1) {
      final newList = List<VideoModel>.from(currentList);
      newList[index] = updatedVideo;
      state = AsyncValue.data(newList);
    }
  }
}
