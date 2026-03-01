import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/basic_app_button.dart';
import 'register.dart';
import 'login.dart';

class SignupOrSigninPage extends StatelessWidget {
  const SignupOrSigninPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Aquí podrías poner una imagen de fondo si la tienes
          Container(color: AppColors.background),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Millones de canciones.\nGratis en Snakefy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Snakefy es un clon profesional de Spotify creado con Flutter y Node.js.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, color: AppColors.grey),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: BasicAppButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                        },
                        title: 'Regístrate',
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                        },
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
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}