import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../home/data/models/song_model.dart';

abstract class FavoritesApiService {
  Future<List<SongModel>> getFavorites();
  Future<void> addFavorite(String songId);
  Future<void> removeFavorite(String songId);
  Future<bool> isFavorite(String songId);
}

class FavoritesApiServiceImpl implements FavoritesApiService {
  final ApiClient _apiClient;
  FavoritesApiServiceImpl(this._apiClient);

  @override
  Future<List<SongModel>> getFavorites() async {
    try {
      final response = await _apiClient.dio.get('/favorites/');
      if (response.data != null && response.data['favorites'] is List) {
        final List<dynamic> list = response.data['favorites'];
        return list.map((e) => SongModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Error cargando favoritos: ${e.message}');
    }
  }

  @override
  Future<void> addFavorite(String songId) async {
    try {
      await _apiClient.dio.post('/favorites/add/$songId');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      throw Exception(msg);
    }
  }

  @override
  Future<void> removeFavorite(String songId) async {
    try {
      await _apiClient.dio.delete('/favorites/remove/$songId');
    } on DioException catch (e) {
      throw Exception('Error eliminando favorito: ${e.message}');
    }
  }

  @override
  Future<bool> isFavorite(String songId) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((s) => s.id == songId);
    } catch (_) {
      return false;
    }
  }
}
