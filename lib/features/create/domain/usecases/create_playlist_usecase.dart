import 'package:dartz/dartz.dart';
import '../repository/create_repository.dart';
import '../../../home/domain/entities/playlist_entity.dart';

class CreatePlaylistUseCase {
  final CreateRepository repository;

  CreatePlaylistUseCase(this.repository);

  Future<Either<String, PlaylistEntity>> call(String name, String description) async {
    return repository.createPlaylist(name, description);
  }
}
