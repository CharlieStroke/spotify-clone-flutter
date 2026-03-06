import 'package:dartz/dartz.dart';
import '../../data/repository/home_repository.dart';
import '../entities/playlist_entity.dart';

class GetPlaylistsUseCase {
  final HomeRepository repository;

  GetPlaylistsUseCase(this.repository);

  Future<Either<String, List<PlaylistEntity>>> call() {
    return repository.getPlaylists();
  }
}
