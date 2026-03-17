import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_library_usecase.dart';
import 'library_event.dart';
import 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final GetLibraryUseCase _getLibraryUseCase;

  LibraryBloc(this._getLibraryUseCase) : super(LibraryInitial()) {
    on<ResetLibraryEvent>((event, emit) {
      emit(LibraryInitial());
    });

    on<LoadLibraryEvent>((event, emit) async {
      // Evitar llamadas duplicadas si ya hay datos
      if (state is LibraryLoaded && !event.forceRefresh) return;
      if (state is LibraryLoading) return;

      emit(LibraryLoading());

      final result = await _getLibraryUseCase();

      result.fold(
        (failure) => emit(LibraryFailure(failure)),
        (data) => emit(LibraryLoaded(
          playlists: data['playlists']!,
          albums: data['albums']!,
        )),
      );
    });
  }
}
