import 'package:dartz/dartz.dart';
import '../entities/artist_stats_entity.dart';
import '../repository/artist_repository.dart';

class GetArtistStatsUseCase {
  final ArtistRepository repository;

  GetArtistStatsUseCase(this.repository);

  Future<Either<String, ArtistStatsEntity>> call() {
    return repository.getArtistStats();
  }
}
