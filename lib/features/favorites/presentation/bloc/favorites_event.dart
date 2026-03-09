import '../../../home/domain/entities/song_entity.dart';

abstract class FavoritesEvent {}

class LoadFavoritesEvent extends FavoritesEvent {}

class AddFavoriteEvent extends FavoritesEvent {
  final String songId;
  final SongEntity? song; // Para optimistic update
  AddFavoriteEvent(this.songId, {this.song});
}

class RemoveFavoriteEvent extends FavoritesEvent {
  final String songId;
  RemoveFavoriteEvent(this.songId);
}

class ResetFavoritesEvent extends FavoritesEvent {}
