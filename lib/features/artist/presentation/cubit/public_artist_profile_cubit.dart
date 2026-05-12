import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/artist_entity.dart';
import '../../domain/usecases/get_public_artist_usecase.dart';
import '../../domain/usecases/get_public_artist_top_songs_usecase.dart';
import '../../domain/usecases/get_public_artist_albums_usecase.dart';
import '../../../home/domain/entities/song_entity.dart';
import '../../../home/domain/entities/album_entity.dart';

abstract class PublicArtistProfileState {}

class PublicArtistProfileInitial extends PublicArtistProfileState {}

class PublicArtistProfileLoading extends PublicArtistProfileState {}

class PublicArtistProfileLoaded extends PublicArtistProfileState {
  final ArtistEntity artist;
  final List<SongEntity> topSongs;
  final List<AlbumEntity> albums;

  PublicArtistProfileLoaded({
    required this.artist,
    required this.topSongs,
    required this.albums,
  });
}

class PublicArtistProfileError extends PublicArtistProfileState {
  final String message;
  PublicArtistProfileError(this.message);
}

class PublicArtistProfileCubit extends Cubit<PublicArtistProfileState> {
  final GetPublicArtistUseCase _getArtist;
  final GetPublicArtistTopSongsUseCase _getTopSongs;
  final GetPublicArtistAlbumsUseCase _getAlbums;

  PublicArtistProfileCubit(
    this._getArtist,
    this._getTopSongs,
    this._getAlbums,
  ) : super(PublicArtistProfileInitial());

  Future<void> loadProfile(int artistId) async {
    if (state is PublicArtistProfileLoading) return;
    emit(PublicArtistProfileLoading());

    final artistFuture = _getArtist.call(artistId);
    final songsFuture = _getTopSongs.call(artistId);
    final albumsFuture = _getAlbums.call(artistId);

    final artistResult = await artistFuture;
    if (artistResult.isLeft()) {
      emit(PublicArtistProfileError(
        artistResult.fold((l) => l, (r) => 'Error desconocido'),
      ));
      return;
    }

    final songsResult = await songsFuture;
    final albumsResult = await albumsFuture;

    emit(PublicArtistProfileLoaded(
      artist: artistResult.getOrElse(() => throw Exception()),
      topSongs: songsResult.getOrElse(() => []),
      albums: albumsResult.getOrElse(() => []),
    ));
  }

  void retry(int artistId) {
    emit(PublicArtistProfileInitial());
    loadProfile(artistId);
  }
}
