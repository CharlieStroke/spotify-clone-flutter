import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../home/data/models/album_model.dart';
import '../../../home/data/models/playlist_model.dart';

abstract class LibraryApiService {
  Future<Map<String, List<dynamic>>> getUserLibrary();
  Future<void> createPlaylist(String name, String description);
  Future<void> deletePlaylist(String playlistId);
  Future<void> addSongToPlaylist(String playlistId, String songId);
  Future<void> removeSongFromPlaylist(String playlistId, String songId);
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

  @override
  Future<void> createPlaylist(String name, String description) async {
    try {
      final response = await _apiClient.dio.post(
        '/playlists/create',
        data: {
          'name': name,
          'description': description,
        },
      );

      if (response.data == null || response.data['success'] != true) {
        throw Exception(response.data?['message'] ?? 'Error al crear playlist');
      }
    } on DioException catch (e) {
      String msg = 'No se pudo crear la playlist';
      if (e.response?.data is Map) {
        msg = e.response?.data['message'] ?? msg;
      }
      throw Exception(msg);
    } catch (e) {
      throw Exception('Error inesperado al crear: $e');
    }
  }

  @override
  Future<void> deletePlaylist(String playlistId) async {
    try {
      final response = await _apiClient.dio.delete('/playlists/$playlistId');

      if (response.data == null || response.data['success'] != true) {
        throw Exception(response.data?['message'] ?? 'Error al eliminar playlist');
      }
    } on DioException catch (e) {
      String msg = 'No se pudo eliminar la playlist';
      if (e.response?.data is Map) {
        msg = e.response?.data['message'] ?? msg;
      }
      throw Exception(msg);
    } catch (e) {
      throw Exception('Error inesperado al eliminar: $e');
    }
  }

  @override
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      final response = await _apiClient.dio.delete(
        '/playlists/$playlistId/remove/$songId',
      );

      if (response.data == null || response.data['success'] != true) {
        throw Exception(response.data?['message'] ?? 'Error desconocido al remover canción');
      }
    } on DioException catch (e) {
      String msg = 'No se pudo remover la canción';
      if (e.response?.data is Map) {
        msg = e.response?.data['message'] ?? msg;
      }
      throw Exception(msg);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
