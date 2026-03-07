import 'package:dartz/dartz.dart';
import '../sources/create_api_service.dart';
import '../../domain/repository/create_repository.dart';
import '../../../home/domain/entities/playlist_entity.dart';

class CreateRepositoryImpl implements CreateRepository {
  final CreateApiService _apiService;

  CreateRepositoryImpl(this._apiService);

  @override
  Future<Either<String, PlaylistEntity>> createPlaylist(String name, String description) async {
    try {
      final playlistModel = await _apiService.createPlaylist(name, description);
      return Right(playlistModel);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
