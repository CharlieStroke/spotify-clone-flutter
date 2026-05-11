import 'package:dartz/dartz.dart';
import '../sources/song_api_services.dart';
import '../sources/home_local_data_source.dart';
import 'song_repository.dart';
import '../../domain/entities/song_entity.dart';

class SongRepositoryImpl implements SongRepository {
  final SongApiService songApiService;
  final HomeLocalDataSource _localDataSource;

  SongRepositoryImpl(this.songApiService, this._localDataSource);

  @override
  Future<void> incrementPlayCount(String songId) async {
    try {
      await songApiService.incrementPlayCount(songId);
    } catch (_) {
      // Fire-and-forget: ignore errors to avoid disrupting playback
    }
  }

  @override
  Future<Either<String, List<SongEntity>>> getSongs() async {
    try {
      final songs = await songApiService.getSongs();
      await _localDataSource.cacheSongs(songs);
      return Right(songs);
    } catch (e) {
      final cached = await _localDataSource.getCachedSongs();
      if (cached.isNotEmpty) return Right(cached);
      return Left(e.toString());
    }
  }
}