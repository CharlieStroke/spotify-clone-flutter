import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../home/data/models/song_model.dart';

abstract class PlaylistDetailApiService {
  Future<List<SongModel>> getSongsFromPlaylist(String playlistId);
  Future<List<SongModel>> getSongsFromAlbum(String albumId);
}

class PlaylistDetailApiServiceImpl implements PlaylistDetailApiService {
  final ApiClient _apiClient;

  PlaylistDetailApiServiceImpl(this._apiClient);

  @override
  Future<List<SongModel>> getSongsFromPlaylist(String playlistId) async {
    try {
      final response = await _apiClient.dio.get('/playlists/$playlistId/songs');
      
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> rawSongs = response.data['songs'] ?? [];
        return rawSongs.map((e) => SongModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Error loading playlist songs: ${e.message}');
    }
  }

  @override
  Future<List<SongModel>> getSongsFromAlbum(String albumId) async {
    try {
      final response = await _apiClient.dio.get('/albums/$albumId/songs');
      
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> rawSongs = response.data['songs'] ?? [];
        return rawSongs.map((e) => SongModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Error loading album songs: ${e.message}');
    }
  }
}
