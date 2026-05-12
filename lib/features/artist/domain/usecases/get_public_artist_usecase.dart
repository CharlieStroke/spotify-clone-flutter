import 'package:dartz/dartz.dart';
import '../entities/artist_entity.dart';
import '../repository/artist_repository.dart';

class GetPublicArtistUseCase {
  final ArtistRepository _repository;
  GetPublicArtistUseCase(this._repository);

  Future<Either<String, ArtistEntity>> call(int artistId) {
    return _repository.getPublicArtistProfile(artistId);
  }
}
