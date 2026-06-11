import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'storage_screen.dart';
import 'counter_screen.dart';
import 'profile_screen.dart';
import '../services/fake_gps_detector.dart';
import '../services/session_manager.dart';
import '../services/screenshot_protection.dart';

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
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkFakeGps();
    ScreenshotProtection.enableProtection();
  }

  @override
  void dispose() {
    ScreenshotProtection.disableProtection();
    super.dispose();
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

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const CounterScreen();
      case 2:
        return const ProfileScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Column(
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
                            subtitle: const Text('Capturas de pantalla bloqueadas (Android)'),
                          ),
                          const Divider(),
                          ListTile(
                            leading: Icon(Icons.touch_app, color: Colors.orange.shade700),
                            title: const Text('Control de inactividad'),
                            subtitle: const Text('Sesión expira tras 15 segundos sin uso'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StorageScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.folder_special),
                      label: const Text('Ver Datos Sensibles'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
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
      appBar: AppBar(
        title: Text(_currentIndex == 0 
            ? 'Inicio' 
            : _currentIndex == 1 
                ? 'Contador' 
                : 'Perfil'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              SessionManager().stopSession();
              
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
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Contador',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
