import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../constants/api_constants.dart';
import '../routes/app_routes.dart';
import '../services/network_service.dart';
import '../../injection_container.dart' as di;
import '../../features/auth/data/sources/auth_local_services.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/bloc/home_event.dart';
import '../../features/library/presentation/bloc/library_bloc.dart';
import '../../features/library/presentation/bloc/library_event.dart';
import '../../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../../features/favorites/presentation/bloc/favorites_event.dart';

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
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
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

        final token = await _secureStorage.read(key: AppConstants.tokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          final refreshToken = await _secureStorage.read(key: AppConstants.refreshTokenKey);

          if (refreshToken != null) {
            try {
              final refreshDio = Dio(BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ));

              final response = await refreshDio.post(
                ApiConstants.refreshEndpoint,
                data: {'refreshToken': refreshToken},
              );

              final newToken = response.data['token'] as String;
              final newRefresh = response.data['refreshToken'] as String;

              await _secureStorage.write(key: AppConstants.tokenKey, value: newToken);
              await _secureStorage.write(key: AppConstants.refreshTokenKey, value: newRefresh);

              // Reintentar la petición original con el nuevo token
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final retryResponse = await _dio.fetch(e.requestOptions);
              handler.resolve(retryResponse);
              return;
            } catch (_) {
              // Refresh falló — cerrar sesión
            }
          }

          await di.sl<AuthLocalService>().clear();
          di.sl<HomeBloc>().add(ResetHomeEvent());
          di.sl<LibraryBloc>().add(ResetLibraryEvent());
          di.sl<FavoritesBloc>().add(ResetFavoritesEvent());
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
