import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/extensions/extensions.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _userName.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _onRegisterPressed(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_userName.text.trimSafe.isEmpty || _email.text.trimSafe.isEmpty || _password.text.isEmpty) {
      context.showSnack('Por favor, completa todos los campos', color: Colors.orange);
      return;
    }
    context.read<AuthBloc>().add(AuthSignupEvent(
      username: _userName.text.trimSafe,
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
                  const SizedBox(height: 10),
                  const AppLogo(size: 100),
                  const SizedBox(height: 30),
                  
                  const Text(
                    'Regístrate para\nempezar a escuchar\ncontenido',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 20),
                  
                  AppTextField(
                    label: 'Nombre',
                    hintText: 'Tu nombre de usuario',
                    controller: _userName,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Email',
                    hintText: 'ejemplo@correo.com',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Contraseña',
                    hintText: 'Tu contraseña secreta',
                    controller: _password,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _onRegisterPressed(context),
                  ),
                  
                  const SizedBox(height: 20),

                  AppPrimaryButton(
                    text: 'Regístrate',
                    isLoading: isLoading,
                    onPressed: () => _onRegisterPressed(context),
                  ),
                  
                  const SizedBox(height: 30),

                  const Text('¿Ya tienes cuenta?', style: AppTextStyles.body),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(builder: (context) => const LoginPage())
                    ),
                    child: const Text('Iniciar sesión', style: AppTextStyles.label),
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