import '../../../../core/network/api_client.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String accountType; // 'Attendee' or 'Organizer'
  final String role; // 'ATTENDEE' or 'ORGANIZER' (backend enum)
  final String? avatarUrl;
  final String? bio;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.accountType,
    required this.role,
    this.avatarUrl,
    this.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final role = (json['role'] as String?) ?? 'ATTENDEE';
    final rawAvatar = json['avatarUrl'] as String?;

    return UserModel(
      id: (json['id'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      name: (json['name'] as String?) ?? (json['email'] as String?) ?? 'User',
      accountType: (json['account_type'] as String?) ?? (role == 'ORGANIZER' ? 'Organizer' : 'Attendee'),
      role: role,
      avatarUrl: rawAvatar != null && rawAvatar.isNotEmpty ? ApiClient.getFullUrl(rawAvatar) : null,
      bio: json['bio'] as String?,
    );
  }
}
