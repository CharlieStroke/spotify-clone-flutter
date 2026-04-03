import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/favorites_usecases.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritesUseCase _getFavorites;
  final AddFavoriteUseCase _addFavorite;
  final RemoveFavoriteUseCase _removeFavorite;
  final GetCachedFavoritesUseCase _getCachedFavorites;
  final AddCachedFavoriteUseCase _addCachedFavorite;

  FavoritesBloc(
    this._getFavorites,
    this._addFavorite,
    this._removeFavorite,
    this._getCachedFavorites,
    this._addCachedFavorite,
  ) : super(FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoad);
    on<AddFavoriteEvent>(_onAdd);
    on<RemoveFavoriteEvent>(_onRemove);
    on<ResetFavoritesEvent>((_, emit) => emit(FavoritesInitial()));
  }

  Future<void> _onLoad(LoadFavoritesEvent event, Emitter<FavoritesState> emit) async {
    // 1. Mostrar caché inmediatamente (offline-first)
    final cached = await _getCachedFavorites();
    if (cached.isNotEmpty) {
      emit(FavoritesLoaded(songs: cached));
    } else {
      emit(FavoritesLoading());
    }

    // 2. Actualizar con datos remotos
    final result = await _getFavorites();
    result.fold(
      (error) {
        // Si ya hay caché visible, no mostrar error
        if (state is! FavoritesLoaded) emit(FavoritesError(error));
      },
      (songs) => emit(FavoritesLoaded(songs: songs)),
    );
  }

  Future<void> _onAdd(AddFavoriteEvent event, Emitter<FavoritesState> emit) async {
    // 1. Optimistic update en UI
    if (state is FavoritesLoaded && event.song != null) {
      final current = (state as FavoritesLoaded).songs;
      if (!current.any((s) => s.id == event.songId)) {
        emit(FavoritesLoaded(songs: [event.song!, ...current]));
      }
    } else if (state is FavoritesInitial && event.song != null) {
      emit(FavoritesLoaded(songs: [event.song!]));
    }

    // 2. Llamar API
    final result = await _addFavorite(event.songId);
    result.fold(
      (error) {
        // Revertir UI y Hive
        if (state is FavoritesLoaded) {
          final reverted = (state as FavoritesLoaded).songs
              .where((s) => s.id != event.songId)
              .toList();
          emit(FavoritesLoaded(songs: reverted));
        }
        emit(FavoritesError(error));
      },
      (_) async {
        // 3. Persistir en caché local
        if (event.song != null) {
          await _addCachedFavorite(event.song!);
        } else {
          add(LoadFavoritesEvent());
        }
      },
    );
  }

  Future<void> _onRemove(RemoveFavoriteEvent event, Emitter<FavoritesState> emit) async {
    // 1. Optimistic update
    if (state is FavoritesLoaded) {
      final current = (state as FavoritesLoaded).songs;
      final snapshot = List.from(current);
      emit(FavoritesLoaded(songs: current.where((s) => s.id != event.songId).toList()));

      // 2. API + caché local (removeFavorite en repo ya actualiza Hive)
      final result = await _removeFavorite(event.songId);
      result.fold(
        (error) {
          emit(FavoritesLoaded(songs: snapshot.cast()));
          emit(FavoritesError(error));
        },
        (_) {},
      );
    } else {
      await _removeFavorite(event.songId);
      add(LoadFavoritesEvent());
    }
  }
}
