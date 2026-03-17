import 'package:dartz/dartz.dart';
import 'home_repository.dart';
import '../../domain/entities/album_entity.dart';
import '../../domain/entities/playlist_entity.dart';
import '../sources/home_api_service.dart';
import '../sources/home_local_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeApiService _apiService;
  final HomeLocalDataSource _localDataSource;

  HomeRepositoryImpl(this._apiService, this._localDataSource);

  @override
  Future<Either<String, List<AlbumEntity>>> getAlbums() async {
    try {
      final albums = await _apiService.getAlbums();
      await _localDataSource.cacheAlbums(albums);
      return Right(albums);
    } catch (e) {
      final cachedAlbums = await _localDataSource.getCachedAlbums();
      if (cachedAlbums.isNotEmpty) {
        return Right(cachedAlbums);
      }
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<PlaylistEntity>>> getPlaylists() async {
    try {
      final playlists = await _apiService.getPlaylists();
      await _localDataSource.cachePlaylists(playlists);
      return Right(playlists);
    } catch (e) {
      final cachedPlaylists = await _localDataSource.getCachedPlaylists();
      if (cachedPlaylists.isNotEmpty) {
        return Right(cachedPlaylists);
      }
      return Left(e.toString());
    }
  }

  @override
  Future<List<AlbumEntity>> getCachedAlbums() => _localDataSource.getCachedAlbums();

  @override
  Future<List<PlaylistEntity>> getCachedPlaylists() => _localDataSource.getCachedPlaylists();
}
