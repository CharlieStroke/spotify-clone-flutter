import 'package:dartz/dartz.dart';
import '../repository/artist_repository.dart';

class FollowArtistUseCase {
  final ArtistRepository _repository;
  FollowArtistUseCase(this._repository);

  Future<Either<String, Unit>> call(int artistId) {
    return _repository.followArtist(artistId);
  }
}
