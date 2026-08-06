class UserModel {
  final String id;
  final String email;
  final String name;
  final String accountType; // 'Attendee' or 'Organizer'

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.accountType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      accountType: json['account_type'] as String? ?? 'Attendee',
    );
  }
}
