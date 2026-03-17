import 'package:dartz/dartz.dart';

abstract class LibraryRepository {
  Future<Either<String, Map<String, List<dynamic>>>> getUserLibrary();
  Future<Map<String, List<dynamic>>> getCachedLibrary();
  Future<Either<String, void>> createPlaylist(String name, String description);
  Future<Either<String, void>> deletePlaylist(String playlistId);
  Future<Either<String, void>> addSongToPlaylist(String playlistId, String songId);
  Future<Either<String, void>> removeSongFromPlaylist(String playlistId, String songId);
}
