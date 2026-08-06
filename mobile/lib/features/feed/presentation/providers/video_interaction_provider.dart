import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/video_model.dart';
import '../../data/feed_repository.dart';
import 'feed_provider.dart';

part 'video_interaction_provider.g.dart';

@riverpod
class VideoInteraction extends _$VideoInteraction {
  @override
  VideoModel build(String videoId) {
    // Find initial state from global feed
    final feedState = ref.read(feedProvider);
    final video = feedState.value?.firstWhere((v) => v.id == videoId);
    
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
    });
  }

  void toggleFollow() {
    final newState = !state.isFollowingOrganizer;
    
    state = state.copyWith(
      isFollowingOrganizer: newState,
    );

    ref.read(feedRepositoryProvider).toggleFollow(state.organizerId, newState).catchError((_) {
      state = state.copyWith(
        isFollowingOrganizer: !newState,
      );
    });
  }
}
