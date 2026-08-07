import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/feed_provider.dart';
import '../providers/video_interaction_provider.dart';
import '../providers/category_provider.dart';
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

          // Header Overlay (Categories and Search)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 40,
              child: Row(
                children: [
                  Expanded(
                    child: ref.watch(availableCategoriesProvider).when(
                      data: (categories) {
                        final selectedCategory = ref.watch(selectedCategoryProvider);
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final isSelected = category == selectedCategory;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () {
                                  ref.read(selectedCategoryProvider.notifier).setCategory(category);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.accentCta : Colors.black.withAlpha(80),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? AppColors.accentCta : Colors.white.withAlpha(30),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        color: isSelected ? Colors.black : AppColors.offWhite,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentCta)),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16, left: 8),
                    child: GestureDetector(
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
