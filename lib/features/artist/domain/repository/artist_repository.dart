import 'package:dartz/dartz.dart';
import '../entities/artist_entity.dart';
import '../../../home/domain/entities/album_entity.dart';
import '../../../home/domain/entities/song_entity.dart';
import 'dart:io';

abstract class ArtistRepository {
  Future<Either<String, ArtistEntity?>> getMyArtistProfile();
  Future<Either<String, ArtistEntity>> createArtist({
    required String stageName,
    required String bio,
    required File image,
  });

  // Albums
  Future<Either<String, List<AlbumEntity>>> getMyAlbums();
  Future<Either<String, AlbumEntity>> createAlbum({
    required String title,
    required File cover,
  });

  // Songs
  Future<Either<String, SongEntity>> uploadSong({
    required String title,
    required int albumId,
    required File audio,
    required File cover,
  });
}
