import '../../../home/domain/entities/song_entity.dart';

abstract class PlaylistDetailState {}

class PlaylistDetailInitial extends PlaylistDetailState {}

class PlaylistDetailLoading extends PlaylistDetailState {}

class PlaylistDetailLoaded extends PlaylistDetailState {
  final List<SongEntity> songs;
  PlaylistDetailLoaded({required this.songs});
}

class PlaylistDetailFailure extends PlaylistDetailState {
  final String error;
  PlaylistDetailFailure(this.error);
}
