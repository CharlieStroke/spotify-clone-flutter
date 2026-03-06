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
      throw Exception(e.response?.data['message'] ?? 'Error fetching albums');
    }
  }

  @override
  Future<List<PlaylistModel>> getPlaylists() async {
    try {
      final Response response = await _apiClient.dio.get('/playlists');
      
      if (response.data != null && response.data['playlists'] is List) {
        final List<dynamic> dataList = response.data['playlists'];
        return dataList.map((json) => PlaylistModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching playlists');
    }
  }
}
