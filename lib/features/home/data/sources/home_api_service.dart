import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/album_model.dart';
import '../models/playlist_model.dart';

abstract class HomeApiService {
  Future<List<AlbumModel>> getAlbums();
  Future<List<PlaylistModel>> getPlaylists();
}

class HomeApiServiceImpl implements HomeApiService {
  final ApiClient _apiClient;

  HomeApiServiceImpl(this._apiClient);

  @override
  Future<List<AlbumModel>> getAlbums() async {
    try {
      final Response response = await _apiClient.dio.get('/albums/all');
      
      if (response.data != null && response.data['albums'] is List) {
        final List<dynamic> dataList = response.data['albums'];
        return dataList.map((json) => AlbumModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      String msg = e.message ?? 'Error fetching albums';
      if (e.response?.data is Map) {
        msg = e.response?.data['message'] ?? msg;
      }
      throw Exception('Error fetch albums: $msg (Code: ${e.response?.statusCode})');
    } catch (e) {
      throw Exception('Error mapping albums: $e');
    }
  }

  @override
  Future<List<PlaylistModel>> getPlaylists() async {
    try {
      final Response response = await _apiClient.dio.get('/playlists');
      
      // Si el backend devuelve success: false (ej: "No hay playlists para el usuario")
      // pero devuelve un arreglo de playlists vacío, debemos atraparlo y devolver []
      // sin lanzar una excepción.
      if (response.data != null) {
        if (response.data['success'] == false && response.data['playlists'] != null) {
           return [];
        }

        if (response.data['playlists'] is List) {
          final List<dynamic> dataList = response.data['playlists'];
          return dataList.map((json) => PlaylistModel.fromJson(json as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      String msg = e.message ?? 'Error fetching playlists';
      if (e.response?.data is Map) {
        msg = e.response?.data['message'] ?? msg;
      }
      throw Exception('Error fetch playlists: $msg (Code: ${e.response?.statusCode})');
    } catch (e) {
      throw Exception('Error interno mapping playlists: $e');
    }
  }
}
