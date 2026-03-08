import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_songs_usecase.dart';
import 'detail_event.dart';
import 'detail_state.dart';

class PlaylistDetailBloc extends Bloc<PlaylistDetailEvent, PlaylistDetailState> {
  final GetSongsUseCase _getSongsUseCase;

  PlaylistDetailBloc(this._getSongsUseCase) : super(PlaylistDetailInitial()) {
    on<LoadPlaylistDetailEvent>((event, emit) async {
      emit(PlaylistDetailLoading());

      final result = await _getSongsUseCase(event.id, event.type);

      result.fold(
        (failure) => emit(PlaylistDetailFailure(failure)),
        (songs) => emit(PlaylistDetailLoaded(songs: songs)),
      );
    });
  }
}
