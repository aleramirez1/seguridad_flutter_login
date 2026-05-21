import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class FakeGpsDetector {
  static Future<bool> isMockLocationEnabled() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint(' [FAKE GPS] Servicios de ubicación deshabilitados');
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('[FAKE GPS] Permisos de ubicación denegados');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint(' [FAKE GPS] Permisos de ubicacion denegados permanentemente');
        return false;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      bool isMock = position.isMocked;

      if (isMock) {
        debugPrint(' [FAKE GPS] ¡ALERTA! Ubicacion simulada detectada');
        debugPrint(' [FAKE GPS] Lat: ${position.latitude}, Lon: ${position.longitude}');
        debugPrint(' [FAKE GPS] isMocked: $isMock');
      } else {
        debugPrint(' [FAKE GPS] Ubicacion real detectada');
        debugPrint(' [FAKE GPS] Lat: ${position.latitude}, Lon: ${position.longitude}');
      }

      return isMock;
    } catch (e) {
      debugPrint(' [FAKE GPS] Error al detectar ubicacion: $e');
      return false;
    }
  }

  static Future<void> checkAndAlert(BuildContext context) async {
    bool isFakeGps = await isMockLocationEnabled();

    if (isFakeGps && context.mounted) {
      _showFakeGpsAlert(context);
    }
  }

  static void _showFakeGpsAlert(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 7), () {
          debugPrint(' [FAKE GPS] Cerrando aplicacion automáticamente despues de 7 segundos');
          if (context.mounted) {
            Navigator.of(context).pop();
          }
          SystemNavigator.pop();
        });

        return AlertDialog(
          icon: const Icon(
            Icons.block,
            color: Colors.red,
            size: 60,
          ),
          title: const Text(
            ' Acceso Denegado',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Se ha detectado que estas usando una ubicacion simulada (Fake GPS).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                ' Por razones de seguridad, esta aplicacion NO PUEDE ejecutarse con ubicaciones falsas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Debes desactivar cualquier aplicacion de Fake GPS para poder usar esta app.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 24),
              Text(
                '⏱ La aplicación se cerrara en 7 segundos...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget buildFakeGpsWarningBanner(bool isFakeGps) {
    if (!isFakeGps) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.red.shade700,
      child: const Row(
        children: [
          Icon(Icons.warning, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              ' Fake GPS detectado - Funcionalidad limitada',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
