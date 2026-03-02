import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login.dart';
import '../../features/auth/presentation/pages/register.dart';
import '../../features/auth/presentation/pages/login_or_register.dart';
import '../../features/home/presentation/pages/home.dart';

class AppRoutes {
  // Nombres de las rutas como constantes para evitar errores de tipeo
  static const String initial = '/';
  static const String signup = '/signup';
  static const String signin = '/signin';
  static const String home = '/home';

  // Mapa de rutas que le pasaremos a MaterialApp
  static Map<String, WidgetBuilder> get routes => {
        initial: (context) => const SignupOrSigninPage(),
        signup: (context) => const RegisterPage(),
        signin: (context) => const LoginPage(),
        home: (context) => const HomePage(),
      };
}