import '../../../home/data/repository/song_repository.dart';

class IncrementPlayCountUseCase {
  final SongRepository repository;

  IncrementPlayCountUseCase(this.repository);

  Future<void> call(String songId) {
    return repository.incrementPlayCount(songId);
  }
}
