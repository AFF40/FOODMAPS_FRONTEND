# 🚨 GOOGLE OAUTH2 ERROR - SOLUCIÓN FINAL

## 🔴 ERROR ACTUAL

```
Server returned error: This android application is not registered to use OAuth2.0
PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10: , null, null)
```

**Código de error 10 = DEVELOPER_ERROR** → La app no está registrada correctamente en Google Console.

---

## ✅ TU INFORMACIÓN ACTUAL

```
Package Name: com.foodmaps.app
SHA-1 Fingerprint: B1:E9:AF:08:12:32:6E:1A:4C:69:81:07:9F:67:B7:A8:13:F1:CE:65
```

---

## 🎯 SOLUCIÓN: REGISTRA EN GOOGLE CONSOLE

### PASO 1: Ve a Google Cloud Console
```
https://console.cloud.google.com/
```

### PASO 2: Selecciona tu proyecto
- Busca el proyecto que usas para FoodMaps
- Si no tienes proyecto, crea uno nuevo

### PASO 3: Ve a "APIs & Services" → "Credentials"

### PASO 4: Crea o edita OAuth 2.0 Client ID

#### Opción A: Si NO tienes un Client ID para Android
1. Haz clic en **"Create Credentials"** → **"OAuth 2.0 Client ID"**
2. Selecciona **"Android"**
3. Ingresa:
   ```
   Application name: FoodMaps App
   Package name: com.foodmaps.app
   SHA-1 certificate fingerprint: B1:E9:AF:08:12:32:6E:1A:4C:69:81:07:9F:67:B7:A8:13:F1:CE:65
   ```
4. Haz clic en **"Create"**
5. **Copia el Client ID generado** (será algo como: `123456789012-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com`)

#### Opción B: Si YA tienes un Client ID para Android
1. Busca el Client ID existente (normalmente se llama "Android Client")
2. Haz clic en el ícono de editar (lápiz)
3. Actualiza:
   ```
   Package name: com.foodmaps.app
   SHA-1 certificate fingerprints: B1:E9:AF:08:12:32:6E:1A:4C:69:81:07:9F:67:B7:A8:13:F1:CE:65
   ```
4. Haz clic en **"Save"**

---

## 🔥 PASO 5: REGISTRA EN FIREBASE (IMPORTANTE)

### 5.1 Ve a Firebase Console
```
https://console.firebase.google.com/
```

### 5.2 Selecciona tu proyecto

### 5.3 Ve a "Project Settings" (ícono de engranaje)

### 5.4 Ve a la pestaña "Apps"

### 5.5 Selecciona tu app Android

### 5.6 Ve a "SHA certificate fingerprints"

### 5.7 Agrega el SHA-1 si no está registrado
```
SHA-1: B1:E9:AF:08:12:32:6E:1A:4C:69:81:07:9F:67:B7:A8:13:F1:CE:65
```

### 5.8 Descarga el nuevo google-services.json
- Haz clic en **"Download google-services.json"**
- **Reemplaza el archivo** en tu proyecto:
  ```
  android/app/google-services.json
  ```

---

## 🚀 PASO 6: RECONSTRUYE LA APP

```bash
cd C:\Users\ASUS\StudioProjects\FOODMAPS_FRONTEND

# Limpiar
flutter clean

# Obtener dependencias
flutter pub get

# Reconstruir
flutter run
```

---

## ✅ PASO 7: VERIFICA QUE FUNCIONE

1. Abre la app en tu dispositivo
2. Ve a la pantalla de Login
3. Haz clic en "Continuar con Google"
4. **Debería funcionar sin errores**

Si aún falla:
- Espera 15 minutos (Google tarda en sincronizar)
- Verifica que el SHA-1 sea exacto (con los dos puntos)
- Verifica que el package name sea exactamente `com.foodmaps.app`
- Asegúrate de descargar el nuevo `google-services.json` de Firebase

---

## 📊 RESUMEN DE CAMBIOS

| Paso | Estado | Acción |
|------|--------|--------|
| Package name | ✅ Cambiado | `com.foodmaps.app` |
| SHA-1 | ✅ Obtenido | `B1:E9:AF:08:12:32:6E:1A:4C:69:81:07:9F:67:B7:A8:13:F1:CE:65` |
| Google Console | ⏳ PENDIENTE | Registrar OAuth 2.0 Client ID |
| Firebase | ⏳ PENDIENTE | Agregar SHA-1 y descargar google-services.json |
| Reconstruir | ⏳ PENDIENTE | `flutter clean && flutter run` |

---

## 🔍 CÓDIGOS DE ERROR GOOGLE SIGN-IN

| Código | Significado | Solución |
|--------|-------------|----------|
| 10 | DEVELOPER_ERROR | App no registrada en Console |
| 12500 | SIGN_IN_FAILED | SHA-1 incorrecto |
| 12501 | SIGN_IN_CANCELLED | Usuario canceló |
| 12502 | SIGN_IN_CURRENTLY_IN_PROGRESS | Ya hay un sign-in en progreso |

Tu error es **código 10** → Necesitas registrar la app en Google Console.

---

## 📞 SI NECESITAS AYUDA

### Problema: "No encuentro mi proyecto"
- Crea un nuevo proyecto en Google Cloud Console
- Luego registra la app ahí

### Problema: "Ya tengo registrado com.example.cases"
- Edita el Client ID existente y cambia el package name
- O crea uno nuevo con `com.foodmaps.app`

### Problema: "SHA-1 no coincide"
- El SHA-1 que te di es correcto para tu debug keystore
- Si usas release keystore, necesitarás el SHA-1 de ese keystore

### Problema: "Aún no funciona después de 15 minutos"
- Verifica que descargaste el nuevo `google-services.json`
- Verifica que reemplazaste el archivo en `android/app/`
- Intenta `flutter clean && flutter run`

---

## 🎯 PRÓXIMO PASO

1. **Registra en Google Console** (pasos arriba)
2. **Actualiza Firebase** (pasos arriba)
3. **Descarga nuevo google-services.json**
4. **Reemplaza el archivo**
5. **Reconstruye la app**
6. **Prueba Google Sign-In**

¡Una vez registrado, funcionará perfectamente!


