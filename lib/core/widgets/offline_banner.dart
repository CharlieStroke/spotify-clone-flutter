import 'package:flutter/material.dart';
import '../network/network_info.dart';
import '../../injection_container.dart' as di;

class OfflineBanner extends StatefulWidget {
  final Widget child;

  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late NetworkInfo _networkInfo;
  bool _isConnected = true;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _networkInfo = di.sl<NetworkInfo>();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // Off-screen top
      end: Offset.zero,           // On-screen
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _checkInitialConnection();
    _networkInfo.onConnectivityChanged.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
          if (!_isConnected) {
            _animationController.forward();
          } else {
            _animationController.reverse();
          }
        });
      }
    });
  }

  Future<void> _checkInitialConnection() async {
    final isConnected = await _networkInfo.isConnected;
    if (mounted) {
      setState(() {
        _isConnected = isConnected;
        if (!_isConnected) {
          _animationController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.redAccent.shade700.withValues(alpha: 0.95),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Sin conexión a Internet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none, // Para cuando no hay scaffold wrapper
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
