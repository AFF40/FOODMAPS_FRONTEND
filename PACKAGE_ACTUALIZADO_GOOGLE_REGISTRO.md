# ✅ CAMBIO REALIZADO + INSTRUCCIONES GOOGLE CONSOLE

## ✅ PASO 1 COMPLETADO: Package Name Actualizado

He cambiado tu package name a **`com.foodmaps.app`** en:

```
✅ android/app/build.gradle
✅ android/app/src/main/AndroidManifest.xml
```

---

## 📋 TU INFORMACIÓN ACTUALIZADA

```
Package Name: com.foodmaps.app
SHA-1 Fingerprint: B1:E9:AF:08:12:32:6E:1A:4C:69:81:07:9F:67:B7:A8:13:F1:CE:65
Status: Listo para registrar en Google
```

---

## 🔐 PASO 2: REGISTRAR EN GOOGLE CONSOLE

### OPCIÓN A: Crear nuevo Client ID (Recomendado)

Si no tienes un Client ID registrado aún, crea uno nuevo:

1. **Ir a Google Cloud Console:**
   ```
   https://console.cloud.google.com/
   ```

2. **Selecciona tu proyecto** (el que uses para FoodMaps)

3. **Ir a "APIs & Services" → "Credentials"**

4. **Haz clic en "Create Credentials" → "OAuth 2.0 Client ID"**

5. **Selecciona "Android"**

6. **Ingresa estos datos:**
   ```
   Application name: FoodMaps
   Package name: com.foodmaps.app
   SHA-1 certificate fingerprint: B1:E9:AF:08:12:32:6E:1A:4C:69:81:07:9F:67:B7:A8:13:F1:CE:65
   ```

7. **Haz clic en "Create"**

8. **Copia el Client ID generado** (será algo como: `123456789012-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com`)

---

### OPCIÓN B: Editar Client ID Existente

Si ya tienes un Client ID para Android:

1. **Ir a Google Cloud Console:**
   ```
   https://console.cloud.google.com/
   ```

2. **Selecciona tu proyecto**

3. **Ir a "APIs & Services" → "Credentials"**

4. **Busca "OAuth 2.0 Client IDs" → "Android Client"**

5. **Haz clic en editar (pencil icon)**

6. **Actualiza:**
   ```
   Package name: com.foodmaps.app
   SHA-1 fingerprints: B1:E9:AF:08:12:32:6E:1A:4C:69:81:07:9F:67:B7:A8:13:F1:CE:65
   ```

7. **Haz clic en "Save"**

---

## 🔄 PASO 3: REGISTRAR EN FIREBASE (IMPORTANTE)

También necesitas registrar en Firebase:

1. **Ir a Firebase Console:**
   ```
   https://console.firebase.google.com/
   ```

2. **Selecciona tu proyecto**

3. **Ir a "Project Settings" (ícono de engranaje)**

4. **Ve a la pestaña "Apps"**

5. **Selecciona tu app Android**

6. **Desplácete a "SHA certificate fingerprints"**

7. **Si no está registrado el SHA-1, haz clic en "Add fingerprint"**

8. **Ingresa:**
   ```
   SHA-1: B1:E9:AF:08:12:32:6E:1A:4C:69:81:07:9F:67:B7:A8:13:F1:CE:65
   ```

9. **Haz clic en "Add"**

10. **Descarga el archivo `google-services.json` actualizado**

11. **Reemplaza el archivo en:**
    ```
    android/app/src/main/google-services.json
    ```

---

## 🚀 PASO 4: RECONSTRUIR LA APP

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

## ✅ PASO 5: VERIFICAR

1. Abre la app en tu dispositivo físico
2. Ve a la pantalla de Login
3. Intenta hacer clic en "Continuar con Google"
4. Debería funcionar sin ese error

Si aún ves error:
- Espera 15 minutos (a veces Google tarda en sincronizar)
- Verifica que el SHA-1 esté exactamente igual (incluyendo los dos puntos)
- Verifica que el package name sea exactamente `com.foodmaps.app`
- Asegúrate de descargar el nuevo `google-services.json` desde Firebase

---

## 📊 RESUMEN DE CAMBIOS

| Aspecto | Antes | Después |
|---------|-------|---------|
| Package Name | com.example.cases | com.foodmaps.app |
| SHA-1 | B1:E9:AF:08:12:32:6E:1A:4C:69:81:07:9F:67:B7:A8:13:F1:CE:65 | (Sin cambios) |
| Status | ❌ No registrado | ⏳ Esperando registro |

---

## 📝 ARCHIVOS MODIFICADOS

```
✅ android/app/build.gradle (applicationId)
✅ android/app/src/main/AndroidManifest.xml (package)
```

---

## 🎯 PRÓXIMO PASO

Registra en Google Console según las instrucciones arriba, y vuelve a intentar login con Google. ¡Debería funcionar!


