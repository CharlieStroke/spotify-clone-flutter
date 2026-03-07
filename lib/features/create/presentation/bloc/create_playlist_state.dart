import '../../../home/domain/entities/playlist_entity.dart';

abstract class CreatePlaylistState {}

class CreatePlaylistInitial extends CreatePlaylistState {}

class CreatePlaylistLoading extends CreatePlaylistState {}

class CreatePlaylistSuccess extends CreatePlaylistState {
  final PlaylistEntity playlist;
  CreatePlaylistSuccess(this.playlist);
}

class CreatePlaylistFailure extends CreatePlaylistState {
  final String error;
  CreatePlaylistFailure(this.error);
}
