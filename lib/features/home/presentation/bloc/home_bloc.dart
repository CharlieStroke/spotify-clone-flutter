import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_songs_usecase.dart';
import '../../domain/usecases/get_albums_usecase.dart';
import '../../domain/usecases/get_playlists_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final SongUseCase _songsUseCase;
  final GetAlbumsUseCase _albumsUseCase;
  final GetPlaylistsUseCase _playlistsUseCase;

  HomeBloc({
    required SongUseCase getSongsUseCase,
    required GetAlbumsUseCase getAlbumsUseCase,
    required GetPlaylistsUseCase getPlaylistsUseCase,
  }) : _songsUseCase = getSongsUseCase,
       _albumsUseCase = getAlbumsUseCase,
       _playlistsUseCase = getPlaylistsUseCase,
       super(HomeLoading()) {
    
    on<ResetHomeEvent>((event, emit) {
      emit(HomeLoading());
    });

    on<GetSongsEvent>((event, emit) async {
      emit(HomeLoading());
      
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
        emit(HomeFailure(errorMessage: errorMessage));
      } else {
        emit(HomeLoaded(
          // Forzamos los tipos asumiendo que el Right fue exitoso en los tres
          songs: songsResult.fold((l) => [], (r) => r as dynamic),
          albums: albumsResult.fold((l) => [], (r) => r as dynamic),
          playlists: playlistsResult.fold((l) => [], (r) => r as dynamic),
        ));
      }
    });
  }
}