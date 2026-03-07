import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../home/data/models/album_model.dart';
import '../../../home/data/models/playlist_model.dart';
import '../../../home/data/models/song_model.dart';

abstract class SearchApiService {
  Future<Map<String, List<dynamic>>> search(String query);
}

class SearchApiServiceImpl implements SearchApiService {
  final ApiClient _apiClient;

  SearchApiServiceImpl(this._apiClient);

  @override
  Future<Map<String, List<dynamic>>> search(String query) async {
    try {
      final response = await _apiClient.dio.get('/search?q=$query');
      
      if (response.data != null && response.data['success'] == true) {
        
        final List<dynamic> rawSongs = response.data['songs'] ?? [];
        final List<dynamic> rawAlbums = response.data['albums'] ?? [];
        final List<dynamic> rawPlaylists = response.data['playlists'] ?? [];

        final songs = rawSongs.map((e) => SongModel.fromJson(e as Map<String, dynamic>)).toList();
        final albums = rawAlbums.map((e) => AlbumModel.fromJson(e as Map<String, dynamic>)).toList();
        final playlists = rawPlaylists.map((e) => PlaylistModel.fromJson(e as Map<String, dynamic>)).toList();

        return {
          'songs': songs,
          'albums': albums,
          'playlists': playlists,
        };
      }
      
      return {'songs': [], 'albums': [], 'playlists': []};
    } on DioException catch (e) {
      String msg = e.message ?? 'Error in search';
      if (e.response?.data is Map) {
        msg = e.response?.data['message'] ?? msg;
      }
      throw Exception('Error $msg');
    } catch (e) {
      throw Exception('Search unexpected error: $e');
    }
  }
}
