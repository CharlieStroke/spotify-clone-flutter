import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';
import '../../../../core/constants/api_constants.dart';

abstract class AuthApiService {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
}

class AuthApiServiceImpl implements AuthApiService {
  final ApiClient _apiClient;

  AuthApiServiceImpl(this._apiClient);

  @override
Future<UserModel> login(String email, String password) async {
  try {
    final response = await _apiClient.dio.post(
      ApiConstants.loginEndpoint,
      data: {
        'email': email,
        'password': password,
      },
    );

    // Verificamos si 'user' existe en la respuesta
    if (response.data['user'] != null) {
      return UserModel.fromJson(response.data);
    } else {
      // Si el backend solo manda el token, creamos un modelo básico
      // para que el flujo de la app continúe al Home
      return UserModel(email: email, uid: 'logged_in', token: response.data['token']); 
    }
  } on DioException catch (e) {
    throw Exception(e.response?.data['message'] ?? 'Error al iniciar sesión');
  }
}

  @override
  Future<UserModel> register(String username, String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.registerEndpoint,
        data: {
          'username': username, 
          'email': email, 
          'password': password},
      );
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al registrarse');
    }
  }
}