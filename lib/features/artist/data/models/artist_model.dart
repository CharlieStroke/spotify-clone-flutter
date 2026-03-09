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
    final rawArtistId = json['artist_id'];
    final rawUserId = json['user_id'];
    return ArtistModel(
      artistId: rawArtistId is int ? rawArtistId : int.tryParse(rawArtistId.toString()) ?? 0,
      userId: rawUserId is int ? rawUserId : int.tryParse(rawUserId.toString()) ?? 0,
      stageName: json['stage_name'] ?? '',
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
