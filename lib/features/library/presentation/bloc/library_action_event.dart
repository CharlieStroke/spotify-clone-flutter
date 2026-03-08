abstract class LibraryActionEvent {}

class AddSongEvent extends LibraryActionEvent {
  final String playlistId;
  final String songId;
  AddSongEvent({required this.playlistId, required this.songId});
}
