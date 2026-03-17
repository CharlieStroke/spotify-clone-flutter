import '../../data/repository/home_repository.dart';

class GetCachedHomeUseCase {
  final HomeRepository repository;

  GetCachedHomeUseCase(this.repository);

  Future<Map<String, List<dynamic>>> call() async {
    final albums = await repository.getCachedAlbums();
    final playlists = await repository.getCachedPlaylists();
    return {
      'albums': albums,
      'playlists': playlists,
    };
  }
}
