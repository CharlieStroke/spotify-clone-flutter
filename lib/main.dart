import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart'; // Importamos las rutas
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/data/sources/auth_local_services.dart'; // Importamos el servicio local
import 'features/main_navigation/presentation/cubit/main_navigation_cubit.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/bloc/profile_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
        // Disparamos el LoadProfileEvent al iniciar la app para tener los datos precargados
        BlocProvider(create: (_) => di.sl<ProfileBloc>()..add(LoadProfileEvent())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: initialRoute, // Usamos la ruta decidida
        routes: AppRoutes.routes,
      ),
    );
  }
}