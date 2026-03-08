import 'package:dartz/dartz.dart';
import '../../../home/domain/entities/song_entity.dart';
import '../repositories/favorites_repository.dart';

class GetFavoritesUseCase {
  final FavoritesRepository _repo;
  GetFavoritesUseCase(this._repo);

  Future<Either<String, List<SongEntity>>> call() async {
    try {
      final songs = await _repo.getFavorites();
      return Right(songs);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

class AddFavoriteUseCase {
  final FavoritesRepository _repo;
  AddFavoriteUseCase(this._repo);

  Future<Either<String, void>> call(String songId) async {
    try {
      await _repo.addFavorite(songId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

class RemoveFavoriteUseCase {
  final FavoritesRepository _repo;
  RemoveFavoriteUseCase(this._repo);

  Future<Either<String, void>> call(String songId) async {
    try {
      await _repo.removeFavorite(songId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
