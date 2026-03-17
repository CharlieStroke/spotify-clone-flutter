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

      // 1. Mostrar caché inmediatamente si existe
      final cache = await _getCachedLibraryUseCase();
      if ((cache['playlists'] as List).isNotEmpty || (cache['albums'] as List).isNotEmpty) {
        emit(LibraryLoaded(
          playlists: cache['playlists']!,
          albums: cache['albums']!,
        ));
      } else {
        emit(LibraryLoading());
      }

      final result = await _getLibraryUseCase();

      result.fold(
        (failure) {
          if (state is! LibraryLoaded) {
            emit(LibraryFailure(failure));
          }
        },
        (data) => emit(LibraryLoaded(
          playlists: data['playlists']!,
          albums: data['albums']!,
        )),
      );
    });
  }
}
