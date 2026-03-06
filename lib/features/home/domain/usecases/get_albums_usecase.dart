import 'package:dartz/dartz.dart';
import '../../data/repository/home_repository.dart';
import '../entities/album_entity.dart';

class GetAlbumsUseCase {
  final HomeRepository repository;

  GetAlbumsUseCase(this.repository);

  Future<Either<String, List<AlbumEntity>>> call() {
    return repository.getAlbums();
  }
}
