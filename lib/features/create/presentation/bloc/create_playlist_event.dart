abstract class CreatePlaylistEvent {}

class SubmitPlaylistEvent extends CreatePlaylistEvent {
  final String name;
  final String description;

  SubmitPlaylistEvent({required this.name, required this.description});
}
