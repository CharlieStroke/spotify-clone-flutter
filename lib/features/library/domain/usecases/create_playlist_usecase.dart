import 'package:dartz/dartz.dart';
import '../repository/library_repository.dart';

class CreatePlaylistUseCase {
  final LibraryRepository repository;

  CreatePlaylistUseCase(this.repository);

  Future<Either<String, void>> call(String name, String description) {
    return repository.createPlaylist(name, description);
  }
}
