import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../features/auth/presentation/pages/login.dart';
import '../../features/auth/presentation/pages/register.dart';
import '../../features/auth/presentation/pages/login_or_register.dart';
import '../../features/main_navigation/presentation/pages/main_page.dart';
import '../../features/artist/presentation/pages/public_artist_profile_page.dart';
import '../../features/artist/presentation/cubit/public_artist_profile_cubit.dart';
import '../widgets/biometric_guard_page.dart';

class AppRoutes {
  // Clave global para navegar sin context (usada por Interceptores)
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Nombres de las rutas como constantes para evitar errores de tipeo
  static const String initial = '/';
  static const String signup = '/signup';
  static const String signin = '/signin';
  static const String home = '/home';
  static const String artistProfile = '/artist';

  // Mapa de rutas que le pasaremos a MaterialApp
  static Map<String, WidgetBuilder> get routes => {
        initial: (context) => const SignupOrSigninPage(),
        signup: (context) => const RegisterPage(),
        signin: (context) => const LoginPage(),
        home: (context) => const BiometricGuardPage(child: MainPage()),
        artistProfile: (context) {
          final artistId = ModalRoute.of(context)!.settings.arguments as int;
          return BlocProvider(
            create: (_) => GetIt.instance<PublicArtistProfileCubit>(),
            child: PublicArtistProfilePage(artistId: artistId),
          );
        },
      };
}