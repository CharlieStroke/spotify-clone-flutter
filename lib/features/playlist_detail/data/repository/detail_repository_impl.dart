import 'package:dartz/dartz.dart';
import '../sources/detail_api_service.dart';
import '../../domain/repository/detail_repository.dart';
import '../../../home/domain/entities/song_entity.dart';

class PlaylistDetailRepositoryImpl implements PlaylistDetailRepository {
  final PlaylistDetailApiService _apiService;

  PlaylistDetailRepositoryImpl(this._apiService);

  @override
  Future<Either<String, List<SongEntity>>> getSongsFromPlaylist(String playlistId) async {
    try {
      final songs = await _apiService.getSongsFromPlaylist(playlistId);
      return Right(songs);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<SongEntity>>> getSongsFromAlbum(String albumId) async {
    try {
      final songs = await _apiService.getSongsFromAlbum(albumId);
      return Right(songs);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<SongEntity>>> getSongsFromFavorites() async {
    try {
      final songs = await _apiService.getSongsFromFavorites();
      return Right(songs);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
