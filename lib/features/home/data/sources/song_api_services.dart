import 'package:dio/dio.dart'; // Ahora sí lo usaremos para el tipado de 'Response'
import '../../../../core/network/api_client.dart';
import '../models/song_model.dart';

abstract class SongApiService {
  Future<List<SongModel>> getSongs();
}

class SongApiServiceImpl implements SongApiService {
  final ApiClient _apiClient;

  SongApiServiceImpl(this._apiClient);

  @override
  Future<List<SongModel>> getSongs() async {
    try {
      // 1. Asegúrate de que la ruta coincida con tu backend (/api/songs/all)
      final Response response = await _apiClient.dio.get('/songs/all');
      
      // 2. Verificamos que 'songs' exista y sea una lista
      if (response.data != null && response.data['songs'] is List) {
        final List<dynamic> songsList = response.data['songs'];

        // 3. Convertimos explícitamente cada elemento a Map<String, dynamic>
        return songsList.map((songJson) {
          return SongModel.fromJson(songJson as Map<String, dynamic>);
        }).toList();
      }
      
      return [];
    } on DioException catch (e) {
      // Captura errores específicos de Dio (como 404 o 500)
      throw Exception(e.response?.data['message'] ?? 'Error de red al cargar canciones');
    } catch (e) {
      // Captura cualquier otro error (como errores de mapeo)
      throw Exception('Error inesperado: $e');
    }
  }
}