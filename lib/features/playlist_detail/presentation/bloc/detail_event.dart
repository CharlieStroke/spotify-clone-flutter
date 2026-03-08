abstract class PlaylistDetailEvent {}

class LoadPlaylistDetailEvent extends PlaylistDetailEvent {
  final String id;
  final String type; // 'playlist' or 'album'

  LoadPlaylistDetailEvent({required this.id, required this.type});
}
