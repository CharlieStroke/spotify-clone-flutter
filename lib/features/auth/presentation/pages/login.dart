import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'register.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/extensions/extensions.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _onLoginPressed(BuildContext context) {
    FocusScope.of(context).unfocus(); // Ocultar teclado
    if (_email.text.trimSafe.isEmpty || _password.text.isEmpty) {
      context.showSnack('Por favor, ingresa tu email y contraseña', color: Colors.orange);
      return;
    }
    context.read<AuthBloc>().add(AuthSigninEvent(
      email: _email.text.trimSafe,
      password: _password.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          }
          if (state is AuthFailure) {
            context.showSnack(state.message, color: Colors.redAccent);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const AppLogo(size: 120),
                  const SizedBox(height: 40),
                  
                  const Text(
                    'Iniciar sesión en\nSnakefy',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading2,
                  ),
                  const SizedBox(height: 50),
                  
                  AppTextField(
                    label: 'Email',
                    hintText: 'ejemplo@correo.com',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Contraseña',
                    hintText: 'Tu contraseña',
                    controller: _password,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _onLoginPressed(context),
                  ),
                  
                  const SizedBox(height: 40),

                  AppPrimaryButton(
                    text: 'Iniciar sesión',
                    isLoading: isLoading,
                    onPressed: () => _onLoginPressed(context),
                  ),
                  
                  const SizedBox(height: 40),

                  const Text('¿No tienes una cuenta?', style: AppTextStyles.body),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(builder: (context) => const RegisterPage())
                    ),
                    child: const Text('Regístrate', style: AppTextStyles.label),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
