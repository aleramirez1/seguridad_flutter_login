# 📱 Wipe Remoto - Limpieza Remota de Datos Sensibles

## ✅ Implementación Completa

### 🔐 Campos Sensibles (4 campos):
1. **Email** - `user_email`
2. **Contraseña** - `password`
3. **Tarjeta de Crédito** - `credit_card`
4. **Número de Seguro Social** - `ssn`

---

## 🚀 Cómo Usar la Aplicación

### 1. Ejecutar la App
```bash
flutter pub get
flutter run
```

### 2. Primera Vez
Al abrir la app por primera vez:
- ✅ Se generan automáticamente datos de ejemplo
- ✅ Se crea un `userId` único para el dispositivo
- ✅ Se obtiene el `FCM Token`

### 3. Datos Visibles en la App
La pantalla muestra:
- **User ID**: Identificador único del dispositivo
- **FCM Token**: Token para enviar notificaciones
- **4 Campos Sensibles**: Email, Contraseña, Tarjeta, SSN

### 4. Funciones Disponibles
- ✏️ **Editar campos**: Modificar cualquier dato sensible
- 💾 **Guardar Cambios**: Actualizar los datos encriptados
- 🔄 **Generar Datos de Ejemplo**: Rellenar con datos automáticos
- 🗑️ **Eliminar Todos**: Borrado manual local

---

## 🔥 Enviar Notificación de Borrado Remoto

### ⚠️ IMPORTANTE
La notificación **DEBE** incluir el `userId` específico del dispositivo. Solo se borrarán los datos si el `userId` coincide.

### Opción 1: Desde Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto `tests-abe52`
3. Ve a **Cloud Messaging** → **Send your first message**
4. **Título**: `Alerta de Seguridad`
5. **Mensaje**: `Se eliminaran tus datos sensibles`
6. Ve a **Additional options** → **Custom data**
7. Agrega:
   - Key: `action` → Value: `DELETE_DATA`
   - Key: `userId` → Value: `[COPIA EL USER ID DE LA APP]`
8. En **Target**: pega el **FCM Token** de la app
9. Envía la notificación

### Opción 2: cURL desde Terminal

Reemplaza los valores entre `< >`:

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=<TU_SERVER_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "<FCM_TOKEN_DE_LA_APP>",
    "data": {
      "action": "DELETE_DATA",
      "userId": "<USER_ID_DE_LA_APP>"
    },
    "notification": {
      "title": "Alerta de Seguridad",
      "body": "Borrado remoto activado"
    }
  }'
```

### Opción 3: PowerShell (Windows)

```powershell
$serverKey = "TU_SERVER_KEY"
$fcmToken = "FCM_TOKEN_DE_LA_APP"
$userId = "USER_ID_DE_LA_APP"

$headers = @{
    "Authorization" = "key=$serverKey"
    "Content-Type" = "application/json"
}

$body = @{
    to = $fcmToken
    data = @{
        action = "DELETE_DATA"
        userId = $userId
    }
    notification = @{
        title = "Alerta de Seguridad"
        body = "Borrado remoto activado"
    }
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://fcm.googleapis.com/fcm/send" `
                  -Method Post `
                  -Headers $headers `
                  -Body $body
```

---

## 🔍 Obtener Server Key de Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Haz clic en ⚙️ → **Project settings**
4. Ve a la pestaña **Cloud Messaging**
5. Copia el **Server key**

---

## 🧪 Casos de Prueba

### ✅ Test 1: Datos Automáticos
1. Abre la app
2. Verifica que los 4 campos tengan datos de ejemplo
3. Verifica que se muestre User ID y FCM Token

### ✅ Test 2: Editar y Guardar
1. Modifica cualquier campo
2. Presiona "Guardar Cambios"
3. Cierra y vuelve a abrir la app
4. Verifica que los cambios persistan

### ✅ Test 3: Borrado Remoto (Usuario Correcto)
1. Copia el **User ID** y **FCM Token** de la app
2. Envía notificación con el userId correcto
3. Verifica que los 4 campos se vacíen automáticamente

### ✅ Test 4: Borrado Remoto (Usuario Incorrecto)
1. Envía notificación con un userId diferente
2. Verifica que los datos NO se borren
3. Solo se borran si el userId coincide

### ✅ Test 5: Borrado en Background
1. Pon la app en segundo plano
2. Envía notificación de borrado
3. Abre la app
4. Verifica que los datos se hayan eliminado

---

## 📋 Formato de Notificación

```json
{
  "to": "FCM_TOKEN",
  "data": {
    "action": "DELETE_DATA",
    "userId": "abc-123-def-456"
  },
  "notification": {
    "title": "Título opcional",
    "body": "Mensaje opcional"
  }
}
```

### Campos Obligatorios:
- `data.action` = `"DELETE_DATA"`
- `data.userId` = El User ID específico del dispositivo

---

## 🎯 Características de Seguridad

✅ **Notificación Específica por Usuario**: Solo borra si el `userId` coincide
✅ **4 Campos Sensibles**: Email, Contraseña, Tarjeta, SSN
✅ **Almacenamiento Encriptado**: Usa Android Keystore / iOS Keychain
✅ **Auto-inicialización**: Datos de ejemplo al primer uso
✅ **Funciona en Background**: Borrado incluso si la app está cerrada

---

## 📊 Diferencia con Implementación Anterior

| Característica | Antes | Ahora |
|----------------|-------|-------|
| Campos | Genéricos clave-valor | 4 campos específicos sensibles |
| Inicialización | Manual | Automática con datos de ejemplo |
| Seguridad | Palabra clave genérica | userId específico por dispositivo |
| UI | Lista genérica | Formulario de campos sensibles |
| Verificación | Cualquier palabra clave | Solo si userId coincide |

---

**Implementado por**: Flutter + Firebase Cloud Messaging + Secure Storage
