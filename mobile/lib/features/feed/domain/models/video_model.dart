class VideoModel {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String caption;
  final List<String> hashtags;
  final String organizerId;
  final String organizerName;
  final String organizerAvatarUrl;
  final int likesCount;
  final int commentsCount;
  final bool hasTickets;
  final bool isLikedByMe;
  final bool isFollowingOrganizer;

  const VideoModel({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.caption,
    required this.hashtags,
    required this.organizerId,
    required this.organizerName,
    required this.organizerAvatarUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.hasTickets,
    required this.isLikedByMe,
    required this.isFollowingOrganizer,
  });

  VideoModel copyWith({
    int? likesCount,
    int? commentsCount,
    bool? isLikedByMe,
    bool? isFollowingOrganizer,
  }) {
    return VideoModel(
      id: id,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      caption: caption,
      hashtags: hashtags,
      organizerId: organizerId,
      organizerName: organizerName,
      organizerAvatarUrl: organizerAvatarUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      hasTickets: hasTickets,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      isFollowingOrganizer: isFollowingOrganizer ?? this.isFollowingOrganizer,
    );
  }
}
