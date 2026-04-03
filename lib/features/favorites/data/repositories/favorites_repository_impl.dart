import '../../../home/domain/entities/song_entity.dart';
import '../../../home/data/models/song_model.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../sources/favorites_api_service.dart';
import '../sources/favorites_local_data_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesApiService _apiService;
  final FavoritesLocalDataSource _localDataSource;

  FavoritesRepositoryImpl(this._apiService, this._localDataSource);

  @override
  Future<List<SongEntity>> getFavorites() async {
    try {
      final remoteFavorites = await _apiService.getFavorites();
      await _localDataSource.cacheFavorites(remoteFavorites);
      return remoteFavorites;
    } catch (_) {
      return _localDataSource.getCachedFavorites();
    }
  }

  @override
  Future<List<SongEntity>> getCachedFavorites() =>
      _localDataSource.getCachedFavorites();

  @override
  Future<void> addFavorite(String songId) async {
    await _apiService.addFavorite(songId);
  }

  @override
  Future<void> addCachedFavorite(SongEntity song) async {
    await _localDataSource.addFavorite(SongModel(
      id: song.id,
      title: song.title,
      album: song.album,
      artistName: song.artistName,
      duration: song.duration,
      coverUrl: song.coverUrl,
      audioUrl: song.audioUrl,
    ));
  }

  @override
  Future<void> removeFavorite(String songId) async {
    await _localDataSource.removeFavorite(songId);
    await _apiService.removeFavorite(songId);
  }
}
