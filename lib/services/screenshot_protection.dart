import 'dart:io';
import 'package:flutter/services.dart';

class ScreenshotProtection {
  static const MethodChannel _channel = MethodChannel('screenshot_protection');
  static bool _isProtected = false;

  static Future<void> enableProtection() async {
    if (_isProtected) return;

    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('enableProtection');
        _isProtected = true;
      }
    } catch (e) {
      print('Error al habilitar protección: $e');
    }
  }

  static Future<void> disableProtection() async {
    if (!_isProtected) return;

    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('disableProtection');
        _isProtected = false;
      }
    } catch (e) {
      print('Error al deshabilitar protección: $e');
    }
  }

  static bool get isProtected => _isProtected;
}
