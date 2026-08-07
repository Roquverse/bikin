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
import '../../domain/models/video_model.dart';

class HomeFeedScreen extends ConsumerStatefulWidget {
  final bool isTabActive;
  
  const HomeFeedScreen({
    super.key,
    this.isTabActive = true,
  });

  @override
  ConsumerState<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isOverlayOpen = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openComments(String videoId, int commentsCount) async {
    setState(() => _isOverlayOpen = true);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsSheet(
        videoId: videoId,
        commentsCount: commentsCount,
      ),
    );
    if (mounted) setState(() => _isOverlayOpen = false);
  }

  void _openTickets(VideoModel video) async {
    setState(() => _isOverlayOpen = true);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TicketBookingSheet(video: video),
    );
    if (mounted) setState(() => _isOverlayOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Feed PageView
          feedState.when(
            data: (videos) {
              if (videos.isEmpty) {
                return const Center(child: Text('No videos found', style: TextStyle(color: AppColors.offWhite)));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(feedProvider);
                },
                child: PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: videos.length,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                    if (index == videos.length - 2) {
                      ref.read(feedProvider.notifier).loadMore();
                    }
                  },
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    final isActive = _currentIndex == index && widget.isTabActive && !_isOverlayOpen;
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
                            onOpenComments: () => _openComments(video.id, video.commentsCount),
                            onOpenTickets: () => _openTickets(video),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const FeedShimmer(),
            error: (error, stack) => Center(
              child: Text('Error loading feed: $error', style: const TextStyle(color: AppColors.error)),
            ),
          ),

          // Header Overlay (Mockup screen 1 design)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Location Picker Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(80),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withAlpha(30), width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppColors.success),
                      const SizedBox(width: 6),
                      const Text(
                        'Lagos',
                        style: TextStyle(
                          color: AppColors.offWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.offWhite),
                    ],
                  ),
                ),

                // Search Icon
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(80),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withAlpha(30), width: 0.5),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: AppColors.offWhite,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
