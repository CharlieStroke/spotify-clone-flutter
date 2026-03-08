import 'package:dartz/dartz.dart';
import '../../../home/domain/entities/song_entity.dart';

abstract class PlaylistDetailRepository {
  Future<Either<String, List<SongEntity>>> getSongsFromPlaylist(String playlistId);
  Future<Either<String, List<SongEntity>>> getSongsFromAlbum(String albumId);
}
