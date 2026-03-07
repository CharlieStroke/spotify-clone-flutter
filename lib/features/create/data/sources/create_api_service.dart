import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../home/data/models/playlist_model.dart'; // Reutilizaremos este modelo para la respuesta

abstract class CreateApiService {
  Future<PlaylistModel> createPlaylist(String name, String description);
}

class CreateApiServiceImpl implements CreateApiService {
  final ApiClient _apiClient;

  CreateApiServiceImpl(this._apiClient);

  @override
  Future<PlaylistModel> createPlaylist(String name, String description) async {
    try {
      final response = await _apiClient.dio.post(
        '/playlists/create',
        data: {
          'name': name,
          'description': description,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        return PlaylistModel.fromJson(response.data['playlist'] as Map<String, dynamic>);
      }
      
      throw Exception('Respuesta inesperada del servidor');
    } on DioException catch (e) {
      String msg = e.message ?? 'Error creating playlist';
      if (e.response?.data is Map) {
        msg = e.response?.data['message'] ?? msg;
      }
      throw Exception('Error $msg');
    } catch (e) {
      throw Exception('Error interno create playlist: $e');
    }
  }
}
