import '../../domain/entities/artist_stats_entity.dart';

class TopSongModel extends TopSongEntity {
  const TopSongModel({
    required super.songId,
    required super.title,
    required super.plays,
    required super.coverUrl,
  });

  factory TopSongModel.fromJson(Map<String, dynamic> json) => TopSongModel(
        songId:   (json['song_id'] as num).toInt(),
        title:    json['title'] as String,
        plays:    (json['plays'] as num).toInt(),
        coverUrl: json['cover_url'] as String? ?? '',
      );
}

class AlbumPlaysModel extends AlbumPlaysEntity {
  const AlbumPlaysModel({
    required super.albumId,
    required super.title,
    required super.coverUrl,
    required super.plays,
  });

  factory AlbumPlaysModel.fromJson(Map<String, dynamic> json) => AlbumPlaysModel(
        albumId:  (json['album_id'] as num).toInt(),
        title:    json['title'] as String,
        coverUrl: json['cover_url'] as String? ?? '',
        plays:    (json['plays'] as num).toInt(),
      );
}

class ArtistStatsModel extends ArtistStatsEntity {
  const ArtistStatsModel({
    required super.totalPlays,
    required super.totalSongs,
    required super.totalAlbums,
    required super.topSongs,
    required super.playsByAlbum,
  });

  factory ArtistStatsModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>;
    return ArtistStatsModel(
      totalPlays:  (stats['total_plays'] as num).toInt(),
      totalSongs:  (stats['total_songs'] as num).toInt(),
      totalAlbums: (stats['total_albums'] as num).toInt(),
      topSongs: (stats['top_songs'] as List<dynamic>)
          .map((e) => TopSongModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      playsByAlbum: (stats['plays_by_album'] as List<dynamic>)
          .map((e) => AlbumPlaysModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
