abstract class LibraryActionEvent {}

class AddSongEvent extends LibraryActionEvent {
  final String playlistId;
  final String songId;
  AddSongEvent({required this.playlistId, required this.songId});
}

class DeletePlaylistEvent extends LibraryActionEvent {
  final String playlistId;
  DeletePlaylistEvent(this.playlistId);
}

class RemoveSongEvent extends LibraryActionEvent {
  final String playlistId;
  final String songId;
  RemoveSongEvent({required this.playlistId, required this.songId});
}

