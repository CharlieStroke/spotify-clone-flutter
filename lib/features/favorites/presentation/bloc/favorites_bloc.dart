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
    // 1. Optimistic update: añadir inmediatamente al estado local
    if (state is FavoritesLoaded && event.song != null) {
      final current = (state as FavoritesLoaded).songs;
      // Evitar duplicados
      if (!current.any((s) => s.id == event.songId)) {
        emit(FavoritesLoaded(songs: [event.song!, ...current]));
      }
    }

    // 2. Llamar al API en background
    final result = await _addFavorite(event.songId);
    result.fold(
      (error) {
        // 3. Si falla: revertir eliminando la canción que añadimos
        if (state is FavoritesLoaded) {
          final reverted = (state as FavoritesLoaded).songs
              .where((s) => s.id != event.songId)
              .toList();
          emit(FavoritesLoaded(songs: reverted));
        }
        emit(FavoritesError(error));
      },
      (_) {
        // Si no teníamos el objeto song, recargamos desde servidor
        if (event.song == null) {
          add(LoadFavoritesEvent());
        }
      },
    );
  }

  Future<void> _onRemove(RemoveFavoriteEvent event, Emitter<FavoritesState> emit) async {
    // 1. Optimistic update: quitar inmediatamente del estado local
    if (state is FavoritesLoaded) {
      final current = (state as FavoritesLoaded).songs;
      final snapshot = List.from(current); // guardar copia para revertir
      final optimistic = current.where((s) => s.id != event.songId).toList();
      emit(FavoritesLoaded(songs: optimistic));

      // 2. Llamar al API en background
      final result = await _removeFavorite(event.songId);
      result.fold(
        (error) {
          // 3. Si falla: revertir restaurando la canción
          emit(FavoritesLoaded(songs: snapshot.cast()));
          emit(FavoritesError(error));
        },
        (_) {}, // Éxito: estado optimista ya es correcto
      );
    } else {
      // No había estado cargado, llamar API de todas formas
      await _removeFavorite(event.songId);
      add(LoadFavoritesEvent());
    }
  }
}
