import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

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

  ProfileApiServiceImpl({required this.apiClient});

  @override
  Future<UserModel> getUserProfile() async {
    try {
      final response = await apiClient.dio.get('/auth');
      return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error de conexión al servidor');
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
      final formData = FormData.fromMap({
        if (username != null && username.isNotEmpty) 'username': username,
        if (oldPassword != null && oldPassword.isNotEmpty) 'oldPassword': oldPassword,
        if (newPassword != null && newPassword.isNotEmpty) 'newPassword': newPassword,
        if (imagePath != null && imagePath.isNotEmpty)
          'profile_image': await MultipartFile.fromFile(imagePath),
      });

      final response = await apiClient.dio.put('/auth/profile', data: formData);
      return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error updating profile');
    }
  }
}
