import '../../domain/entities/album_entity.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/song_entity.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<SongEntity> songs;
  final List<AlbumEntity> albums;
  final List<PlaylistEntity> playlists;

  HomeLoaded({
    required this.songs,
    required this.albums,
    required this.playlists,
  });
}

class HomeFailure extends HomeState {
  final String errorMessage;
  HomeFailure({required this.errorMessage});
}