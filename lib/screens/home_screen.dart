import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';
import 'login_screen.dart';
import '../services/fake_gps_detector.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({
    super.key,
    required this.username,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isFakeGps = false;

  @override
  void initState() {
    super.initState();
    _enableScreenshotProtection();
    _checkFakeGps();
  }

  Future<void> _enableScreenshotProtection() async {
    try {
      await ScreenProtector.protectDataLeakageOn();
      debugPrint('[HOME] Proteccion contra capturas ACTIVADA');
      debugPrint('[HOME] FLAG_SECURE habilitado - Capturas bloqueadas');
    } catch (e) {
      debugPrint('[HOME] Error al activar proteccion: $e');
    }
  }

  Future<void> _checkFakeGps() async {
    bool isFake = await FakeGpsDetector.isMockLocationEnabled();
    setState(() {
      _isFakeGps = isFake;
    });

    if (isFake && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FakeGpsDetector.checkAndAlert(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Column(
        children: [
          FakeGpsDetector.buildFakeGpsWarningBanner(_isFakeGps),
          
          Expanded(
            child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 100,
                color: Colors.green.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                '¡Bienvenido!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.username,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey.shade700,
                    ),
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.security, color: Colors.blue.shade700),
                        title: const Text('Sesión iniciada correctamente'),
                        subtitle: const Text('Tu información está protegida'),
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.verified_user, color: Colors.green.shade700),
                        title: const Text('Protección activa'),
                        subtitle: const Text('Capturas de pantalla bloqueadas'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
            ),
          ),
        ],
      ),
    );
  }
}
