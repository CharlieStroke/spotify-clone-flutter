import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_songs_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final SongUseCase _songsUseCase;

  HomeBloc({
    required SongUseCase getSongsUseCase,
  }) : _songsUseCase = getSongsUseCase,
        super(HomeLoading()) {
    
    on<GetSongsEvent>((event, emit) async {
      emit(HomeLoading());
      
      final result = await _songsUseCase();
      
      result.fold(
        (error) => emit(HomeFailure(errorMessage: error)),
        (songs) => emit(HomeLoaded(songs: songs)),
      );
    });
  }
}