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
      duration: const Duration(seconds: 2),
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
      right: 16,
      bottom: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (video.hasTickets) ...[
            GestureDetector(
              onTap: widget.onOpenTickets,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.accentCta,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentCta.withOpacity(0.5 * _pulseController.value),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.local_activity, color: AppColors.primaryBackground, size: 24),
                          SizedBox(height: 4),
                          Text(
                            'Get Tickets',
                            style: TextStyle(
                              color: AppColors.primaryBackground,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          _InteractionButton(
            icon: video.isLikedByMe ? Icons.favorite : Icons.favorite_border,
            color: video.isLikedByMe ? AppColors.accentCta : Colors.white,
            label: video.likesCount.toString(),
            onTap: () => ref.read(videoInteractionProvider(widget.videoId).notifier).toggleLike(),
            isAnimated: true,
            isActive: video.isLikedByMe,
          ),
          const SizedBox(height: 20),
          _InteractionButton(
            icon: Icons.chat_bubble_outline,
            label: video.commentsCount.toString(),
            onTap: widget.onOpenComments,
          ),
          const SizedBox(height: 20),
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
            child: Icon(widget.icon, color: widget.color, size: 36),
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.0, -0.5), end: Offset.zero).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Text(
              widget.label,
              key: ValueKey(widget.label),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
