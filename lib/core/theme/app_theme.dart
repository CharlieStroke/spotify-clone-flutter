import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static final darkTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    brightness: Brightness.dark,
    fontFamily: 'Satoshi', // O la fuente que prefieras usar
    
    // Configuración de los botones estilo Snakefy [cite: 8]
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    
    // Configuración de los Inputs (Email/Password) [cite: 13, 15]
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.transparent,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    ),
  );
}