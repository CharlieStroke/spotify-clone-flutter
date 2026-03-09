import 'dart:io';

abstract class CreatePlaylistEvent {}

class SubmitPlaylistEvent extends CreatePlaylistEvent {
  final String name;
  final String description;
  final File? image;

  SubmitPlaylistEvent({
    required this.name, 
    required this.description,
    this.image,
  });
}
