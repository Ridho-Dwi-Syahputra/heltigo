/// User model — data user dari backend `/auth/me` / `/user/profile`.
/// Backend mengembalikan: `{ id, email, name, avatar_url, has_profile, created_at }`.
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final bool hasProfile;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.hasProfile = false,
    this.createdAt,
    this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: (json['avatarUrl'] ?? json['avatar_url']) as String?,
      hasProfile: (json['has_profile'] ?? json['hasProfile'] ?? false) as bool,
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      lastLoginAt: _parseDate(json['last_login_at'] ?? json['lastLoginAt']),
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'avatarUrl': avatarUrl,
        'has_profile': hasProfile,
      };
}
