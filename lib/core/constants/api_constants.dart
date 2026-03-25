class ApiConstants {
  /// Configurable via --dart-define=API_BASE_URL=https://tu-dominio.com/api
  /// Ejemplo de build: flutter build apk --dart-define=API_BASE_URL=https://api.snakefy.app/api
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://159.54.145.22:4000/api',
  );

  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String userProfileEndpoint = '/auth/';

  static const String getSongsEndpoint = '/songs/all';
}