import 'package:equatable/equatable.dart';
import '../../domain/entities/artist_entity.dart';
import 'package:spotify_clone/features/home/domain/entities/album_entity.dart';
import 'package:spotify_clone/features/home/domain/entities/song_entity.dart';

abstract class ArtistState extends Equatable {
  const ArtistState();

  @override
  List<Object?> get props => [];
}

class ArtistInitial extends ArtistState {}

class ArtistLoading extends ArtistState {}

class ArtistStatusLoaded extends ArtistState {
  final ArtistEntity? artist;
  const ArtistStatusLoaded({this.artist});

  bool get isArtist => artist != null;

  @override
  List<Object?> get props => [artist];
}

class ArtistFailure extends ArtistState {
  final String message;
  const ArtistFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ArtistRegistrationSuccess extends ArtistState {
  final ArtistEntity artist;
  const ArtistRegistrationSuccess(this.artist);

  @override
  List<Object?> get props => [artist];
}

class ArtistAlbumsLoaded extends ArtistState {
  final List<AlbumEntity> albums;
  const ArtistAlbumsLoaded(this.albums);

  @override
  List<Object?> get props => [albums];
}

class CreateAlbumSuccess extends ArtistState {
  final AlbumEntity album;
  const CreateAlbumSuccess(this.album);

  @override
  List<Object?> get props => [album];
}

class UploadSongSuccess extends ArtistState {
  final SongEntity song;
  const UploadSongSuccess(this.song);

  @override
  List<Object?> get props => [song];
}
