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
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    // Intentar traer el nombre de artista, si no fallback al título del álbum
    final String artistName = json['artist_name'] ?? json['album_name'] ?? 'Artista desconocido';
    return SongModel(
      id: json['song_id']?.toString() ?? '1',
      title: json['title'] ?? 'Sin Título',
      album: json['album_name'] ?? 'Single',
      artistName: artistName,
      duration: json['duration']?.toString() ?? '0',
      coverUrl: json['cover_url'] ?? '',
      audioUrl: json['audio_url'] ?? '',
    );
  }
}