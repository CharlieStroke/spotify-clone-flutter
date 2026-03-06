import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ProfileApiService {
  Future<UserModel> getUserProfile();
}

class ProfileApiServiceImpl implements ProfileApiService {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  ProfileApiServiceImpl({required this.apiClient, required this.sharedPreferences});

  @override
  Future<UserModel> getUserProfile() async {
    try {
      final token = sharedPreferences.getString('auth_token');
      if (token == null) throw Exception('No token found');

      final response = await apiClient.dio.get(
        '/auth',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error de conexión al servidor');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
