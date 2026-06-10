import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/storage_screen.dart';
import 'services/firebase_service.dart';
import 'services/storage_service.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seguridad Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const StorageScreen(),
    );
  }
}
