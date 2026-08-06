import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/video_interaction_provider.dart';

class InteractionRail extends ConsumerStatefulWidget {
  final String videoId;
  final VoidCallback onOpenComments;
  final VoidCallback onOpenTickets;

  const InteractionRail({
    super.key,
    required this.videoId,
    required this.onOpenComments,
    required this.onOpenTickets,
  });

  @override
  ConsumerState<InteractionRail> createState() => _InteractionRailState();
}

class _InteractionRailState extends ConsumerState<InteractionRail> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = ref.watch(videoInteractionProvider(widget.videoId));

    return Positioned(
      right: 12,
      bottom: 70, // Keep offset slightly above the navigation bar area
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Yellow ticket booking button (Mockup style)
          if (video.hasTickets) ...[
            GestureDetector(
              onTap: widget.onOpenTickets,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.05),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.accentCta,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentCta.withAlpha((40 + (_pulseController.value * 80)).toInt()),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.local_activity,
                          color: AppColors.primaryBackground,
                          size: 24,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Like Button (Mockup style)
          _InteractionButton(
            icon: video.isLikedByMe ? Icons.favorite : Icons.favorite_border,
            color: video.isLikedByMe ? Colors.red[400]! : Colors.white,
            label: _formatCount(video.likesCount),
            onTap: () => ref.read(videoInteractionProvider(widget.videoId).notifier).toggleLike(),
            isAnimated: true,
            isActive: video.isLikedByMe,
          ),
          const SizedBox(height: 20),

          // Comment Button (Mockup style)
          _InteractionButton(
            icon: Icons.chat_bubble_outline,
            label: _formatCount(video.commentsCount),
            onTap: widget.onOpenComments,
          ),
          const SizedBox(height: 20),

          // Share Button (Mockup style)
          _InteractionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: () {
              SharePlus.instance.share(ShareParams(text: 'Check out this amazing event on Bikin! ${video.videoUrl}'));
            },
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

class _InteractionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isAnimated;
  final bool isActive;

  const _InteractionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
    this.isAnimated = false,
    this.isActive = false,
  });

  @override
  State<_InteractionButton> createState() => _InteractionButtonState();
}

class _InteractionButtonState extends State<_InteractionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant _InteractionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimated && widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
            child: Icon(widget.icon, color: widget.color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
