class ArtistEntity {
  final int artistId;
  final int userId;
  final String stageName;
  final String bio;
  final String imageUrl;

  ArtistEntity({
    required this.artistId,
    required this.userId,
    required this.stageName,
    required this.bio,
    required this.imageUrl,
  });
}
