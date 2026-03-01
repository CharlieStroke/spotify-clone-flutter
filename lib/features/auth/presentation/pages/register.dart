import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/basic_app_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Navegar al Home cuando el backend responda 200 OK
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          }
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text('Regístrate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                  const SizedBox(height: 50),
                  AppTextField(hintText: 'Nombre completo', controller: _fullName),
                  const SizedBox(height: 20),
                  AppTextField(hintText: 'Email', controller: _email),
                  const SizedBox(height: 20),
                  AppTextField(hintText: 'Contraseña', controller: _password, isPassword: true),
                  const SizedBox(height: 30),
                  state is AuthLoading
                      ? const CircularProgressIndicator()
                      : BasicAppButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthSignupEvent(
                                  email: _email.text,
                                  password: _password.text,
                                  name: _fullName.text,
                                ));
                          },
                          title: 'Crear cuenta',
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}