import 'package:dartz/dartz.dart';
import '../repository/artist_repository.dart';

class UnfollowArtistUseCase {
  final ArtistRepository _repository;
  UnfollowArtistUseCase(this._repository);

  Future<Either<String, Unit>> call(int artistId) {
    return _repository.unfollowArtist(artistId);
  }
}
