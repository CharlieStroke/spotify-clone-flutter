import 'package:flutter/material.dart';
import '../services/biometric_auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../injection_container.dart' as di;

class BiometricGuardPage extends StatefulWidget {
  final Widget child;

  const BiometricGuardPage({super.key, required this.child});

  @override
  State<BiometricGuardPage> createState() => _BiometricGuardPageState();
}

class _BiometricGuardPageState extends State<BiometricGuardPage> {
  final BiometricAuthService _biometricService = BiometricAuthService();
  bool _isAuthenticated = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final isAvailable = await _biometricService.isBiometricAvailable();
    if (!isAvailable) {
      setState(() {
        _isAuthenticated = true;
        _isLoading = false;
      });
      return;
    }

    final authenticated = await _biometricService.authenticate();
    if (authenticated) {
      setState(() {
        _isAuthenticated = true;
        _isLoading = false;
      });
    } else {
      // Si falla o se cancela, podemos cerrar sesión o mostrar un botón de reintentar
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _logout() async {
    final prefs = di.sl<SharedPreferences>();
    await prefs.remove('token');
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.initial, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (!_isAuthenticated) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: AppColors.primary),
              const SizedBox(height: 20),
              const Text(
                'App Bloqueada',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Desbloquea para escuchar tu música',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _checkBiometrics,
                icon: const Icon(Icons.fingerprint, color: Colors.white),
                label: const Text('Reintentar', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _logout,
                child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent)),
              )
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
