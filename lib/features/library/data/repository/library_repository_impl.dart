import 'package:dartz/dartz.dart';
import '../sources/library_api_service.dart';
import '../../domain/repository/library_repository.dart';

import '../sources/library_local_data_source.dart';
 
class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryApiService _apiService;
  final LibraryLocalDataSource _localDataSource;

  LibraryRepositoryImpl(this._apiService, this._localDataSource);

  @override
  Future<Either<String, Map<String, List<dynamic>>>> getUserLibrary() async {
    try {
      final results = await _apiService.getUserLibrary();
      await _localDataSource.cacheLibrary(results);
      return Right(results);
    } catch (e) {
      final cached = await _localDataSource.getCachedLibrary();
      if ((cached['playlists'] as List).isNotEmpty || (cached['albums'] as List).isNotEmpty) {
        return Right(cached);
      }
      return Left(e.toString());
    }
  }

  @override
  Future<Map<String, List<dynamic>>> getCachedLibrary() => _localDataSource.getCachedLibrary();

  @override
  Future<Either<String, void>> addSongToPlaylist(String playlistId, String songId) async {
    try {
      await _apiService.addSongToPlaylist(playlistId, songId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> createPlaylist(String name, String description) async {
    try {
      await _apiService.createPlaylist(name, description);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deletePlaylist(String playlistId) async {
    try {
      await _apiService.deletePlaylist(playlistId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      await _apiService.removeSongFromPlaylist(playlistId, songId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
