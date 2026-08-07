import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/video_model.dart';
import '../../data/feed_repository.dart';
import 'feed_provider.dart';
import 'discover_provider.dart';

part 'video_interaction_provider.g.dart';

@riverpod
class VideoInteraction extends _$VideoInteraction {
  @override
  VideoModel build(String videoId) {
    final feedState = ref.read(feedProvider);
    final discoverState = ref.read(discoverProvider);
    
    final video = feedState.value?.cast<VideoModel?>().firstWhere((v) => v?.id == videoId, orElse: () => null) 
      ?? discoverState.value?.cast<VideoModel?>().firstWhere((v) => v?.id == videoId, orElse: () => null);
    
    if (video == null) {
      throw Exception('Video not found in feed');
    }
    
    return video;
  }

  void toggleLike() {
    final newState = !state.isLikedByMe;
    final newCount = state.isLikedByMe ? state.likesCount - 1 : state.likesCount + 1;
    
    // Optimistic UI update
    state = state.copyWith(
      isLikedByMe: newState,
      likesCount: newCount,
    );
    
    _syncGlobalState(state);
    
    // Provide haptic feedback
    if (newState) {
      HapticFeedback.lightImpact();
    }

    // Call API
    ref.read(feedRepositoryProvider).toggleLike(state.id, newState).catchError((_) {
      // Revert if error
      state = state.copyWith(
        isLikedByMe: !newState,
        likesCount: state.isLikedByMe ? state.likesCount - 1 : state.likesCount + 1,
      );
      _syncGlobalState(state);
    });
  }

  void toggleFollow() {
    final newState = !state.isFollowingOrganizer;
    
    state = state.copyWith(
      isFollowingOrganizer: newState,
    );
    
    _syncGlobalState(state);

    ref.read(feedRepositoryProvider).toggleFollow(state.organizerId, newState).catchError((_) {
      state = state.copyWith(
        isFollowingOrganizer: !newState,
      );
      _syncGlobalState(state);
    });
  }

  void _syncGlobalState(VideoModel updatedVideo) {
    ref.read(feedProvider.notifier).updateVideo(updatedVideo);
    ref.read(discoverProvider.notifier).updateVideo(updatedVideo);
  }
}
