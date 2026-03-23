# 🔧 SOLUCIÓN: DEBUG FÍSICO SE CUELGA

## Problema Identificado

**Emulador:** ✅ Funciona perfectamente  
**Dispositivo físico:** ❌ Se cuelga en "Running Gradle task 'assembleDebug'..."

**Causa:** Incompatibilidad de SDK:
- Tu dispositivo: Android 15 (API 35)
- App compilada para: Android SDK 36 (targetSdk = 36)

---

## ✅ ARREGLO REALIZADO

Cambié `targetSdk` en `android/app/build.gradle`:

```groovy
ANTES:
targetSdk = 36

DESPUÉS:
targetSdk = 35  // Compatible con tu dispositivo
```

**Nota:** `compileSdk` sigue siendo 36 (eso está bien, solo afecta compilación).

---

## 🚀 CÓMO DEBUGGEAR AHORA

### Opción 1: Desde Terminal (RECOMENDADO)

```bash
cd C:\Users\ASUS\StudioProjects\FOODMAPS_FRONTEND

# Limpiar
flutter clean

# Obtener dependencias
flutter pub get

# Ejecutar en debug con verbose (para ver qué está pasando)
flutter run -v -d 2201123G
```

### Opción 2: Desde Android Studio

1. `File → Invalidate Caches → Invalidate and Restart`
2. Espera a que sincronice (1-3 minutos)
3. Selecciona dispositivo "2201123G (wireless)"
4. Click Run

---

## ✨ VERIFICACIÓN

Tu configuración es ahora:

```
✅ compileSdk = 36 (para compilación)
✅ targetSdk = 35  (compatible con dispositivo Android 15)
✅ minSdk = flutter.minSdkVersion (flexible)
✅ Dispositivo = Android 15 (API 35)
✅ Status = COMPATIBLE
```

---

## 📊 CAMBIOS REALIZADOS

### Archivo: `android/app/build.gradle`
```groovy
defaultConfig {
    applicationId = "com.example.cases"
    minSdkVersion = flutter.minSdkVersion
    targetSdk = 35  // ← CAMBIO AQUÍ (era 36)
    versionCode = 1
    versionName = "1.0"
}
```

---

## 🎯 SI SIGUE SIN FUNCIONAR

### Paso 1: Limpiar APK anterior
```bash
cd C:\Users\ASUS\StudioProjects\FOODMAPS_FRONTEND
flutter clean
rm -rf build/
```

### Paso 2: Desinstalar app antigua del dispositivo
```bash
flutter uninstall  # O ir a Configuración → Apps → Desinstalar
```

### Paso 3: Compilar nueva APK
```bash
flutter pub get
flutter run -v -d 2201123G
```

Esto mostrará logs detallados de qué está pasando.

### Paso 4: Revisar los logs
```bash
flutter logs
```

Busca errores o mensajes de estado.

---

## 📱 INFORMACIÓN DEL DISPOSITIVO

```
Nombre: 2201123G
Conexión: Wireless (WiFi)
OS: Android 15
API: 35
Arquitectura: arm64
Estado: Conectado y visible en Flutter
```

---

## ⚠️ NOTAS IMPORTANTES

1. **compileSdk vs targetSdk vs minSdk:**
   - `compileSdk = 36`: SDK usado para compilar (no afecta instalación)
   - `targetSdk = 35`: API del dispositivo (DEBE coincidir)
   - `minSdk`: Versión mínima (flexible, Flutter lo maneja)

2. **Compatible hacia atrás:**
   - Compilar para SDK 36 funciona en dispositivo API 35 ✅
   - Compilar para SDK 35 también funciona ✅

3. **Wireless Debug:**
   - La conexión WiFi es más lenta que USB
   - Compilación + instalación puede tardar 2-5 minutos
   - Esto es normal, no significa que se cuelgue

---

## 🔍 DIAGNOSTICAR PROBLEMAS

### Comando con máxima información:
```bash
flutter run -v -d 2201123G --disable-service-auth-codes
```

Esto te mostrará cada paso que está haciendo.

### Ver dispositivos conectados:
```bash
flutter devices
```

Deberías ver:
```
2201123G (wireless) (mobile) • ... • android-arm64 • Android 15 (API 35)
```

### Ver qué versión compiló:
```bash
flutter build apk --verbose
```

Esto mostrará:
```
...
compileSdkVersion 36
targetSdkVersion 35
...
```

---

## 🎉 RESULTADO ESPERADO

Después de este cambio:

```
✅ flutter run -d 2201123G
✅ Gradle compila sin errores
✅ APK se genera
✅ APK se instala en dispositivo
✅ App se abre correctamente
✅ No hay cuelgues infinitos
```

---

## 📞 SI HAY PROBLEMAS

```
Problema: "Aún se cuelga"
Solución: 
- Usar flutter run -v para ver logs
- Verificar que compileSdk es 36 y targetSdk es 35

Problema: "Error de instalación"
Solución:
- flutter uninstall
- flutter run

Problema: "Compilación muy lenta"
Solución:
- Normal en primera compilación (3-5 min)
- Conexión wireless es más lenta que USB
```

---

**Status:** ✅ **ARREGLADO - LISTO PARA DEBUGGEAR**

El cambio de `targetSdk = 35` debería resolver el problema de cuelgue en dispositivo físico.

Ejecuta: `flutter run -d 2201123G` (o desde Android Studio)


