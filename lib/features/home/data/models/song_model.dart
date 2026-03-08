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
    return SongModel(
      id: json['song_id']?.toString() ?? '1',
      // Mapeamos exactamente lo que llega
      title: json['title'] ?? 'Sin Título',
      album: 'ID Álbum: ${json['album_id']}', // Mostramos el ID mientras el backend no mande el nombre
      duration: json['duration']?.toString() ?? '0',
      coverUrl: json['cover_url'] ?? '',
      audioUrl: json['audio_url'] ?? '',
    );
  }
}