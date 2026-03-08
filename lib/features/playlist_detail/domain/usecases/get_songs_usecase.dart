import 'package:dartz/dartz.dart';
import '../repository/detail_repository.dart';
import '../../../home/domain/entities/song_entity.dart';

class GetSongsUseCase {
  final PlaylistDetailRepository repository;

  GetSongsUseCase(this.repository);

  // type = 'playlist' or 'album'
  Future<Either<String, List<SongEntity>>> call(String id, String type) async {
    if (type == 'album') {
      return repository.getSongsFromAlbum(id);
    } else {
      return repository.getSongsFromPlaylist(id);
    }
  }
}
