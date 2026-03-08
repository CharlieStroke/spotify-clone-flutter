import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/favorites_usecases.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritesUseCase _getFavorites;
  final AddFavoriteUseCase _addFavorite;
  final RemoveFavoriteUseCase _removeFavorite;

  FavoritesBloc(this._getFavorites, this._addFavorite, this._removeFavorite)
      : super(FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoad);
    on<AddFavoriteEvent>(_onAdd);
    on<RemoveFavoriteEvent>(_onRemove);
    on<ResetFavoritesEvent>((_, emit) => emit(FavoritesInitial()));
  }

  Future<void> _onLoad(LoadFavoritesEvent event, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading());
    final result = await _getFavorites();
    result.fold(
      (error) => emit(FavoritesError(error)),
      (songs) => emit(FavoritesLoaded(songs: songs)),
    );
  }

  Future<void> _onAdd(AddFavoriteEvent event, Emitter<FavoritesState> emit) async {
    final result = await _addFavorite(event.songId);
    result.fold(
      (error) => emit(FavoritesError(error)),
      (_) async {
        // Reload after add
        final reloaded = await _getFavorites();
        reloaded.fold(
          (e) => emit(FavoritesError(e)),
          (songs) => emit(FavoritesLoaded(songs: songs)),
        );
      },
    );
  }

  Future<void> _onRemove(RemoveFavoriteEvent event, Emitter<FavoritesState> emit) async {
    final result = await _removeFavorite(event.songId);
    result.fold(
      (error) => emit(FavoritesError(error)),
      (_) async {
        final reloaded = await _getFavorites();
        reloaded.fold(
          (e) => emit(FavoritesError(e)),
          (songs) => emit(FavoritesLoaded(songs: songs)),
        );
      },
    );
  }
}
