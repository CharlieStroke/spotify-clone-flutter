import '../../../home/domain/entities/song_entity.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../sources/favorites_api_service.dart';
import '../sources/favorites_local_data_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesApiService _apiService;
  final FavoritesLocalDataSource _localDataSource;

  FavoritesRepositoryImpl(this._apiService, this._localDataSource);

  @override
  Future<List<SongEntity>> getFavorites() async {
    // 1. Return local cache first if available
    final localFavorites = await _localDataSource.getCachedFavorites();
    
    // 2. Try fetching from remote and updating cache
    try {
      final remoteFavorites = await _apiService.getFavorites();
      await _localDataSource.cacheFavorites(remoteFavorites);
      return remoteFavorites;
    } catch (_) {
      // 3. Fallback to local if remote fails
      if (localFavorites.isNotEmpty) {
        return localFavorites;
      }
      return [];
    }
  }

  @override
  Future<void> addFavorite(String songId) async {
    // Optional: Optimistic update local cache if we had the full song model.
    // However, addFavorite by songId only might not be enough to cache without the model.
    // The UI handles optimistic update itself via bloc state.
    // We just call the API.
    await _apiService.addFavorite(songId);
  }

  @override
  Future<void> removeFavorite(String songId) async {
    // Optimistic remove from local cache
    await _localDataSource.removeFavorite(songId);
    await _apiService.removeFavorite(songId);
  }
}
