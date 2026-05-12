import 'package:dartz/dartz.dart';
import '../repository/artist_repository.dart';
import '../../../home/domain/entities/album_entity.dart';

class GetPublicArtistAlbumsUseCase {
  final ArtistRepository _repository;
  GetPublicArtistAlbumsUseCase(this._repository);

  Future<Either<String, List<AlbumEntity>>> call(int artistId) {
    return _repository.getPublicArtistAlbums(artistId);
  }
}
