import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_song_usecase.dart';
import 'library_action_event.dart';
import 'library_action_state.dart';

class LibraryActionBloc extends Bloc<LibraryActionEvent, LibraryActionState> {
  final AddSongToPlaylistUseCase _addSongToPlaylistUseCase;

  LibraryActionBloc(this._addSongToPlaylistUseCase) : super(LibraryActionInitial()) {
    on<AddSongEvent>((event, emit) async {
      emit(LibraryActionLoading());

      final result = await _addSongToPlaylistUseCase(event.playlistId, event.songId);

      result.fold(
        (failure) => emit(LibraryActionFailure(failure)),
        (_) => emit(LibraryActionSuccess('Canción añadida a la playlist exitosamente')),
      );
    });
  }
}
