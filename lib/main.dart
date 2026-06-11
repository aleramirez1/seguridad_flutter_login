import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/login_screen.dart';
import 'services/firebase_service.dart';
import 'services/storage_service.dart';
import 'services/session_manager.dart';
import 'widgets/activity_detector.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  
  print('----------------------');
  print('📩 Notificación en Background');
  print('Message ID: ${message.messageId}');
  
  if (message.data['action'] == FirebaseService.deleteKeyword) {
    String? targetUserId = message.data['userId'];
    if (targetUserId != null) {
      String currentUserId = await StorageService().getUserId();
      print('Target userId: $targetUserId');
      print('Current userId: $currentUserId');
      
      if (targetUserId == currentUserId) {
        print('✅ User ID coincide - BORRANDO DATOS');
        await StorageService().deleteAllSensitiveData();
      } else {
        print('❌ User ID no coincide - Ignorando');
      }
    }
  }
  print('----------------------');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  await FirebaseService().initialize();
  
  await StorageService().initializeWithSampleData();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  @override
  void initState() {
    super.initState();
    SessionManager().initialize(
      onSessionExpired: _handleSessionExpired,
    );
  }

  void _handleSessionExpired() {
    final BuildContext? context = _navigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      final BuildContext? dialogContext = _navigatorKey.currentContext;
      if (dialogContext != null && dialogContext.mounted) {
        showDialog(
          context: dialogContext,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              icon: const Icon(
                Icons.lock_clock,
                color: Colors.orange,
                size: 48,
              ),
              title: const Text(
                'Sesión Expirada',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text(
                'Tu sesión ha sido cerrada automáticamente por seguridad debido a inactividad.\n\nPor favor, inicia sesión nuevamente.',
                textAlign: TextAlign.center,
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Entendido'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  void dispose() {
    SessionManager().stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ActivityDetector(
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Seguridad Login',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
