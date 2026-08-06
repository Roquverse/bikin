import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/feed_provider.dart';
import '../providers/video_interaction_provider.dart';
import '../widgets/feed_shimmer.dart';
import '../widgets/video_player_item.dart';
import '../widgets/feed_overlay.dart';
import '../widgets/interaction_rail.dart';
import '../widgets/heart_burst_animator.dart';
import '../widgets/ticket_booking_sheet.dart';
import '../widgets/comments_sheet.dart';

class HomeFeedScreen extends ConsumerStatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  ConsumerState<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openComments(String videoId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsSheet(videoId: videoId),
    );
  }

  void _openTickets(String videoId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TicketBookingSheet(videoId: videoId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: feedState.when(
        data: (videos) {
          if (videos.isEmpty) {
            return const Center(child: Text('No videos found', style: TextStyle(color: AppColors.offWhite)));
          }
          
          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: videos.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              if (index == videos.length - 2) {
                ref.read(feedProvider.notifier).loadMore();
              }
            },
            itemBuilder: (context, index) {
              final video = videos[index];
              final isActive = _currentIndex == index;
              
              // Only initialize current, next two, and previous one
              final shouldInitialize = (index - _currentIndex).abs() <= 2;

              return HeartBurstAnimator(
                onDoubleTap: () => ref.read(videoInteractionProvider(video.id).notifier).toggleLike(),
                child: Stack(
                  children: [
                    VideoPlayerItem(
                      videoUrl: video.videoUrl,
                      isActive: isActive,
                      shouldInitialize: shouldInitialize,
                    ),
                    FeedOverlay(videoId: video.id),
                    InteractionRail(
                      videoId: video.id,
                      onOpenComments: () => _openComments(video.id),
                      onOpenTickets: () => _openTickets(video.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const FeedShimmer(),
        error: (error, stack) => Center(
          child: Text('Error loading feed: $error', style: const TextStyle(color: AppColors.error)),
        ),
      ),
    );
  }
}
