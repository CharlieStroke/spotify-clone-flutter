import 'package:dartz/dartz.dart';
import '../../domain/entities/album_entity.dart';
import '../../domain/entities/playlist_entity.dart';

abstract class HomeRepository {
  Future<Either<String, List<AlbumEntity>>> getAlbums();
  Future<Either<String, List<PlaylistEntity>>> getPlaylists();
}
