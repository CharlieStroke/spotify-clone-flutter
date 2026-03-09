import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart'; // Importamos las rutas
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/data/sources/auth_local_services.dart';
import 'features/main_navigation/presentation/cubit/main_navigation_cubit.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/player/presentation/bloc/player_cubit.dart';
import 'features/library/presentation/bloc/library_bloc.dart';
import 'features/favorites/presentation/bloc/favorites_bloc.dart';
import 'features/artist/presentation/bloc/artist_bloc.dart';

import 'package:just_audio_background/just_audio_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 0. Inicializar Audio de Fondo (Lock Screen / Notificaciones)
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  
  // 1. Inicializamos GetIt (DI)
  await di.init();
  
  // 2. Consultamos si existe un token guardado
  final authLocalService = di.sl<AuthLocalService>();
  final String? token = await authLocalService.getToken();

  // 3. Decidimos la ruta inicial
  final String initialRoute = (token != null) 
      ? AppRoutes.home 
      : AppRoutes.initial;

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  
  const MyApp({required this.initialRoute, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<MainNavigationCubit>()),
        // Eliminamos el ..add(LoadProfileEvent()) de aquí porque si el usuario
        // no está logueado, la app hará crash pidiendo el token. 
        // El evento se lanzará cuando se entre a la pantalla principal protegida.
        BlocProvider(create: (_) => di.sl<ProfileBloc>()),
        BlocProvider(create: (_) => di.sl<PlayerCubit>()),
        BlocProvider(create: (_) => di.sl<LibraryBloc>()),
        BlocProvider(create: (_) => di.sl<FavoritesBloc>()), // evento se dispara en MainPage.initState
        BlocProvider(create: (_) => di.sl<ArtistBloc>()),
      ],
      child: MaterialApp(
        navigatorKey: AppRoutes.navigatorKey, // Permite navegación sin context
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: initialRoute, // Usamos la ruta decidida
        routes: AppRoutes.routes,
      ),
    );
  }
}