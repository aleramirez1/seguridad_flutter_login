# 🔒 Protección contra Capturas de Pantalla - Flutter

Aplicación Flutter que implementa **FLAG_SECURE** para prevenir capturas de pantalla y proteger información sensible de credenciales de acceso.

## 📋 Descripción

Este proyecto es una práctica de laboratorio de **Seguridad en Aplicaciones Móviles** que demuestra la implementación de controles de seguridad para prevenir la fuga de información mediante capturas de pantalla en dispositivos Android.

## ✨ Características

- ✅ **Pantalla de Login** con validación de formularios
- ✅ **Protección FLAG_SECURE** en Android
- ✅ **Bloqueo de capturas de pantalla** y grabación
- ✅ **Detección de Fake GPS** con alertas de seguridad
- ✅ **Banner de advertencia** cuando se detecta ubicación simulada
- ✅ **Navegación segura** entre pantallas
- ✅ **Logs de seguridad** para monitoreo
- ✅ **Diseño moderno** con Material Design 3

## 🛠️ Tecnologías Utilizadas

- **Flutter:** 3.38.3
- **Dart:** 3.10.1
- **screen_protector:** 1.5.1
- **geolocator:** ^13.0.2
- **Android:** 15-16 (API 35-36)
- **Gradle:** AGP 9.0+
- **Kotlin:** JVM 17

## 🔐 Seguridad Implementada

### Estándares y Buenas Prácticas
- **OWASP Mobile Top 10** - M2: Insecure Data Storage
- **OWASP MASVS** - V2: Data Storage and Privacy
- **FLAG_SECURE** en ciclo de vida de pantallas (`initState()`)
- **Detección de Fake GPS** para prevenir ubicaciones simuladas
- Validación de entrada de usuario
- Protección activa en todas las pantallas sensibles

### Amenazas Mitigadas
- 🛡️ Shoulder surfing (miradas indiscretas)
- 🛡️ Malware de captura de pantalla
- 🛡️ Fuga accidental de credenciales
- 🛡️ Grabación de pantalla no autorizada
- 🛡️ **Fake GPS / Ubicación simulada**
- 🛡️ **Spoofing de ubicación**

## 📦 Instalación

### Prerrequisitos
- Flutter SDK 3.38.3 o superior
- Android Studio / VS Code
- Dispositivo Android físico o emulador

### Pasos de Instalación

```bash
# 1. Clonar el repositorio
git clone https://github.com/aleramirez1/seguridad_flutter_login.git
cd seguridad_flutter_login

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en dispositivo
flutter run
```

## 🚀 Uso

1. **Ejecutar la aplicación** en un dispositivo Android
2. **Ingresar credenciales** en la pantalla de login (cualquier usuario con contraseña de 6+ caracteres)
3. **Intentar capturar pantalla** - El sistema bloqueará la acción
4. **Verificar logs** en la consola para confirmar protección activa

### Logs Esperados
```
✅ [LOGIN] Protección contra capturas ACTIVADA
🔒 [LOGIN] FLAG_SECURE habilitado - Capturas bloqueadas
📱 [LOGIN] Cualquier intento de captura será bloqueado por el SO
✅ [FAKE GPS] Ubicación real detectada
📍 [FAKE GPS] Lat: 16.7569, Lon: -93.1292
```

### Si se detecta Fake GPS:
```
🚨 [FAKE GPS] ¡ALERTA! Ubicación simulada detectada
📍 [FAKE GPS] Lat: 37.4219999, Lon: -122.0840575
⚠️ [FAKE GPS] isMocked: true
```

## 📁 Estructura del Proyecto

```
seguridad_login/
├── lib/
│   ├── main.dart                    # Punto de entrada
│   ├── screens/
│   │   ├── login_screen.dart        # Pantalla de login con protección
│   │   └── home_screen.dart         # Pantalla principal con protección
│   └── services/
│       └── fake_gps_detector.dart   # Servicio de detección de Fake GPS
├── android/
│   └── app/
│       ├── src/main/AndroidManifest.xml  # Permisos de ubicación
│       └── build.gradle.kts              # Configuración Gradle
├── pubspec.yaml                     # Dependencias del proyecto
└── README.md                        # Este archivo
```

## 🔧 Configuración de Seguridad

### 1. Protección contra Capturas de Pantalla

En `login_screen.dart` y `home_screen.dart`:

```dart
@override
void initState() {
  super.initState();
  _enableScreenshotProtection();
}

Future<void> _enableScreenshotProtection() async {
  try {
    await ScreenProtector.protectDataLeakageOn();
    debugPrint('✅ Protección contra capturas ACTIVADA');
  } catch (e) {
    debugPrint('❌ Error al activar protección: $e');
  }
}
```

### 2. Detección de Fake GPS

En `fake_gps_detector.dart`:

```dart
static Future<bool> isMockLocationEnabled() async {
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
  
  bool isMock = position.isMocked;
  
  if (isMock) {
    debugPrint('🚨 [FAKE GPS] ¡ALERTA! Ubicación simulada detectada');
  }
  
  return isMock;
}
```

### 3. Permisos en AndroidManifest.xml

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### En `pubspec.yaml`:

```yaml
dependencies:
  screen_protector: ^1.4.2
  geolocator: ^13.0.2
```

## 🐛 Problemas Resueltos

Durante el desarrollo se resolvieron los siguientes problemas:

1. ✅ **Incompatibilidad SDK Dart** (3.12.0 → 3.10.0)
2. ✅ **Error Gradle AGP 9.0+** (configuración de plugins Kotlin)
3. ✅ **Conflicto JVM Target** (Java 17 vs Kotlin 21)
4. ✅ **Selección de paquete compatible** (flutter_windowmanager → screen_protector)

## 📚 Documentación Adicional

- [OWASP Mobile Top 10](https://owasp.org/www-project-mobile-top-10/)
- [Flutter Security Best Practices](https://docs.flutter.dev/security)
- [Android FLAG_SECURE Documentation](https://developer.android.com/reference/android/view/WindowManager.LayoutParams#FLAG_SECURE)
- [screen_protector Package](https://pub.dev/packages/screen_protector)

## 👥 Autor

**Alexia Vanelli Ramirez Santana**
- Matrícula: 233380
- Carrera: Ingeniería en Software
- Institución: Universidad Politécnica de Chiapas
- Correo: 233380@ids.upchiapas.edu.mx

## 📄 Licencia

Este proyecto es parte de una práctica académica de laboratorio.

## 🙏 Agradecimientos

- Profesor de Seguridad de la Información
- Comunidad de Flutter
- Documentación de OWASP Mobile Security

---

**Nota:** Este proyecto demuestra la implementación de controles de seguridad básicos. Para aplicaciones de producción, se recomienda implementar capas adicionales de seguridad como encriptación, autenticación biométrica, y SSL pinning.
