# ✅ GOOGLE-SERVICES.JSON ACTUALIZADO - NUEVO PROYECTO

## ✅ LO QUE HICIMOS

Tu `google-services.json` **ya está actualizado** con el nuevo proyecto:

```json
"project_id": "foodmaps-388314"
"package_name": "com.foodmaps.app"
```

---

## ⚠️ PROBLEMA ACTUAL

El `oauth_client` está vacío:
```json
"oauth_client": []
```

Necesitamos crear un **Client ID web** en Google Cloud Console para que Google Sign-In funcione.

---

## 🎯 PASOS PARA CREAR CLIENT ID WEB

### PASO 1: Ve a Google Cloud Console
```
https://console.cloud.google.com/
```

### PASO 2: Selecciona el proyecto `foodmaps-388314`
- Asegúrate de que el proyecto seleccionado sea **foodmaps-388314**
- (Este es tu nuevo proyecto)

### PASO 3: Ve a "APIs & Services" → "Credentials"

### PASO 4: Crea un nuevo OAuth 2.0 Client ID
1. **Create Credentials** → **OAuth 2.0 Client ID**
2. **Selecciona "Web application"**
3. **Nombre:** "FoodMaps Web Client"
4. **Authorized JavaScript origins:** (puedes dejar vacío)
5. **Authorized redirect URIs:** (puedes dejar vacío)
6. **Create**

### PASO 5: Copia el Client ID generado
- Se mostrará algo como: `123456789012-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com`
- **Anota este Client ID** (lo necesitarás)

### PASO 6: Descarga el nuevo google-services.json
1. **Ve a Firebase:** https://console.firebase.google.com/
2. **Selecciona el proyecto `foodmaps-388314`**
3. **Project Settings → Apps**
4. **Selecciona tu app Android**
5. **Descarga el nuevo `google-services.json`**

### PASO 7: Reemplaza el archivo (otra vez)
- El nuevo google-services.json tendrá el `oauth_client` con los datos correctos

---

## 📊 ESTADO ACTUAL

| Componente | Estado |
|------------|--------|
| Proyecto Firebase | ✅ `foodmaps-388314` |
| Package Name | ✅ `com.foodmaps.app` |
| SHA-1 | ✅ `B1:E9:AF:08:12:32:6E:1A:4C:69:81:07:9F:67:B7:A8:13:F1:CE:65` |
| Client ID Android | ✅ Registrado |
| Client ID Web | ⏳ **PENDIENTE** (crear en Google Console) |
| google-services.json | ⚠️ Incompleto (sin oauth_client) |

---

## 🚀 PRÓXIMOS PASOS

1. **Crea Client ID web** en Google Cloud Console (pasos arriba)
2. **Descarga nuevo google-services.json** de Firebase
3. **Reemplaza el archivo** en `android/app/`
4. **Reconstruye:**
   ```bash
   flutter clean && flutter pub get && flutter run
   ```
5. **Espera 15 minutos** y prueba Google Sign-In

---

## 💡 NOTA IMPORTANTE

Asegúrate de que todos tus client IDs (Android y Web) estén en el **MISMO PROYECTO** (`foodmaps-388314`). Esto es lo que causaba el error anterior.


