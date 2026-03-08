import '../../../home/domain/entities/song_entity.dart';

abstract class FavoritesState {}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<SongEntity> songs;
  final Set<String> favoriteIds;

  FavoritesLoaded({required this.songs})
      : favoriteIds = songs.map((s) => s.id).toSet();

  bool isFavorite(String songId) => favoriteIds.contains(songId);
}

class FavoritesError extends FavoritesState {
  final String message;
  FavoritesError(this.message);
}
