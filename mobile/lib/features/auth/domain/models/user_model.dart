class UserModel {
  final String id;
  final String email;
  final String name;
  final String accountType; // 'Attendee' or 'Organizer'
  final String role; // 'ATTENDEE' or 'ORGANIZER' (backend enum)

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.accountType,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as String? ?? 'ATTENDEE';
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      accountType: json['account_type'] as String? ?? role,
      role: role,
    );
  }
}
