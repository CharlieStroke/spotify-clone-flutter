import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../home/data/models/playlist_model.dart'; // Reutilizaremos este modelo para la respuesta

abstract class CreateApiService {
  Future<PlaylistModel> createPlaylist(String name, String description, File? image);
}

class CreateApiServiceImpl implements CreateApiService {
  final ApiClient _apiClient;

  CreateApiServiceImpl(this._apiClient);

  @override
  Future<PlaylistModel> createPlaylist(String name, String description, File? image) async {
    try {
      dynamic data;
      
      if (image != null) {
        data = FormData.fromMap({
          'name': name,
          'description': description,
          'cover_image': MultipartFile.fromBytes(
            await image.readAsBytes(),
            filename: image.path.split(RegExp(r'[\\/]')).last,
          ),
        });
      } else {
        data = {
          'name': name,
          'description': description,
        };
      }

      final response = await _apiClient.dio.post(
        '/playlists/create',
        data: data,
        options: Options(
          headers: image != null ? {'Content-Type': 'multipart/form-data'} : null,
        ),
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
