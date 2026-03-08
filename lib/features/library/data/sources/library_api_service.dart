import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../home/data/models/album_model.dart';
import '../../../home/data/models/playlist_model.dart';

abstract class LibraryApiService {
  Future<Map<String, List<dynamic>>> getUserLibrary();
  Future<void> addSongToPlaylist(String playlistId, String songId);
}

class LibraryApiServiceImpl implements LibraryApiService {
  final ApiClient _apiClient;

  LibraryApiServiceImpl(this._apiClient);

  @override
  Future<Map<String, List<dynamic>>> getUserLibrary() async {
    try {
      // Hacemos ambas peticiones en paralelo para optimizar la carga
      final responses = await Future.wait([
        _apiClient.dio.get('/playlists'), // getUserPlaylists
        _apiClient.dio.get('/albums/all'), // getAllAlbums (los consideraremos "guardados")
      ]);

      final playlistsRes = responses[0];
      final albumsRes = responses[1];

      final List<dynamic> rawPlaylists = (playlistsRes.data['success'] == true && playlistsRes.data['playlists'] != null)
          ? playlistsRes.data['playlists']
          : [];

      final List<dynamic> rawAlbums = (albumsRes.data['success'] == true && albumsRes.data['albums'] != null)
          ? albumsRes.data['albums']
          : [];

      final playlists = rawPlaylists.map((e) => PlaylistModel.fromJson(e as Map<String, dynamic>)).toList();
      final albums = rawAlbums.map((e) => AlbumModel.fromJson(e as Map<String, dynamic>)).toList();

      return {
        'playlists': playlists,
        'albums': albums,
      };
      
    } on DioException catch (e) {
      String msg = 'Error loading library';
      if (e.response?.data is Map) {
        msg = e.response?.data['message'] ?? msg;
      }
      throw Exception(msg);
    } catch (e) {
      throw Exception('Library unexpected error: $e');
    }
  }

  @override
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    try {
      final response = await _apiClient.dio.post(
        '/playlists/$playlistId/add/$songId',
      );

      if (response.data == null || response.data['success'] != true) {
        throw Exception(response.data?['message'] ?? 'Error desconocido al añadir canción');
      }
    } on DioException catch (e) {
      String msg = 'No se pudo añadir la canción';
      if (e.response?.data is Map) {
        msg = e.response?.data['message'] ?? msg;
      }
      throw Exception(msg);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
