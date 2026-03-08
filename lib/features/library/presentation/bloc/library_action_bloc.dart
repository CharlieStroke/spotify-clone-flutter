import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_song_usecase.dart';
import '../../domain/usecases/delete_playlist_usecase.dart';
import '../../domain/usecases/remove_song_usecase.dart';
import 'library_action_event.dart';
import 'library_action_state.dart';

class LibraryActionBloc extends Bloc<LibraryActionEvent, LibraryActionState> {
  final AddSongToPlaylistUseCase _addSongToPlaylistUseCase;
  final DeletePlaylistUseCase _deletePlaylistUseCase;
  final RemoveSongFromPlaylistUseCase _removeSongFromPlaylistUseCase;

  LibraryActionBloc(
    this._addSongToPlaylistUseCase, 
    this._deletePlaylistUseCase,
    this._removeSongFromPlaylistUseCase
  ) : super(LibraryActionInitial()) {
    on<AddSongEvent>((event, emit) async {
      emit(LibraryActionLoading());

      final result = await _addSongToPlaylistUseCase(event.playlistId, event.songId);

      result.fold(
        (failure) => emit(LibraryActionFailure(failure)),
        (_) => emit(LibraryActionSuccess('Canción añadida a la playlist exitosamente')),
      );
    });

    on<DeletePlaylistEvent>((event, emit) async {
      emit(LibraryActionLoading());

      final result = await _deletePlaylistUseCase(event.playlistId);

      result.fold(
        (failure) => emit(LibraryActionFailure(failure)),
        (_) => emit(LibraryActionSuccess('Playlist eliminada exitosamente')),
      );
    });

    on<RemoveSongEvent>((event, emit) async {
      emit(LibraryActionLoading());

      final result = await _removeSongFromPlaylistUseCase(event.playlistId, event.songId);

      result.fold(
        (failure) => emit(LibraryActionFailure(failure)),
        (_) => emit(LibraryActionSuccess('Canción removida exitosamente')),
      );
    });
  }
}
