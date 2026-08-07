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
  bool _isPaused = false;
  bool _showActionIcon = false;
  bool _isImage = false;

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
        if (!_isPaused) _controller!.play();
      } else if (!widget.isActive && oldWidget.isActive) {
        _controller!.pause();
      }
    }
  }

  Future<void> _initializeController() async {
    if (_controller != null) return;
    
    final url = widget.videoUrl.toLowerCase();
    if (url.endsWith('.jpg') || url.endsWith('.jpeg') || url.endsWith('.png') || url.endsWith('.webp') || url.contains('cloudinary.com/image')) {
      if (mounted) {
        setState(() {
          _isImage = true;
          _isInitialized = true;
        });
      }
      return;
    }

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _controller!.setLooping(true); // Loop indefinitely like TikTok
    _controller!.setVolume(1.0); // Ensure sound is unmuted
    
    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        if (widget.isActive && !_isPaused) {
          _controller!.play();
        }
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  void _disposeController({bool isDisposing = false}) {
    _controller?.dispose();
    _controller = null;
    if (!isDisposing && mounted) {
      setState(() {
        _isInitialized = false;
      });
    }
  }

  @override
  void dispose() {
    _disposeController(isDisposing: true);
    super.dispose();
  }

  void _togglePlay() {
    if (_controller == null || !_isInitialized) return;
    
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPaused = true;
      } else {
        _controller!.play();
        _isPaused = false;
      }
      _showActionIcon = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showActionIcon = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // Use shimmer if it's the active view waiting to load, or just black if it's a preloaded one
      return widget.isActive ? const FeedShimmer() : Container(color: Colors.black);
    }
    
    if (_isImage) {
      return SizedBox.expand(
        child: Image.network(
          widget.videoUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const FeedShimmer();
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 64));
          },
        ),
      );
    }

    if (_controller == null) {
      return Container(color: Colors.black);
    }

    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
          if (_showActionIcon || _isPaused)
            Center(
              child: AnimatedOpacity(
                opacity: _showActionIcon ? 1.0 : (_isPaused ? 0.6 : 0.0),
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(100),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
