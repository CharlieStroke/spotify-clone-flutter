import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ArtistEvent extends Equatable {
  const ArtistEvent();

  @override
  List<Object?> get props => [];
}

class CheckArtistStatusEvent extends ArtistEvent {}

class LoadArtistAlbumsEvent extends ArtistEvent {}

class RegisterArtistEvent extends ArtistEvent {
  final String stageName;
  final String bio;
  final File image;

  const RegisterArtistEvent({
    required this.stageName,
    required this.bio,
    required this.image,
  });

  @override
  List<Object?> get props => [stageName, bio, image];
}

class CreateAlbumEvent extends ArtistEvent {
  final String title;
  final File cover;

  const CreateAlbumEvent({required this.title, required this.cover});

  @override
  List<Object?> get props => [title, cover];
}

class UploadSongEvent extends ArtistEvent {
  final String title;
  final int albumId;
  final File audio;
  final File cover;

  const UploadSongEvent({
    required this.title,
    required this.albumId,
    required this.audio,
    required this.cover,
  });

  @override
  List<Object?> get props => [title, albumId, audio, cover];
}
