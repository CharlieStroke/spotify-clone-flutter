import '../../domain/entities/album_entity.dart';

class AlbumModel extends AlbumEntity {
  AlbumModel({
    required super.id,
    required super.title,
    required super.coverUrl,
    required super.artistName,
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['album_id'];
    return AlbumModel(
      id: rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0,
      title: json['title'] ?? '',
      coverUrl: (json['cover_url'] ?? '').toString().trim(),
      artistName: json['artist_name'] ?? 'Artista desconocido',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'album_id': id,
      'title': title,
      'cover_url': coverUrl,
      'artist_name': artistName,
    };
  }
}
