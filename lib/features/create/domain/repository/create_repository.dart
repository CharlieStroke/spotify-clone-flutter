import 'package:dartz/dartz.dart';
import '../../../home/domain/entities/playlist_entity.dart';

abstract class CreateRepository {
  Future<Either<String, PlaylistEntity>> createPlaylist(String name, String description);
}
