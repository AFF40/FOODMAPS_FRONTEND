# 🐛 GUÍA DE DEBUG EN ANDROID STUDIO

## El Problema Original

Android Studio **no terminaba de compilar** la aplicación. Los errores eran:

```
❌ Java home inválido (JDK 17 Adoptium que no existe)
❌ AndroidManifest con Impeller opt-out deprecated
❌ Advertencias sobre SDK y Kotlin
```

## ✅ Lo que Arreglé

### 1. **JDK Configuration** (ARREGLADO)
```
ANTES:
org.gradle.java.home=C:\\Program Files\\Eclipse Adoptium\\jdk-17.0.18.8-hotspot

DESPUÉS:
org.gradle.java.home=C:\\Program Files\\Android\\Android Studio\\jbr
```

Archivo: `android/gradle.properties`

### 2. **Impeller Configuration** (ARREGLADO)
```
ANTES: (Nada, usando opt-out deprecated)

DESPUÉS: Agregado en AndroidManifest.xml
<meta-data
    android:name="io.flutter.embedding.android.EnableImpeller"
    android:value="true" />
```

Archivo: `android/app/src/main/AndroidManifest.xml`

---

## 🚀 AHORA CÓMO HACER DEBUG

### OPCIÓN 1: Desde Terminal (RECOMENDADO)

```bash
# 1. Limpiar build previos
flutter clean

# 2. Obtener dependencias
flutter pub get

# 3. Ejecutar en debug
flutter run
```

Esto debería compilar y ejecutar sin problemas.

### OPCIÓN 2: Desde Android Studio

1. **Abre el proyecto:**
   ```
   C:\Users\ASUS\StudioProjects\FOODMAPS_FRONTEND\android
   ```

2. **Espera a que Gradle termine de sincronizar** (puede tomar 1-3 minutos la primera vez)

3. **Selecciona el dispositivo físico** (2201123G wireless)

4. **Haz clic en "Run"** (botón verde de play)

---

## 📋 ARCHIVOS MODIFICADOS PARA COMPILACIÓN

```
✅ android/gradle.properties
   - Actualizada ruta del JDK

✅ android/app/src/main/AndroidManifest.xml
   - Agregado EnableImpeller=true

✅ android/settings.gradle (ya estaba bien)
   - Kotlin version 2.1.0

✅ android/app/build.gradle (ya estaba bien)
   - compileSdk = 36
   - targetSdk = 36
```

---

## ✨ CONFIGURACIÓN FINAL

Tu proyecto ahora tiene:
- ✅ JDK correcto (Android Studio JBR)
- ✅ Kotlin 2.1.0
- ✅ Android SDK 36
- ✅ Impeller habilitado
- ✅ Firebase configurado
- ✅ Google Maps API KEY configurada

---

## 🔧 SI SIGUE SIN FUNCIONAR

### Opción 1: Sincronizar Gradle nuevamente

En Android Studio:
```
File → Sync Now
```

O en terminal:
```bash
cd android
./gradlew --sync
```

### Opción 2: Limpiar caché completo

```bash
flutter clean
rm -rf build/
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

### Opción 3: Resetear Android Studio

```
File → Invalidate Caches → Invalidate and Restart
```

---

## 📊 VERIFICACIÓN

Ejecuta:
```bash
flutter doctor -v
```

Deberías ver:
```
✅ Android toolchain - develop for Android devices
✅ Java version OpenJDK Runtime Environment (build 21.x)
✅ Java binary at: C:\Program Files\Android\Android Studio\jbr\bin\java
```

---

## 🎯 TIEMPO DE BUILD ESPERADO

```
Primera compilación:  2-5 minutos (Gradle descarga dependencias)
Compilaciones siguientes: 30-60 segundos
Debug en dispositivo: +30 segundos para transferir e instalar
```

---

## 🆘 ERRORES COMUNES

### Error: "Invalid Java home"
**Solución:** Verificar que `gradle.properties` apunta a:
```
C:\\Program Files\\Android\\Android Studio\\jbr
```

### Error: "Kotlin version X.X.X not supported"
**Solución:** En `android/settings.gradle`:
```groovy
id "org.jetbrains.kotlin.android" version "2.1.0"
```

### Error: "compileSdk is not specified"
**Solución:** En `android/app/build.gradle`:
```groovy
android {
    compileSdk = 36
    targetSdk = 36
}
```

### Error: "Plugin X requires compileSdkVersion >= Y"
**Solución:** Actualizar a SDK 36 (ya está hecho)

---

## 💡 TIPS PARA DEBUG

### 1. Ver logs en tiempo real
```bash
flutter logs
```

### 2. Debug con logs en la app
En tu código:
```dart
print('Debug info: $variable');
```

### 3. Usar verbose
```bash
flutter run -v
```

Esto muestra todo lo que Gradle está haciendo.

### 4. Especificar dispositivo
```bash
flutter devices  # Ver dispositivos disponibles
flutter run -d 2201123G  # Ejecutar en dispositivo específico
```

---

## 📱 DISPOSITIVO FÍSICO

Tu dispositivo (`2201123G wireless`) está:
- ✅ Detectado por ADB
- ✅ Ejecutando Android 15 (API 35)
- ✅ Listo para debug

Asegúrate de:
1. Tener USB debugging habilitado
2. Tener "Instalar desde fuentes desconocidas" habilitado
3. Estar conectado por USB o WiFi (está en WiFi según `flutter doctor`)

---

## 🎉 RESULTADO

Después de estos cambios:
- ✅ Gradle compilará sin errores de JDK
- ✅ No habrá advertencias de Impeller
- ✅ Android Studio no se colgará compilando
- ✅ El debug debería funcionar correctamente
- ✅ La app se ejecutará en dispositivo físico

---

## 📞 SI NECESITAS AYUDA

```
Problema: Android Studio no compila
Solución: Ver este documento (LEE_ESTO)

Problema: Error de JDK
Solución: Verificar gradle.properties (línea 4)

Problema: Compilación lenta
Solución: flutter clean y esperar primera compilación

Problema: App no se instala
Solución: Verificar que AndroidManifest.xml es válido
```

---

**Estado: ✅ ARREGLADO**

Tu configuración de compilación ahora es correcta. Ejecuta:
```bash
flutter clean && flutter pub get && flutter run
```

Y Android Studio debería completar el debug sin problemas.

