# 🚫 Implementación de Detección y Bloqueo de Fake GPS

## 📋 Resumen

Se implementó un sistema completo de detección y bloqueo de ubicaciones simuladas (Fake GPS) en la aplicación Flutter de seguridad de login.

## ✅ Funcionalidades Implementadas

### 1. **Detección Automática de Fake GPS**
- ✅ Verifica la ubicación al iniciar la aplicación
- ✅ Usa `geolocator` para obtener la posición actual
- ✅ Detecta si la ubicación es simulada mediante `position.isMocked`
- ✅ Logs detallados con coordenadas y estado de mock

### 2. **Bloqueo de Acceso**
- ✅ **NO permite hacer login** si se detecta Fake GPS
- ✅ Muestra mensaje de error en SnackBar
- ✅ Alerta modal con mensaje claro de acceso denegado
- ✅ Botón "Entendido" que **cierra la aplicación** completamente

### 3. **Indicadores Visuales**
- ✅ **Banner rojo** en la parte superior cuando se detecta Fake GPS
- ✅ Alerta modal con icono de bloqueo
- ✅ Mensajes claros sobre por qué no puede usar la app

### 4. **Verificación Continua**
- ✅ Verifica al abrir LoginScreen
- ✅ Verifica al abrir HomeScreen
- ✅ **Verifica antes de cada intento de login**

## 🔧 Archivos Modificados

### 1. `lib/services/fake_gps_detector.dart`
Servicio principal de detección con los siguientes métodos:

```dart
// Detecta si la ubicación es simulada
static Future<bool> isMockLocationEnabled()

// Muestra alerta y verifica
static Future<void> checkAndAlert(BuildContext context)

// Alerta modal que cierra la app
static void _showFakeGpsAlert(BuildContext context)

// Banner de advertencia visual
static Widget buildFakeGpsWarningBanner(bool isFakeGps)
```

### 2. `lib/screens/login_screen.dart`
- Importa `FakeGpsDetector`
- Variable `_isFakeGps` para estado
- Método `_checkFakeGps()` en `initState()`
- **Verificación en `_handleLogin()`** que bloquea el acceso
- Banner de advertencia en el UI

### 3. `lib/screens/home_screen.dart`
- Importa `FakeGpsDetector`
- Variable `_isFakeGps` para estado
- Método `_checkFakeGps()` en `initState()`
- Banner de advertencia en el UI

### 4. `android/app/src/main/AndroidManifest.xml`
- Permisos de ubicación agregados:
  - `ACCESS_FINE_LOCATION`
  - `ACCESS_COARSE_LOCATION`

### 5. `pubspec.yaml`
- Dependencia agregada: `geolocator: ^13.0.2`

## 📱 Flujo de Funcionamiento

```
1. Usuario abre la app
   ↓
2. LoginScreen se inicializa
   ↓
3. Se ejecuta _checkFakeGps()
   ↓
4. Geolocator obtiene posición actual
   ↓
5. ¿position.isMocked == true?
   ├─ SÍ → Muestra banner rojo + alerta modal
   └─ NO → Permite uso normal
   ↓
6. Usuario ingresa credenciales y presiona "Ingresar"
   ↓
7. Se ejecuta _handleLogin()
   ↓
8. Verifica nuevamente Fake GPS
   ↓
9. ¿isFake == true?
   ├─ SÍ → BLOQUEA login + SnackBar + Alerta
   └─ NO → Permite login y navega a Home
```

## 🚨 Comportamiento con Fake GPS Activo

### Al Abrir la App:
```
✅ [LOGIN] Protección contra capturas ACTIVADA
🔒 [LOGIN] FLAG_SECURE habilitado
🚨 [FAKE GPS] ¡ALERTA! Ubicación simulada detectada
📍 [FAKE GPS] Lat: 26.348315, Lon: 12.138984
⚠️ [FAKE GPS] isMocked: true
```

- Muestra **banner rojo** en la parte superior
- Muestra **alerta modal** automáticamente
- Usuario ve el mensaje de acceso denegado

