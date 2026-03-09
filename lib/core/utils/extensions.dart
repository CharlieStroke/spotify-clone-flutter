import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  void showSnack(String message, {Color color = Colors.redAccent}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
