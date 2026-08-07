import '../../../../core/network/api_client.dart';

class VideoModel {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String caption;
  final String? date;
  final String? location;
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
    this.date,
    this.location,
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

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final rawVideoUrl = json['videoUrl'] ?? json['mediaUrl'] ?? '';
    final rawThumbnailUrl = json['thumbnailUrl'] ?? json['mediaUrl'] ?? '';
    final rawOrganizerAvatar = json['organizerAvatarUrl'] ?? json['organizer']?['avatarUrl'] ?? 'https://i.pravatar.cc/150';

    return VideoModel(
      id: json['id']?.toString() ?? '',
      videoUrl: rawVideoUrl.isNotEmpty ? ApiClient.getFullUrl(rawVideoUrl) : '',
      thumbnailUrl: rawThumbnailUrl.isNotEmpty ? ApiClient.getFullUrl(rawThumbnailUrl) : '',
      caption: json['caption'] ?? json['title'] ?? '',
      date: json['date'] as String?,
      location: json['location'] as String?,
      hashtags: List<String>.from(json['hashtags'] ?? []),
      organizerId: json['organizerId'] ?? '',
      organizerName: json['organizerName'] ?? json['organizer']?['name'] ?? 'Unknown',
      organizerAvatarUrl: rawOrganizerAvatar.isNotEmpty ? ApiClient.getFullUrl(rawOrganizerAvatar) : '',
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      hasTickets: json['hasTickets'] ?? (json['price'] != null && (json['price'] as num) > 0),
      isLikedByMe: json['isLikedByMe'] ?? false,
      isFollowingOrganizer: json['isFollowingOrganizer'] ?? false,
    );
  }


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
      date: date,
      location: location,
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
