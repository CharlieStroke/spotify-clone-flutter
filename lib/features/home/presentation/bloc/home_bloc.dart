import 'package:flutter_bloc/flutter_bloc.dart';
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
  }) : _songsUseCase = getSongsUseCase,
       _albumsUseCase = getAlbumsUseCase,
       _playlistsUseCase = getPlaylistsUseCase,
       _getCachedHomeUseCase = getCachedHomeUseCase,
       super(HomeInitial()) {
    
    on<ResetHomeEvent>((event, emit) {
      emit(HomeLoading());
    });

    on<GetSongsEvent>((event, emit) async {
      // Si ya está cargado y no pedimos refresco forzado, ignoramos para evitar 429
      if (state is HomeLoaded && !event.forceRefresh) return;
      
      // Si ya estamos cargando, ignoramos peticiones duplicadas
      if (state is HomeLoading && state is! HomeInitial) return;

      // 1. Mostrar caché inmediatamente si existe para Offline-First
      final cache = await _getCachedHomeUseCase();
      if ((cache['albums'] as List).isNotEmpty || (cache['playlists'] as List).isNotEmpty) {
        emit(HomeLoaded(
          songs: [], 
          albums: cache['albums'] as dynamic,
          playlists: cache['playlists'] as dynamic,
        ));
      } else {
        emit(HomeLoading());
      }
      
      try {
        // Ejecutamos las tres llamadas en paralelo
        final results = await Future.wait([
          _songsUseCase(),
          _albumsUseCase(),
          _playlistsUseCase(),
        ]);

        final songsResult = results[0];
        final albumsResult = results[1];
        final playlistsResult = results[2];

        bool hasError = false;
        String errorMessage = '';

        songsResult.fold((l) { hasError = true; errorMessage = l; }, (r) => null);
        albumsResult.fold((l) { hasError = true; errorMessage = l; }, (r) => null);
        playlistsResult.fold((l) { hasError = true; errorMessage = l; }, (r) => null);

        if (hasError) {
          // Si ya tenemos datos (del caché), no mostramos pantalla de error total
          if (state is! HomeLoaded) {
            emit(HomeFailure(errorMessage: errorMessage));
          }
        } else {
          emit(HomeLoaded(
            songs: songsResult.fold((l) => [], (r) => r as dynamic),
            albums: albumsResult.fold((l) => [], (r) => r as dynamic),
            playlists: playlistsResult.fold((l) => [], (r) => r as dynamic),
          ));
        }
      } catch (e) {
        emit(HomeFailure(errorMessage: 'Error inesperado: $e'));
      }
    });
  }
}