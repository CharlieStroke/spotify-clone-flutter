import '../../domain/entities/song_entity.dart';

class SongModel extends SongEntity {
  SongModel({
    required super.id,
    required super.title,
    required super.album,
    required super.artistName,
    required super.duration,
    required super.coverUrl,
    required super.audioUrl,
    super.plays = 0,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    final String artistName = json['artist_name'] ?? json['album_name'] ?? 'Artista desconocido';
    return SongModel(
      id: json['song_id']?.toString() ?? '1',
      title: json['title'] ?? 'Sin Título',
      album: json['album_name'] ?? 'Single',
      artistName: artistName,
      duration: json['duration']?.toString() ?? '0',
      coverUrl: json['cover_url'] ?? '',
      audioUrl: json['audio_url'] ?? '',
      plays: (json['plays'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'song_id': id,
      'title': title,
      'album_name': album,
      'artist_name': artistName,
      'duration': duration,
      'cover_url': coverUrl,
      'audio_url': audioUrl,
    };
  }

}