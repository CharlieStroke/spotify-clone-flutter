import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;

  const AppTextField({
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.all(30),
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }
}