import 'package:dartz/dartz.dart';
import '../repository/artist_repository.dart';
import '../../../home/domain/entities/song_entity.dart';

class GetPublicArtistTopSongsUseCase {
  final ArtistRepository _repository;
  GetPublicArtistTopSongsUseCase(this._repository);

  Future<Either<String, List<SongEntity>>> call(int artistId) {
    return _repository.getPublicArtistTopSongs(artistId);
  }
}
