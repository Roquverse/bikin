import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/video_interaction_provider.dart';

class FeedOverlay extends ConsumerWidget {
  final String videoId;

  const FeedOverlay({
    super.key,
    required this.videoId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final video = ref.watch(videoInteractionProvider(videoId));
    
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.primaryBackground.withOpacity(0.8),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          bottom: 40,
          right: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.secondary, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(video.organizerAvatarUrl),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      video.organizerName,
                      style: const TextStyle(
                        color: AppColors.offWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => ref.read(videoInteractionProvider(videoId).notifier).toggleFollow(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: video.isFollowingOrganizer ? Colors.transparent : AppColors.success,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: video.isFollowingOrganizer ? AppColors.success : Colors.transparent),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: video.isFollowingOrganizer
                            ? const Row(
                                key: ValueKey('following'),
                                children: [
                                  Icon(Icons.check, size: 14, color: AppColors.success),
                                  SizedBox(width: 4),
                                  Text('Following', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              )
                            : const Text(
                                'Follow',
                                key: ValueKey('follow'),
                                style: TextStyle(color: AppColors.offWhite, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                video.caption,
                style: const TextStyle(color: AppColors.offWhite, fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: video.hashtags.map((tag) => Text(
                  tag,
                  style: const TextStyle(color: AppColors.offWhite, fontWeight: FontWeight.bold),
                )).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
