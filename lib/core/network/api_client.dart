import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../constants/api_constants.dart';
import '../routes/app_routes.dart';
import '../services/network_service.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  ApiClient(this._secureStorage, NetworkService networkService)
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    // Logging solo en debug para no exponer datos sensibles en producción
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Rechazar inmediatamente si no hay conexión (evita esperar el timeout)
        if (!networkService.isConnected) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
              message: 'Sin conexión a internet. Comprueba tu red e inténtalo de nuevo.',
            ),
          );
          return;
        }

        // Adjuntar JWT a todas las peticiones autenticadas
        final token = await _secureStorage.read(key: AppConstants.tokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token expirado o inválido: limpiar sesión y redirigir al login
          await _secureStorage.delete(key: AppConstants.tokenKey);
          AppRoutes.navigatorKey.currentState?.pushNamedAndRemoveUntil(
            AppRoutes.initial,
            (route) => false,
          );
        }
        handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;
}
