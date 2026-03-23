# 🔐 SOLUCIÓN: GOOGLE OAUTH2 NO REGISTRADO

## 🔴 Problema

```
Error: This android application is not registered to use OAuth2.0
Server returned error: please confirm the package name and SHA-1 certificate fingerprint match
```

**Causa:** Tu aplicación no está registrada correctamente en Google Developer Console.

---

## ℹ️ Tu Información de App

```
Package Name: com.example.cases
SHA-1 Fingerprint: B1:E9:AF:08:12:32:6E:1A:4C:69:81:07:9F:67:B7:A8:13:F1:CE:65
```

---

## ✅ PASOS PARA ARREGLAR

### PASO 1: Cambiar Package Name (Recomendado)

Aunque `com.example.cases` es válido, es mejor cambiar a algo más profesional como `com.foodmaps.app` o `com.tucompañia.foodmaps`.

#### Opción A: Rápido (Mantener com.example.cases)
Solo ir al Paso 2 y registrar lo que tienes.

#### Opción B: Profesional (Cambiar a com.foodmaps.app)

**En `android/app/build.gradle`:**
```groovy
defaultConfig {
    applicationId = "com.foodmaps.app"  // Cambiar de "com.example.cases"
    minSdkVersion = flutter.minSdkVersion
    targetSdk = 35
    versionCode = 1
    versionName = "1.0"
}
```

**En `android/app/src/main/AndroidManifest.xml`:**
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.foodmaps.app">  <!-- Cambiar de "com.example.cases" -->
```

Si cambias el package name, **el SHA-1 permanece igual** (B1:E9:AF:08:12:32:6E:1A:4C:69:81:07:9F:67:B7:A8:13:F1:CE:65).

---

### PASO 2: Registrar en Google Developer Console

#### 2.1 Ir a Google Cloud Console
```
https://console.cloud.google.com/
```

#### 2.2 Selecciona tu proyecto
Busca el proyecto donde creaste las credenciales de OAuth.

#### 2.3 Ir a "APIs & Services" → "Credentials"

#### 2.4 Selecciona tu OAuth 2.0 Client ID (Android)

Debería mostrar algo como:
```
OAuth 2.0 Client IDs
Name: Android Client
```

#### 2.5 Editar la credencial Android

Haz clic en editar y asegúrate que está:

```
Package name: com.example.cases
SHA-1 certificate fingerprints: B1:E9:AF:08:12:32:6E:1A:4C:69:81:07:9F:67:B7:A8:13:F1:CE:65
```

**Si no existe, crear uno nuevo:**
1. "Create Credentials" → "OAuth 2.0 Client ID"
2. Selecciona "Android"
3. Ingresa:
   - Package name: `com.example.cases` (o el que uses)
   - SHA-1: `B1:E9:AF:08:12:32:6E:1A:4C:69:81:07:9F:67:B7:A8:13:F1:CE:65`
4. Create

#### 2.6 Copiar Client ID
Debería verse así:
```
123456789012-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com
```

---

### PASO 3: Verificar Firebase (si usas)

Si usas Firebase, también necesitas registrar ahí:

#### 3.1 Ir a Firebase Console
```
https://console.firebase.google.com/
```

#### 3.2 Selecciona tu proyecto

#### 3.3 Ir a "Project Settings"

#### 3.4 Ir a "Apps" y selecciona tu app Android

#### 3.5 Desplácese a "SHA certificate fingerprints"

Asegúrate que está registrado:
```
SHA-1: B1:E9:AF:08:12:32:6E:1A:4C:69:81:07:9F:67:B7:A8:13:F1:CE:65
```

Si no está, agrega:
1. Haz clic en "Add fingerprint"
2. Ingresa el SHA-1
3. Save

---

### PASO 4: Sincronizar cambios en Android Studio

```bash
cd C:\Users\ASUS\StudioProjects\FOODMAPS_FRONTEND

# Si cambiaste package name:
flutter clean
flutter pub get

# Reconstruir
flutter run
```

---

## 🔍 VERIFICAR QUE FUNCIONA

Después de registrar, vuelve a intentar login con Google. Debería funcionar sin ese error.

Si aún falla:
1. Verifica que el SHA-1 es exacto (incluyendo los dos puntos)
2. Verifica que el package name coincide exactamente
3. Espera 15 minutos (a veces tarda en sincronizar)
4. Reinicia la app

---

## 📊 RESUMEN

| Aspecto | Valor |
|---------|-------|
| **Package Name** | com.example.cases |
| **SHA-1** | B1:E9:AF:08:12:32:6E:1A:4C:69:81:07:9F:67:B7:A8:13:F1:CE:65 |
| **Estado** | Necesita registrarse en Google Console |

---

## 📞 SI CAMBIASTE PACKAGE NAME

**Nuevo package name recomendado:**
```
com.foodmaps.app
```

**Archivos a cambiar:**
1. `android/app/build.gradle` - applicationId
2. `android/app/src/main/AndroidManifest.xml` - package

**SHA-1:** Permanece igual (B1:E9:AF:08:12:32:6E:1A:4C:69:81:07:9F:67:B7:A8:13:F1:CE:65)

---

## 🎯 DESPUÉS DE REGISTRAR

1. ✅ Limpiar: `flutter clean`
2. ✅ Reconstruir: `flutter run`
3. ✅ Intentar login con Google
4. ✅ Debería funcionar sin errores

---

**Nota:** El debug keystore siempre genera el mismo SHA-1, así que no cambia aunque reconstruyas la app.