### Al Intentar Hacer Login:
```
🚫 No se puede iniciar sesión con Fake GPS activo
```

- SnackBar rojo con mensaje de error
- Alerta modal se muestra nuevamente
- **Login es bloqueado** - NO navega a HomeScreen

### Cierre Automático con Contador Regresivo:
```
⏱️ La aplicación se cerrará en:
7 segundos
6 segundos
5 segundos
4 segundos
3 segundos (cambia a rojo)
2 segundos (rojo)
1 segundo (rojo)
🚫 [FAKE GPS] Cerrando aplicación automáticamente
```

- La alerta se muestra **sin botones**
- **Contador regresivo animado** de 7 a 0
- Número grande (48px) que cambia cada segundo
- Color **naranja** para 7-4 segundos
- Color **rojo** para 3-1 segundos (urgencia)
- Después de **7 segundos**, la aplicación se **cierra automáticamente**
- Usa `SystemNavigator.pop()` para cerrar completamente
- El usuario tiene tiempo para leer el mensaje antes del cierre

## 🔐 Seguridad Implementada

### Amenazas Mitigadas:
- ✅ **Spoofing de ubicación** - Detecta ubicaciones falsas
- ✅ **Fake GPS apps** - Identifica apps de simulación
- ✅ **Acceso no autorizado** - Bloquea login con ubicación falsa
- ✅ **Bypass de geolocalización** - Previene uso de la app con GPS falso

### Estándares Aplicados:
- **OWASP Mobile Top 10** - M1: Improper Platform Usage
- **OWASP MASVS** - V2.9: Location Services Security
- **Best Practices** - Verificación de ubicación en apps sensibles

## 📊 Logs de Ejemplo

### Ubicación Real (Permitido):
```
✅ [FAKE GPS] Ubicación real detectada
📍 [FAKE GPS] Lat: 16.6162328, Lon: -93.0909702
```

### Ubicación Simulada (Bloqueado):
```
🚨 [FAKE GPS] ¡ALERTA! Ubicación simulada detectada
📍 [FAKE GPS] Lat: 26.348315737645787, Lon: 12.138984985649586
⚠️ [FAKE GPS] isMocked: true
🚫 [FAKE GPS] Usuario cerró la alerta - Cerrando aplicación
```

## 🧪 Cómo Probar

### 1. Probar con Ubicación Real:
```bash
flutter run -d <device_id>
```
- La app debe funcionar normalmente
- Login debe permitirse
- No debe mostrar alertas

### 2. Probar con Fake GPS:
1. Instalar app de Fake GPS (ej: Fake GPS Location)
2. Activar ubicación simulada
3. Ejecutar la app
4. Verificar que:
   - ✅ Muestra banner rojo
   - ✅ Muestra alerta modal
   - ✅ Bloquea el login
   - ✅ Cierra la app al presionar "Entendido"

## 📝 Notas Importantes

1. **Solo funciona en Android**: La detección de `isMocked` es específica de Android
2. **Requiere permisos**: El usuario debe otorgar permisos de ubicación
3. **Verificación en tiempo real**: Se verifica cada vez que se intenta hacer login
4. **Cierre de app**: Usa `SystemNavigator.pop()` para cerrar completamente

## 🔄 Mejoras Futuras Posibles

- [ ] Implementar detección en iOS (diferente método)
- [ ] Agregar verificación periódica en background
- [ ] Registrar intentos de acceso con Fake GPS
- [ ] Enviar alertas al servidor sobre intentos sospechosos
- [ ] Implementar lista blanca de ubicaciones permitidas
- [ ] Agregar verificación de root/jailbreak

## 📚 Referencias

- [Geolocator Package](https://pub.dev/packages/geolocator)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
- [Android Location APIs](https://developer.android.com/training/location)
- [Flutter Security Best Practices](https://docs.flutter.dev/security)

---

**Implementado por:** Alexia Vanelli Ramirez Santana (233380)  
**Fecha:** Mayo 2026  
**Versión:** 1.0.0
