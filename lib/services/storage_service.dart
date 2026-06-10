import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/sensitive_data.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _storage = const FlutterSecureStorage();
  final _uuid = const Uuid();

  static const String _userIdKey = 'device_user_id';
  static const String _userEmailKey = 'user_email';
  static const String _passwordKey = 'password';
  static const String _creditCardKey = 'credit_card';
  static const String _ssnKey = 'ssn';

  Future<String> getUserId() async {
    String? userId = await _storage.read(key: _userIdKey);
    if (userId == null) {
      userId = _uuid.v4();
      await _storage.write(key: _userIdKey, value: userId);
    }
    return userId;
  }

  Future<void> saveSensitiveData(SensitiveData data) async {
    await _storage.write(key: _userEmailKey, value: data.userEmail);
    await _storage.write(key: _passwordKey, value: data.password);
    await _storage.write(key: _creditCardKey, value: data.creditCard);
    await _storage.write(key: _ssnKey, value: data.ssn);
  }

  Future<SensitiveData> getSensitiveData() async {
    final email = await _storage.read(key: _userEmailKey);
    final password = await _storage.read(key: _passwordKey);
    final creditCard = await _storage.read(key: _creditCardKey);
    final ssn = await _storage.read(key: _ssnKey);

    return SensitiveData(
      userEmail: email ?? '',
      password: password ?? '',
      creditCard: creditCard ?? '',
      ssn: ssn ?? '',
    );
  }

  Future<void> initializeWithSampleData() async {
    final currentData = await getSensitiveData();
    if (currentData.isEmpty) {
      await saveSensitiveData(SensitiveData.sample());
    }
  }

  Future<void> deleteAllSensitiveData() async {
    await _storage.delete(key: _userEmailKey);
    await _storage.delete(key: _passwordKey);
    await _storage.delete(key: _creditCardKey);
    await _storage.delete(key: _ssnKey);
  }

  Future<void> deleteAllData() async {
    await _storage.deleteAll();
  }
}

