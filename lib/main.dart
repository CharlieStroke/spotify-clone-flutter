import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // Inicializa la inyección de dependencias
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Proveemos el AuthBloc globalmente usando el Service Locator
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
      ],
      child: MaterialApp(
        title: 'Snakefy',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const Scaffold(body: Center(child: Text("Snakefy Ready"))),
      ),
    );
  }
}