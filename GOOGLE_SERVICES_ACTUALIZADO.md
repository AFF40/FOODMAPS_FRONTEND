# ✅ GOOGLE-SERVICES.JSON ACTUALIZADO

## 🔧 Lo Que Hice

He actualizado el archivo `android/app/google-services.json` para que coincida con el nuevo package name **`com.foodmaps.app`**.

```
✅ Cambié: "package_name": "com.example.cases"
✅ Por: "package_name": "com.foodmaps.app"
```

---

## 🚀 AHORA PUEDES COMPILAR

```bash
flutter run
```

Debería compilar sin ese error de Google Services.

---

## ⚠️ IMPORTANTE: REGISTRAR EN GOOGLE CONSOLE

Aunque la app compilará ahora, **NECESITAS registrar el package name en Google Console** para que Google Sign-In funcione correctamente.

### REGISTRAR EN GOOGLE CLOUD CONSOLE

1. **Ve a:** https://console.cloud.google.com/

2. **Selecciona tu proyecto**

3. **Ir a "APIs & Services" → "Credentials"**

4. **Crear o editar OAuth 2.0 Client ID para Android**

5. **Asegúrate de tener:**
   ```
   Package name: com.foodmaps.app
   SHA-1: B1:E9:AF:08:12:32:6E:1A:4C:69:81:07:9F:67:B7:A8:13:F1:CE:65
   ```

6. **Si no existe, crea uno nuevo con esta información**

---

### REGISTRAR EN FIREBASE CONSOLE

También necesitas actualizar en Firebase:

1. **Ve a:** https://console.firebase.google.com/

2. **Selecciona tu proyecto**

3. **Ir a "Project Settings" → "Apps"**

4. **Selecciona tu app Android**

5. **Ve a "SHA certificate fingerprints"**

6. **Agrega el SHA-1 si no está:**
   ```
   B1:E9:AF:08:12:32:6E:1A:4C:69:81:07:9F:67:B7:A8:13:F1:CE:65
   ```

7. **Descarga el nuevo `google-services.json`** con el package name `com.foodmaps.app`

8. **Reemplaza el archivo en:**
   ```
   android/app/google-services.json
   ```

---

## 📋 RESUMEN

| Paso | Estado |
|------|--------|
| Actualizar android/app/build.gradle | ✅ Hecho |
| Actualizar AndroidManifest.xml | ✅ Hecho |
| Actualizar google-services.json | ✅ Hecho (temporalmente) |
| Registrar en Google Console | ⏳ **PENDIENTE** |
| Descargar nuevo google-services.json de Firebase | ⏳ **PENDIENTE** |
| Compilar y ejecutar | ✅ Ahora debería funcionar |

---

## 🎯 SIGUIENTE PASO

1. **Compila ahora:** `flutter run`
2. **Luego registra en Google Console** según las instrucciones arriba
3. **Descarga el nuevo google-services.json de Firebase**
4. **Reemplázalo y compila de nuevo**

Cuando termines con Google Console, el login con Google funcionará correctamente.

---

## 📚 DOCUMENTACIÓN RELACIONADA

- `SOLUCION_GOOGLE_OAUTH.md` - Solución completa
- `PACKAGE_ACTUALIZADO_GOOGLE_REGISTRO.md` - Instrucciones de registro


