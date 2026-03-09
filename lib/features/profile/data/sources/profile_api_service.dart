import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ProfileApiService {
  Future<UserModel> getUserProfile();
  Future<UserModel> updateProfile({
    String? username,
    String? oldPassword,
    String? newPassword,
    String? imagePath,
  });
}

class ProfileApiServiceImpl implements ProfileApiService {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  ProfileApiServiceImpl({required this.apiClient, required this.sharedPreferences});

  @override
  Future<UserModel> getUserProfile() async {
    try {
      final token = sharedPreferences.getString('token');
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
  @override
  Future<UserModel> updateProfile({
    String? username,
    String? oldPassword,
    String? newPassword,
    String? imagePath,
  }) async {
    try {
      final token = sharedPreferences.getString('token');
      if (token == null) throw Exception('No token found');

      final formData = FormData.fromMap({
        if (username != null && username.isNotEmpty) 'username': username,
        if (oldPassword != null && oldPassword.isNotEmpty) 'oldPassword': oldPassword,
        if (newPassword != null && newPassword.isNotEmpty) 'newPassword': newPassword,
        if (imagePath != null && imagePath.isNotEmpty)
          'profile_image': await MultipartFile.fromFile(imagePath),
      });

      final response = await apiClient.dio.put(
        '/auth/profile',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error updating profile');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
