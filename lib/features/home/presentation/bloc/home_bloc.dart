import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/album_entity.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/song_entity.dart';
import '../../domain/usecases/get_songs_usecase.dart';
import '../../domain/usecases/get_albums_usecase.dart';
import '../../domain/usecases/get_playlists_usecase.dart';
import '../../domain/usecases/get_cached_home_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final SongUseCase _songsUseCase;
  final GetAlbumsUseCase _albumsUseCase;
  final GetPlaylistsUseCase _playlistsUseCase;
  final GetCachedHomeUseCase _getCachedHomeUseCase;

  HomeBloc({
    required SongUseCase getSongsUseCase,
    required GetAlbumsUseCase getAlbumsUseCase,
    required GetPlaylistsUseCase getPlaylistsUseCase,
    required GetCachedHomeUseCase getCachedHomeUseCase,
  })  : _songsUseCase = getSongsUseCase,
        _albumsUseCase = getAlbumsUseCase,
        _playlistsUseCase = getPlaylistsUseCase,
        _getCachedHomeUseCase = getCachedHomeUseCase,
        super(HomeInitial()) {
    on<ResetHomeEvent>((event, emit) {
      emit(HomeLoading());
    });

    on<GetSongsEvent>((event, emit) async {
      // Si ya tenemos datos frescos y no se pide refresco, evitamos llamadas innecesarias
      if (state is HomeLoaded && !event.forceRefresh) return;

      // Si ya hay una carga en curso, ignoramos la petición duplicada
      if (state is HomeLoading) return;

      // 1. Mostrar caché inmediatamente (offline-first) si hay datos persistidos
      final cache = await _getCachedHomeUseCase();
      final cachedAlbums = (cache['albums'] ?? const <dynamic>[]).cast<AlbumEntity>();
      final cachedPlaylists = (cache['playlists'] ?? const <dynamic>[]).cast<PlaylistEntity>();

      if (cachedAlbums.isNotEmpty || cachedPlaylists.isNotEmpty) {
        emit(HomeLoaded(
          songs: const [],
          albums: cachedAlbums,
          playlists: cachedPlaylists,
        ));
      } else {
        emit(HomeLoading());
      }

      try {
        // 2. Ejecutar las tres llamadas en paralelo para minimizar tiempo de espera
        final results = await Future.wait<dynamic>([
          _songsUseCase(),
          _albumsUseCase(),
          _playlistsUseCase(),
        ]);

        final songsResult = results[0] as Either<String, List<SongEntity>>;
        final albumsResult = results[1] as Either<String, List<AlbumEntity>>;
        final playlistsResult = results[2] as Either<String, List<PlaylistEntity>>;

        // Recopilar el primer error encontrado (si existe)
        String? errorMessage;
        songsResult.fold((l) => errorMessage ??= l, (_) => null);
        albumsResult.fold((l) => errorMessage ??= l, (_) => null);
        playlistsResult.fold((l) => errorMessage ??= l, (_) => null);

        if (errorMessage != null) {
          // Si ya mostramos caché, no reemplazamos con pantalla de error total
          if (state is! HomeLoaded) {
            emit(HomeFailure(errorMessage: errorMessage!));
          }
          return;
        }

        emit(HomeLoaded(
          songs: songsResult.fold<List<SongEntity>>((_) => [], (r) => r),
          albums: albumsResult.fold<List<AlbumEntity>>((_) => [], (r) => r),
          playlists: playlistsResult.fold<List<PlaylistEntity>>((_) => [], (r) => r),
        ));
      } catch (e) {
        if (state is! HomeLoaded) {
          emit(HomeFailure(errorMessage: 'Error inesperado: $e'));
        }
      }
    });
  }
}
