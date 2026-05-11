import 'package:dartz/dartz.dart';
import '../../domain/entities/song_entity.dart';

abstract class SongRepository {
  Future<Either<String, List<SongEntity>>> getSongs();
  Future<void> incrementPlayCount(String songId);
}