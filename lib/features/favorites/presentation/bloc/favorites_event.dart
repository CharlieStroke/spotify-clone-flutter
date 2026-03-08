abstract class FavoritesEvent {}

class LoadFavoritesEvent extends FavoritesEvent {}

class AddFavoriteEvent extends FavoritesEvent {
  final String songId;
  AddFavoriteEvent(this.songId);
}

class RemoveFavoriteEvent extends FavoritesEvent {
  final String songId;
  RemoveFavoriteEvent(this.songId);
}

class ResetFavoritesEvent extends FavoritesEvent {}
