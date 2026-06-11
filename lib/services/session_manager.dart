import 'dart:async';
import 'package:flutter/material.dart';

class SessionManager extends ChangeNotifier {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  static const int _inactivityTimeoutSeconds = 15;
  
  Timer? _inactivityTimer;
  DateTime? _lastActivityTime;
  bool _isSessionActive = false;
  VoidCallback? _onSessionExpired;

  void initialize({required VoidCallback onSessionExpired}) {
    _onSessionExpired = onSessionExpired;
    _isSessionActive = true;
    _resetTimer();
  }

  void registerActivity() {
    if (!_isSessionActive) return;
    _lastActivityTime = DateTime.now();
    _resetTimer();
  }

  void _resetTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(
      Duration(seconds: _inactivityTimeoutSeconds),
      _handleSessionExpiration,
    );
  }

  void _handleSessionExpiration() {
    if (!_isSessionActive) return;
    _isSessionActive = false;
    _inactivityTimer?.cancel();
    _onSessionExpired?.call();
  }

  void stopSession() {
    _isSessionActive = false;
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  void resumeSession() {
    if (_isSessionActive) return;
    _isSessionActive = true;
    _resetTimer();
  }

  bool get isActive => _isSessionActive;
  DateTime? get lastActivity => _lastActivityTime;

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }
}
