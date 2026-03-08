import '../../domain/entities/song_entity.dart';

class SongModel extends SongEntity {
  SongModel({
    required super.id,
    required super.title,
    required super.album,
    required super.duration,
    required super.coverUrl,
    required super.audioUrl,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    // Tomamos artist_name si existe, si no intentamos con album_name o el título del álbum
    final String artistName = json['artist_name'] ?? json['album_name'] ?? '';
    return SongModel(
      id: json['song_id']?.toString() ?? '1',
      title: json['title'] ?? 'Sin Título',
      album: artistName,
      duration: json['duration']?.toString() ?? '0',
      coverUrl: json['cover_url'] ?? '',
      audioUrl: json['audio_url'] ?? '',
    );
  }
}