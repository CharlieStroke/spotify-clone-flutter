import '../../../home/domain/entities/song_entity.dart';

abstract class FavoritesRepository {
  Future<List<SongEntity>> getFavorites();
  Future<void> addFavorite(String songId);
  Future<void> removeFavorite(String songId);
}
