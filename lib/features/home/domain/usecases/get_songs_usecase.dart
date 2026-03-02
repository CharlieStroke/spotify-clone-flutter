import 'package:dartz/dartz.dart';
import '../entities/song_entity.dart';
import '../../data/repository/song_repository.dart';

class SongUseCase {
  final SongRepository repository;

  SongUseCase(this.repository);

  Future<Either<String, List<SongEntity>>> call() {
    return repository.getSongs();
  }
}