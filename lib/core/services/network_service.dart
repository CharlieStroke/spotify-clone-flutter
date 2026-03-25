import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Servicio que monitorea el estado de conectividad de la red en tiempo real.
///
/// Se integra con [ApiClient] para rechazar peticiones offline con un mensaje
/// claro, en lugar de esperar a que Dio haga timeout.
///
/// Uso:
/// ```dart
/// if (!networkService.isConnected) {
///   // mostrar banner offline
/// }
/// ```
class NetworkService {
  final Connectivity _connectivity;

  bool _isConnected = true; // optimista: asumimos conexión hasta verificar
  StreamSubscription<List<ConnectivityResult>>? _sub;

  NetworkService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Estado actual de conectividad (sin await).
  bool get isConnected => _isConnected;

  /// Inicializa el servicio: verifica el estado actual y escucha cambios futuros.
  /// Debe llamarse una vez durante el arranque de la aplicación.
  Future<void> init() async {
    // Verificar estado inicial real antes de asumir que hay conexión
    final initialResults = await _connectivity.checkConnectivity();
    _isConnected = _evaluate(initialResults);

    // Suscribirse a cambios futuros para mantener el estado actualizado
    _sub = _connectivity.onConnectivityChanged.listen((results) {
      _isConnected = _evaluate(results);
    });
  }

  void dispose() {
    _sub?.cancel();
  }

  bool _evaluate(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
