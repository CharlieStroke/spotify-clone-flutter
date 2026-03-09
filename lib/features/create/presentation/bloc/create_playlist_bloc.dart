import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_playlist_usecase.dart';
import 'create_playlist_event.dart';
import 'create_playlist_state.dart';

class CreatePlaylistBloc extends Bloc<CreatePlaylistEvent, CreatePlaylistState> {
  final CreatePlaylistUseCase _createPlaylistUseCase;

  CreatePlaylistBloc(this._createPlaylistUseCase) : super(CreatePlaylistInitial()) {
    on<SubmitPlaylistEvent>((event, emit) async {
      emit(CreatePlaylistLoading());

      final result = await _createPlaylistUseCase(event.name, event.description, event.image);

      result.fold(
        (failure) => emit(CreatePlaylistFailure(failure)),
        (playlist) => emit(CreatePlaylistSuccess(playlist)),
      );
    });
  }
}
