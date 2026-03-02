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
      // Usamos 'Response' de la librería Dio para tipar la respuesta
      final Response response = await _apiClient.dio.get('/api/songs/all');
      
      if (response.statusCode == 200) {
        // Mapeamos la lista de JSON a una lista de Modelos
        return (response.data as List)
            .map((song) => SongModel.fromJson(song))
            .toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      // Usamos 'DioException' para capturar errores de red específicos
      throw Exception(e.response?.data['message'] ?? 'Error al cargar canciones');
    }
  }
}