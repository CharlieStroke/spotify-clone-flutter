class UserEntity {
  final int userId;
  final String email;
  final String username;
  final String? profileImageUrl;

  UserEntity({
    required this.userId,
    required this.email,
    required this.username,
    this.profileImageUrl,
  });
}
