import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'storage_service.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final StorageService _storageService = StorageService();

  static const String deleteKeyword = "DELETE_DATA";
  
  Function? onDataDeleted;

  Future<void> initialize() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();
    
    print('----------------------');
    print('🔥 Firebase Inicializado');
    print('FCM Token: $token');
    print('----------------------');

    _setupNotificationListeners();
  }

  void _setupNotificationListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotification(message);
    });
  }

  void _handleNotification(RemoteMessage message) async {
    Map<String, dynamic> data = message.data;

    print('----------------------');
    print('📩 Notificación Recibida');
    print('Título: ${message.notification?.title}');
    print('Cuerpo: ${message.notification?.body}');
    print('Data: $data');

    if (data['action'] == deleteKeyword) {
      String? targetUserId = data['userId'];
      String currentUserId = await _storageService.getUserId();

      print('Target userId: $targetUserId');
      print('Current userId: $currentUserId');

      if (targetUserId != null && targetUserId == currentUserId) {
        print('✅ User ID coincide - BORRANDO DATOS');
        await _deleteAllStoredData();
      } else {
        print('❌ User ID no coincide - Ignorando notificación');
      }
    }
    print('----------------------');
  }

  Future<void> _deleteAllStoredData() async {
    await _storageService.deleteAllSensitiveData();
    print('🗑️ Datos sensibles eliminados del almacenamiento');
    
    if (onDataDeleted != null) {
      onDataDeleted!();
    }
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
