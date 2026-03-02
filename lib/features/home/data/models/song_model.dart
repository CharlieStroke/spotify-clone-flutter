import '../../domain/entities/song_entity.dart';

class SongModel extends SongEntity {
  SongModel({
    required super.title,
    required super.artist,
    required super.duration,
    required super.coverUrl,
    required super.audioUrl,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      title: json['title'] ?? 'Sin título',
      artist: json['artist'] ?? 'Artista desconocido',
      duration: json['duration']?.toString() ?? '0:00',
      // Importante: Aquí concatenamos la URL de tu VM para las imágenes/audio
      coverUrl: json['coverUrl'] ?? '',
      audioUrl: json['audioUrl'] ?? '',
    );
  }
}