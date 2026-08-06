import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';
import 'feed_shimmer.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  final bool isActive;
  final bool shouldInitialize;

  const VideoPlayerItem({
    super.key,
    required this.videoUrl,
    required this.isActive,
    required this.shouldInitialize,
  });

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.shouldInitialize) {
      _initializeController();
    }
  }

  @override
  void didUpdateWidget(covariant VideoPlayerItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.shouldInitialize && !oldWidget.shouldInitialize) {
      _initializeController();
    } else if (!widget.shouldInitialize && oldWidget.shouldInitialize) {
      _disposeController();
    }

    if (_controller != null && _isInitialized) {
      if (widget.isActive && !oldWidget.isActive) {
        _controller!.play();
      } else if (!widget.isActive && oldWidget.isActive) {
        _controller!.pause();
      }
    }
  }

  Future<void> _initializeController() async {
    if (_controller != null) return;

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _controller!.setLooping(true); // Loop indefinitely like TikTok
    
    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        if (widget.isActive) {
          _controller!.play();
        }
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
    if (mounted) {
      setState(() {
        _isInitialized = false;
      });
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      // Use shimmer if it's the active view waiting to load, or just black if it's a preloaded one
      return widget.isActive ? const FeedShimmer() : Container(color: AppColors.primaryBackground);
    }

    return GestureDetector(
      onTap: () {
        if (_controller!.value.isPlaying) {
          _controller!.pause();
        } else {
          _controller!.play();
        }
      },
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          ),
        ),
      ),
    );
  }
}
