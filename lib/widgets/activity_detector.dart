import 'package:flutter/material.dart';
import '../services/session_manager.dart';

class ActivityDetector extends StatelessWidget {
  final Widget child;
  
  const ActivityDetector({
    super.key,
    required this.child,
  });

  void _handleUserActivity() {
    SessionManager().registerActivity();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _handleUserActivity(),
      onPointerMove: (_) => _handleUserActivity(),
      onPointerUp: (_) => _handleUserActivity(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _handleUserActivity();
          return false;
        },
        child: Focus(
          onFocusChange: (hasFocus) {
            if (hasFocus) _handleUserActivity();
          },
          child: child,
        ),
      ),
    );
  }
}
