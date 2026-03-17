import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'search_event.dart';
import 'search_state.dart';
import '../../domain/usecases/search_usecase.dart';
import '../../data/sources/search_local_data_source.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchUseCase _searchUseCase;
  final SearchLocalDataSource _localDataSource;

  SearchBloc({
    required SearchUseCase searchUseCase,
    required SearchLocalDataSource localDataSource,
  })  : _searchUseCase = searchUseCase,
        _localDataSource = localDataSource,
        super(SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged, transformer: _debounceTransformer());
    on<LoadRecentSearches>(_onLoadRecentSearches);
    on<ClearRecentSearches>(_onClearRecentSearches);
    on<RemoveRecentSearch>(_onRemoveRecentSearch);
  }

  EventTransformer<E> _debounceTransformer<E>() {
    return (events, mapper) => events.debounceTime(const Duration(milliseconds: 500)).switchMap(mapper);
  }

  Future<void> _onSearchQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) async {
    final query = event.query.trim();
    
    if (query.isEmpty) {
      add(LoadRecentSearches());
      return;
    }

    emit(SearchLoading());

    final result = await _searchUseCase(query);
    
    result.fold(
      (failure) => emit(SearchFailure(failure)),
      (data) {
        if (data['songs']!.isNotEmpty || data['albums']!.isNotEmpty || data['playlists']!.isNotEmpty) {
           _localDataSource.cacheRecentSearch(query);
        }
        emit(SearchLoaded(
          songs: data['songs']!,
          albums: data['albums']!,
          playlists: data['playlists']!,
        ));
      },
    );
  }

  Future<void> _onLoadRecentSearches(LoadRecentSearches event, Emitter<SearchState> emit) async {
    final searches = await _localDataSource.getRecentSearches();
    emit(SearchRecentLoaded(searches));
  }

  Future<void> _onClearRecentSearches(ClearRecentSearches event, Emitter<SearchState> emit) async {
    await _localDataSource.clearRecentSearches();
    emit(SearchRecentLoaded(const []));
  }

  Future<void> _onRemoveRecentSearch(RemoveRecentSearch event, Emitter<SearchState> emit) async {
    await _localDataSource.removeRecentSearch(event.query);
    final searches = await _localDataSource.getRecentSearches();
    emit(SearchRecentLoaded(searches));
  }
}
