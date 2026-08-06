import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HeartBurstAnimator extends StatefulWidget {
  final Widget child;
  final VoidCallback onDoubleTap;

  const HeartBurstAnimator({
    super.key,
    required this.child,
    required this.onDoubleTap,
  });

  @override
  State<HeartBurstAnimator> createState() => _HeartBurstAnimatorState();
}

class _HeartBurstAnimatorState extends State<HeartBurstAnimator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.5).chain(CurveTween(curve: Curves.elasticOut)), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.2).chain(CurveTween(curve: Curves.easeIn)), weight: 30),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _tapPosition = details.localPosition;
  }

  void _handleDoubleTap() {
    widget.onDoubleTap();
    if (_tapPosition != null) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _handleDoubleTapDown,
      onDoubleTap: _handleDoubleTap,
      child: Stack(
        children: [
          widget.child,
          if (_tapPosition != null)
            Positioned(
              left: _tapPosition!.dx - 50,
              top: _tapPosition!.dy - 50,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: const Icon(
                        Icons.favorite,
                        color: AppColors.accentCta,
                        size: 100,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
