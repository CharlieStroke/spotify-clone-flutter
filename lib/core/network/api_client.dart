import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class ApiClient {
  final Dio _dio;

  ApiClient() : _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  ) {
    // ESTO ES ORO PURO PARA DEBUGGEAR
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Dio get dio => _dio;
}