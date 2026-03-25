import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_library_usecase.dart';
import '../../domain/usecases/get_cached_library_usecase.dart';
import 'library_event.dart';
import 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final GetLibraryUseCase _getLibraryUseCase;
  final GetCachedLibraryUseCase _getCachedLibraryUseCase;

  LibraryBloc(this._getLibraryUseCase, this._getCachedLibraryUseCase) : super(LibraryInitial()) {
    on<ResetLibraryEvent>((event, emit) {
      emit(LibraryInitial());
    });

    on<LoadLibraryEvent>((event, emit) async {
      // Evitar llamadas duplicadas si ya hay datos
      if (state is LibraryLoaded && !event.forceRefresh) return;
      if (state is LibraryLoading) return;

      // 1. Mostrar caché inmediatamente si existe (offline-first)
      final cache = await _getCachedLibraryUseCase();
      final cachedPlaylists = cache['playlists'] ?? const <dynamic>[];
      final cachedAlbums = cache['albums'] ?? const <dynamic>[];

      if (cachedPlaylists.isNotEmpty || cachedAlbums.isNotEmpty) {
        emit(LibraryLoaded(
          playlists: cachedPlaylists,
          albums: cachedAlbums,
        ));
      } else {
        emit(LibraryLoading());
      }

      final result = await _getLibraryUseCase();

      result.fold(
        (failure) {
          // Si ya hay datos del caché no mostramos error total, los datos siguen visibles
          if (state is! LibraryLoaded) {
            emit(LibraryFailure(failure));
          }
        },
        (data) => emit(LibraryLoaded(
          playlists: data['playlists'] ?? const <dynamic>[],
          albums: data['albums'] ?? const <dynamic>[],
        )),
      );
    });
  }
}
