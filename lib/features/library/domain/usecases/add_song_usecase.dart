import 'package:dartz/dartz.dart';
import '../repository/library_repository.dart';

class AddSongToPlaylistUseCase {
  final LibraryRepository repository;

  AddSongToPlaylistUseCase(this.repository);

  Future<Either<String, void>> call(String playlistId, String songId) async {
    return repository.addSongToPlaylist(playlistId, songId);
  }
}
