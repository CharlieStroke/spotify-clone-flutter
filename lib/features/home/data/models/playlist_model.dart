import '../../domain/entities/playlist_entity.dart';

class PlaylistModel extends PlaylistEntity {
  PlaylistModel({
    required super.id,
    required super.name,
    required super.description,
    required super.userId,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['playlist_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      userId: json['user_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playlist_id': id,
      'name': name,
      'description': description,
      'user_id': userId,
    };
  }
}
