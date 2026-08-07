import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/video_model.dart';
import '../../data/feed_repository.dart';
import 'category_provider.dart';

part 'feed_provider.g.dart';

@riverpod
class Feed extends _$Feed {
  @override
  FutureOr<List<VideoModel>> build() async {
    final category = ref.watch(selectedCategoryProvider);
    return ref.watch(feedRepositoryProvider).getFeedVideos(category: category);
  }

  Future<void> loadMore() async {
    // Basic implementation for infinite scroll, not fully wired up in UI yet
    if (state.isLoading) return;
    
    final currentVideos = state.value ?? [];
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final category = ref.read(selectedCategoryProvider);
      final moreVideos = await ref.read(feedRepositoryProvider).getFeedVideos(page: 2, category: category);
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
