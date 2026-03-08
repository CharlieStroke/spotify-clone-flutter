import 'package:dartz/dartz.dart';
import '../repository/library_repository.dart';

class DeletePlaylistUseCase {
  final LibraryRepository repository;

  DeletePlaylistUseCase(this.repository);

  Future<Either<String, void>> call(String playlistId) {
    return repository.deletePlaylist(playlistId);
  }
}
