import 'package:dartz/dartz.dart';
import '../sources/song_api_services.dart';
import 'song_repository.dart';
import '../../domain/entities/song_entity.dart';

class SongRepositoryImpl implements SongRepository {
  final SongApiService songApiService;

  SongRepositoryImpl(this.songApiService);

  @override
  Future<Either<String, List<SongEntity>>> getSongs() async {
    try {
      final songs = await songApiService.getSongs();
      return Right(songs);
    } catch (e) {
      return Left(e.toString());
    }
  }
}