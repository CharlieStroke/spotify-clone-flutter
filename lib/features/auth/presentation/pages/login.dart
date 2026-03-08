import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  Widget _buildTextFieldWithLabel(String label, String hint, TextEditingController controller, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
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
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Logo de la App
                  ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Título principal
                  const Text(
                    'Iniciar sesión en\nSnakefy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 50),
                  
                  // Campos
                  _buildTextFieldWithLabel('Email', 'Email', _email),
                  const SizedBox(height: 20),
                  _buildTextFieldWithLabel('Contraseña', 'Contraseña', _password, isPassword: true),
                  
                  const SizedBox(height: 40),

                  // Elemento de carga / Botón invisible por ahora (o dejarlo visible si se quiere)
                  // Viendo el mockup, no hay botón de Iniciar sesión explícito dentro del form, sino
                  // que abajo dice "¿No tienes una cuenta? Regístrate". 
                  // Mmh, pero tiene que haber un botón de submit. Vamos a agregarlo
                  // de igual estilo que en SignupOrSignin aunque el mockup está cortado.
                  // (En el mockup de registro no veo el botón, está cortado abajo. 
                  // Agregaré un botón de Iniciar Sesión aquí).
                  state is AuthLoading
                      ? const CircularProgressIndicator(color: AppColors.primary)
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<AuthBloc>().add(AuthSigninEvent(
                                    email: _email.text,
                                    password: _password.text,
                                  ));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                  
                  const SizedBox(height: 40),

                  // Link abajo
                  const Text(
                    '¿No tienes una cuenta?',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(builder: (context) => const RegisterPage())
                      );
                    },
                    child: const Text(
                      'Regístrate',
                      style: TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
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
