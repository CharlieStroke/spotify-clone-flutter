import '../../domain/entities/artist_entity.dart';

class ArtistModel extends ArtistEntity {
  ArtistModel({
    required super.artistId,
    required super.userId,
    required super.stageName,
    required super.bio,
    required super.imageUrl,
  });

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(
      artistId: json['artist_id'],
      userId: json['user_id'],
      stageName: json['stage_name'],
      bio: json['bio'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'artist_id': artistId,
      'user_id': userId,
      'stage_name': stageName,
      'bio': bio,
      'image_url': imageUrl,
    };
  }
}
