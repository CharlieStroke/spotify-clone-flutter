import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'search_event.dart';
import 'search_state.dart';
import '../../domain/usecases/search_usecase.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchUseCase _searchUseCase;

  SearchBloc(this._searchUseCase) : super(SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged, transformer: _debounceTransformer());
  }

  EventTransformer<E> _debounceTransformer<E>() {
    return (events, mapper) => events.debounceTime(const Duration(milliseconds: 500)).switchMap(mapper);
  }

  Future<void> _onSearchQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) async {
    final query = event.query.trim();
    
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    final result = await _searchUseCase(query);
    
    result.fold(
      (failure) => emit(SearchFailure(failure)),
      (data) => emit(SearchLoaded(
        songs: data['songs']!,
        albums: data['albums']!,
        playlists: data['playlists']!,
      )),
    );
  }
}
