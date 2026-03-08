import 'package:dartz/dartz.dart';
import '../repository/library_repository.dart';

class RemoveSongFromPlaylistUseCase {
  final LibraryRepository repository;

  RemoveSongFromPlaylistUseCase(this.repository);

  Future<Either<String, void>> call(String playlistId, String songId) {
    return repository.removeSongFromPlaylist(playlistId, songId);
  }
}
