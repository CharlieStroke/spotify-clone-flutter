import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../constants/api_constants.dart';
import '../routes/app_routes.dart';
import '../services/network_service.dart';

class ApiClient {
  final Dio _dio;
  final SharedPreferences _prefs;

  ApiClient(this._prefs, NetworkService networkService)
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
      onRequest: (options, handler) {
        // Rechazar inmediatamente si no hay conexión (evita esperar el timeout)
        if (!networkService.isConnected) {
          return handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
              message: 'Sin conexión a internet. Comprueba tu red e inténtalo de nuevo.',
            ),
          );
        }

        // Adjuntar JWT a todas las peticiones autenticadas
        final token = _prefs.getString(AppConstants.tokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token expirado o inválido: limpiar sesión y redirigir al login
          await _prefs.remove(AppConstants.tokenKey);
          AppRoutes.navigatorKey.currentState?.pushNamedAndRemoveUntil(
            AppRoutes.initial,
            (route) => false,
          );
        }
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;
}
