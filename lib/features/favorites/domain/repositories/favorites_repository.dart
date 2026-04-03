import '../../../home/domain/entities/song_entity.dart';

abstract class FavoritesRepository {
  Future<List<SongEntity>> getFavorites();
  Future<List<SongEntity>> getCachedFavorites();
  Future<void> addFavorite(String songId);
  Future<void> addCachedFavorite(SongEntity song);
  Future<void> removeFavorite(String songId);
}
