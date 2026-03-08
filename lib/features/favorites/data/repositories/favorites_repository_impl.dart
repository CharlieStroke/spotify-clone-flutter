import '../../../home/domain/entities/song_entity.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../sources/favorites_api_service.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesApiService _apiService;
  FavoritesRepositoryImpl(this._apiService);

  @override
  Future<List<SongEntity>> getFavorites() => _apiService.getFavorites();

  @override
  Future<void> addFavorite(String songId) => _apiService.addFavorite(songId);

  @override
  Future<void> removeFavorite(String songId) => _apiService.removeFavorite(songId);
}
