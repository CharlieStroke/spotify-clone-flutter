import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../constants/api_constants.dart';
import '../routes/app_routes.dart';

class ApiClient {
  final Dio _dio;
  final SharedPreferences _prefs;

  ApiClient(this._prefs) : _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  ) {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));

    // Interceptor Global para agregar el Token JWT a todas las peticiones
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _prefs.getString(AppConstants.tokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token expirado o inválido
          await _prefs.remove(AppConstants.tokenKey); // Limpiar token
          
          // Redirigir al Login elegantemente
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