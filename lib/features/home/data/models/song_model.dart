import '../../domain/entities/song_entity.dart';

class SongModel extends SongEntity {
  SongModel({
    required super.title,
    required super.album,
    required super.duration,
    required super.coverUrl,
    required super.audioUrl,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      // Mapeamos exactamente lo que llega
      title: json['title'] ?? 'Sin título',
      album: 'ID Álbum: ${json['album_id']}', // Mostramos el ID mientras el backend no mande el nombre
      duration: json['duration']?.toString() ?? '0',
      coverUrl: json['cover_url'] ?? '',
      audioUrl: json['audio_url'] ?? '',
    );
  }
}