class TopSongEntity {
  final int songId;
  final String title;
  final int plays;
  final String coverUrl;

  const TopSongEntity({
    required this.songId,
    required this.title,
    required this.plays,
    required this.coverUrl,
  });
}

class AlbumPlaysEntity {
  final int albumId;
  final String title;
  final String coverUrl;
  final int plays;

  const AlbumPlaysEntity({
    required this.albumId,
    required this.title,
    required this.coverUrl,
    required this.plays,
  });
}

class ArtistStatsEntity {
  final int totalPlays;
  final int totalSongs;
  final int totalAlbums;
  final List<TopSongEntity> topSongs;
  final List<AlbumPlaysEntity> playsByAlbum;

  const ArtistStatsEntity({
    required this.totalPlays,
    required this.totalSongs,
    required this.totalAlbums,
    required this.topSongs,
    required this.playsByAlbum,
  });
}
