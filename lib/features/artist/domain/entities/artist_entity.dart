class ArtistEntity {
  final int artistId;
  final int userId;
  final String stageName;
  final String bio;
  final String imageUrl;
  final int followersCount;
  final int totalPlays;
  final bool isFollowing;

  ArtistEntity({
    required this.artistId,
    required this.userId,
    required this.stageName,
    required this.bio,
    required this.imageUrl,
    this.followersCount = 0,
    this.totalPlays = 0,
    this.isFollowing = false,
  });

  ArtistEntity copyWith({
    bool? isFollowing,
    int? followersCount,
  }) {
    return ArtistEntity(
      artistId: artistId,
      userId: userId,
      stageName: stageName,
      bio: bio,
      imageUrl: imageUrl,
      followersCount: followersCount ?? this.followersCount,
      totalPlays: totalPlays,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}
