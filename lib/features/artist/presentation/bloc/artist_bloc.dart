import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/artist_repository.dart';
import 'artist_event.dart';
import 'artist_state.dart';

class ArtistBloc extends Bloc<ArtistEvent, ArtistState> {
  final ArtistRepository _repository;

  ArtistBloc(this._repository) : super(ArtistInitial()) {
    on<CheckArtistStatusEvent>(_onCheckStatus);
    on<RegisterArtistEvent>(_onRegister);
    on<LoadArtistAlbumsEvent>(_onLoadAlbums);
    on<CreateAlbumEvent>(_onCreateAlbum);
    on<UploadSongEvent>(_onUploadSong);
  }

  Future<void> _onCheckStatus(CheckArtistStatusEvent event, Emitter<ArtistState> emit) async {
    emit(ArtistLoading());
    final result = await _repository.getMyArtistProfile();
    result.fold(
      (error) => emit(ArtistFailure(error)),
      (artist) => emit(ArtistStatusLoaded(artist: artist)),
    );
  }

  Future<void> _onRegister(RegisterArtistEvent event, Emitter<ArtistState> emit) async {
    emit(ArtistLoading());
    final result = await _repository.createArtist(
      stageName: event.stageName,
      bio: event.bio,
      image: event.image,
    );
    result.fold(
      (error) => emit(ArtistFailure(error)),
      (artist) => emit(ArtistRegistrationSuccess(artist)),
    );
  }

  Future<void> _onLoadAlbums(LoadArtistAlbumsEvent event, Emitter<ArtistState> emit) async {
    emit(ArtistLoading());
    final result = await _repository.getMyAlbums();
    result.fold(
      (error) => emit(ArtistFailure(error)),
      (albums) => emit(ArtistAlbumsLoaded(albums)),
    );
  }

  Future<void> _onCreateAlbum(CreateAlbumEvent event, Emitter<ArtistState> emit) async {
    emit(ArtistLoading());
    final result = await _repository.createAlbum(
      title: event.title,
      cover: event.cover,
    );
    result.fold(
      (error) => emit(ArtistFailure(error)),
      (album) => emit(CreateAlbumSuccess(album)),
    );
  }

  Future<void> _onUploadSong(UploadSongEvent event, Emitter<ArtistState> emit) async {
    emit(ArtistLoading());
    final result = await _repository.uploadSong(
      title: event.title,
      albumId: event.albumId,
      audio: event.audio,
      cover: event.cover,
      duration: event.duration,
    );
    result.fold(
      (error) => emit(ArtistFailure(error)),
      (song) => emit(UploadSongSuccess(song)),
    );
  }
}
