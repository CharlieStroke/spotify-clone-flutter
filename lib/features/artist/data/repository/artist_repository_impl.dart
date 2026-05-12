import 'package:dartz/dartz.dart';
import 'dart:io';
import '../../domain/entities/artist_entity.dart';
import '../../domain/entities/artist_stats_entity.dart';
import '../../domain/repository/artist_repository.dart';
import '../sources/artist_api_service.dart';
import 'package:spotify_clone/features/home/domain/entities/album_entity.dart';
import 'package:spotify_clone/features/home/domain/entities/song_entity.dart';

class ArtistRepositoryImpl implements ArtistRepository {
  final ArtistApiService _apiService;

  ArtistRepositoryImpl(this._apiService);

  @override
  Future<Either<String, ArtistEntity?>> getMyArtistProfile() async {
    try {
      final artist = await _apiService.getMyArtistProfile();
      return Right(artist);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, ArtistEntity>> createArtist({
    required String stageName,
    required String bio,
    required File image,
  }) async {
    try {
      final artist = await _apiService.createArtist(
        stageName: stageName,
        bio: bio,
        image: image,
      );
      return Right(artist);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<AlbumEntity>>> getMyAlbums() async {
    try {
      final albums = await _apiService.getMyAlbums();
      return Right(albums);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, AlbumEntity>> createAlbum({
    required String title,
    required File cover,
  }) async {
    try {
      final album = await _apiService.createAlbum(title: title, cover: cover);
      return Right(album);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, SongEntity>> uploadSong({
    required String title,
    required int albumId,
    required File audio,
    required File cover,
    int? duration,
  }) async {
    try {
      final song = await _apiService.uploadSong(
        title: title,
        albumId: albumId,
        audio: audio,
        cover: cover,
        duration: duration,
      );
      return Right(song);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, ArtistStatsEntity>> getArtistStats() async {
    try {
      final stats = await _apiService.getArtistStats();
      return Right(stats);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, ArtistEntity>> getPublicArtistProfile(int artistId) async {
    try {
      final artist = await _apiService.getPublicArtistProfile(artistId);
      return Right(artist);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<SongEntity>>> getPublicArtistTopSongs(int artistId) async {
    try {
      final songs = await _apiService.getPublicArtistTopSongs(artistId);
      return Right(songs);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<AlbumEntity>>> getPublicArtistAlbums(int artistId) async {
    try {
      final albums = await _apiService.getPublicArtistAlbums(artistId);
      return Right(albums);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Unit>> followArtist(int artistId) async {
    try {
      await _apiService.followArtist(artistId);
      return const Right(unit);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Unit>> unfollowArtist(int artistId) async {
    try {
      await _apiService.unfollowArtist(artistId);
      return const Right(unit);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
