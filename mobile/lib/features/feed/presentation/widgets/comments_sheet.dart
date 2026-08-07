import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/feed_repository.dart';

class CommentsSheet extends ConsumerStatefulWidget {
  final String videoId;
  final int commentsCount;

  const CommentsSheet({
    super.key,
    required this.videoId,
    this.commentsCount = 0,
  });

  @override
  ConsumerState<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<CommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;
  bool _isLoading = true;
  String? _error;
  List<dynamic> _comments = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final comments = await ref.read(feedRepositoryProvider).getComments(widget.videoId);
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load comments';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    
    try {
      final newComment = await ref.read(feedRepositoryProvider).addComment(widget.videoId, text);
      if (mounted) {
        setState(() {
          _comments.insert(0, newComment);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to post comment')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A1F18).withAlpha(242),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.72,
            minChildSize: 0.45,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Column(
                children: [
                  // Handle
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withAlpha(100),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          'Comments',
                          style: const TextStyle(
                            color: AppColors.offWhite,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.commentsCount.toString(),
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.close, size: 16, color: AppColors.secondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Divider(color: AppColors.secondary.withAlpha(30), height: 1),

                  // Comments list
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (_isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accentCta,
                              strokeWidth: 2,
                            ),
                          );
                        }
                        if (_error != null) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.chat_bubble_outline, color: AppColors.secondary, size: 40),
                                const SizedBox(height: 12),
                                const Text('No comments yet', style: TextStyle(color: AppColors.offWhite, fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('Be the first to comment!', style: TextStyle(color: AppColors.secondary.withAlpha(180), fontSize: 13)),
                              ],
                            ),
                          );
                        }
                        if (_comments.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.chat_bubble_outline, color: AppColors.secondary, size: 40),
                                const SizedBox(height: 12),
                                const Text('No comments yet', style: TextStyle(color: AppColors.offWhite, fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('Be the first to comment!', style: TextStyle(color: AppColors.secondary.withAlpha(180), fontSize: 13)),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            final comment = _comments[index];
                            return _CommentTile(comment: comment);
                          },
                        );
                      },
                    ),
                  ),

                  // Comment input
                  _CommentInput(
                    controller: _controller,
                    hasText: _hasText,
                    onSend: _addComment,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CommentTile extends StatefulWidget {
  final dynamic comment;
  const _CommentTile({required this.comment});

  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile> {
  bool _liked = false;
  int _likes = 0;

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(comment.userAvatarUrl),
                backgroundColor: AppColors.surfaceElevated,
              ),
              if (comment.isOrganizer)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.accentCta,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0A1F18), width: 1.5),
                    ),
                    child: const Icon(Icons.verified, size: 8, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name row
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.offWhite,
                        fontSize: 13.5,
                      ),
                    ),
                    if (comment.isOrganizer) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentCta.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.accentCta.withAlpha(80), width: 0.5),
                        ),
                        child: const Text(
                          'Organizer',
                          style: TextStyle(
                            color: AppColors.accentCta,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    Text(
                      '4h',
                      style: TextStyle(
                        color: AppColors.secondary.withAlpha(160),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // Comment text
                Text(
                  comment.text,
                  style: const TextStyle(
                    color: AppColors.offWhite,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                // Reply
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          color: AppColors.secondary.withAlpha(200),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Like button
          GestureDetector(
            onTap: () {
              setState(() {
                _liked = !_liked;
                _likes += _liked ? 1 : -1;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Column(
                children: [
                  Icon(
                    _liked ? Icons.favorite : Icons.favorite_border,
                    size: 17,
                    color: _liked ? Colors.red[400] : AppColors.secondary.withAlpha(160),
                  ),
                  if (_likes > 0)
                    Text(
                      _likes.toString(),
                      style: const TextStyle(color: AppColors.secondary, fontSize: 10),
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

class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final bool hasText;
  final VoidCallback onSend;

  const _CommentInput({
    required this.controller,
    required this.hasText,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.secondary.withAlpha(30))),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.surfaceElevated,
              child: Icon(Icons.person, size: 18, color: AppColors.secondary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 100),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: AppColors.offWhite, fontSize: 14),
                  maxLines: null,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Add a comment...',
                    hintStyle: TextStyle(color: AppColors.secondary.withAlpha(150), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: hasText ? AppColors.accentCta : AppColors.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: hasText ? onSend : null,
                icon: Icon(
                  Icons.send_rounded,
                  size: 16,
                  color: hasText ? AppColors.primaryBackground : AppColors.secondary.withAlpha(100),
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
