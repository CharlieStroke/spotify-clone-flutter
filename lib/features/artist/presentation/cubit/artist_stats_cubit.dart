import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/artist_stats_entity.dart';
import '../../domain/usecases/get_artist_stats_usecase.dart';

abstract class ArtistStatsState {}

class ArtistStatsInitial extends ArtistStatsState {}

class ArtistStatsLoading extends ArtistStatsState {}

class ArtistStatsLoaded extends ArtistStatsState {
  final ArtistStatsEntity stats;
  ArtistStatsLoaded(this.stats);
}

class ArtistStatsError extends ArtistStatsState {
  final String message;
  ArtistStatsError(this.message);
}

class ArtistStatsCubit extends Cubit<ArtistStatsState> {
  final GetArtistStatsUseCase _getStats;

  ArtistStatsCubit(this._getStats) : super(ArtistStatsInitial());

  Future<void> loadStats() async {
    if (state is! ArtistStatsInitial) return;
    emit(ArtistStatsLoading());
    final result = await _getStats.call();
    result.fold(
      (error) => emit(ArtistStatsError(error)),
      (stats) => emit(ArtistStatsLoaded(stats)),
    );
  }

  void retry() {
    emit(ArtistStatsInitial());
    loadStats();
  }
}
