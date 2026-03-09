class PlaylistEntity {
  final int id;
  final String name;
  final String description;
  final int userId;
  final String creatorName; // Username of the creator
  final String? coverUrl;

  PlaylistEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.userId,
    required this.creatorName,
    this.coverUrl,
  });
}
