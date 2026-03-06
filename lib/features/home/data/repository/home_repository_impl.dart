import 'package:dartz/dartz.dart';
import 'home_repository.dart';
import '../../domain/entities/album_entity.dart';
import '../../domain/entities/playlist_entity.dart';
import '../sources/home_api_service.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeApiService _apiService;

  HomeRepositoryImpl(this._apiService);

  @override
  Future<Either<String, List<AlbumEntity>>> getAlbums() async {
    try {
      final albums = await _apiService.getAlbums();
      return Right(albums);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<PlaylistEntity>>> getPlaylists() async {
    try {
      final playlists = await _apiService.getPlaylists();
      return Right(playlists);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
