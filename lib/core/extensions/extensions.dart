import 'package:flutter/material.dart';

extension ContextX on BuildContext {
  /// Muestra un [SnackBar] rápido de Material Design
  void showSnack(String message, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? Theme.of(this).primaryColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Comprueba si la pantalla es tamaño móvil
  bool get isMobile => MediaQuery.of(this).size.width < 600;
}

extension StringX on String {
  /// Simple email validation
  bool get isValidEmail => contains('@') && contains('.');
  
  /// Seguro para trims de strings posiblemente vacíos
  String get trimSafe => trim();
}
