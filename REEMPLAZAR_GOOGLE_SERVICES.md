# ✅ REEMPLAZAR GOOGLE-SERVICES.JSON

## 🎯 LO QUE DEBES HACER

### PASO 1: Localiza el archivo descargado
- El archivo que descargaste de Firebase se llama **`google-services.json`**
- Normalmente se descarga en tu carpeta de **Descargas** o donde tengas configurado el navegador

### PASO 2: Copia el archivo nuevo
- Ve a la carpeta de tu proyecto:
  ```
  C:\Users\ASUS\StudioProjects\FOODMAPS_FRONTEND
  ```

- Entra a la carpeta `android/app/`

- **Reemplaza** el archivo `google-services.json` existente con el nuevo que descargaste de Firebase

### PASO 3: Verifica que el archivo nuevo tenga el package correcto
- Abre el archivo `google-services.json` que acabas de reemplazar
- Busca `"package_name"` en el archivo
- Debería decir: `"package_name": "com.foodmaps.app"`

---

## 📁 RUTA EXACTA DEL ARCHIVO

**Archivo a reemplazar:**
```
C:\Users\ASUS\StudioProjects\FOODMAPS_FRONTEND\android\app\google-services.json
```

**Archivo nuevo (el que descargaste de Firebase):**
```
C:\Users\ASUS\Downloads\google-services.json
```
*(o donde se haya descargado)*

---

## 🔍 CÓMO VERIFICAR QUE ESTÁ CORRECTO

### Opción 1: Abre el archivo JSON
```json
{
  "project_info": {
    "project_number": "...",
    "project_id": "tu-proyecto",
    "storage_bucket": "..."
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "...",
        "android_client_info": {
          "package_name": "com.foodmaps.app"  // ← DEBE DECIR ESTO
        }
      },
      "oauth_client": [
        {
          "client_id": "tu-client-id-de-google-console",
          "client_type": 3
        }
      ]
    }
  ]
}
```

### Opción 2: Busca en el archivo
- Abre el archivo con un editor de texto
- Busca: `com.foodmaps.app`
- Si lo encuentras, está correcto

---

## 🚀 DESPUÉS DE REEMPLAZAR

### Reconstruye la app
```bash
cd C:\Users\ASUS\StudioProjects\FOODMAPS_FRONTEND

# Limpiar
flutter clean

# Obtener dependencias
flutter pub get

# Ejecutar
flutter run
```

### Prueba Google Sign-In
1. Abre la app
2. Ve a Login
3. Haz clic en "Continuar con Google"
4. **Debería funcionar sin errores**

---

## ⚠️ ERRORES COMUNES

### Error: "Archivo no encontrado"
- Asegúrate de que descargaste el archivo de Firebase
- Busca en tu carpeta de Descargas

### Error: "Package name incorrecto"
- El archivo nuevo debe tener `"package_name": "com.foodmaps.app"`
- Si no, vuelve a Firebase y descarga de nuevo

### Error: "Aún no funciona"
- Espera 15 minutos después de registrar en Google Console
- Verifica que el SHA-1 esté agregado en Firebase

---

## 📊 CHECKLIST

- [ ] Descargué `google-services.json` de Firebase
- [ ] Reemplacé el archivo en `android/app/google-services.json`
- [ ] Verifiqué que dice `"package_name": "com.foodmaps.app"`
- [ ] Ejecuté `flutter clean && flutter pub get && flutter run`
- [ ] Probé Google Sign-In en la app

---

## 🎯 RESULTADO ESPERADO

Después de reemplazar el archivo y reconstruir:

```
✅ Google Sign-In funciona sin errores
✅ No más "not registered to use OAuth2.0"
✅ Login con Google exitoso
```

---

**¡Solo reemplaza el archivo y listo!** 🚀

¿Necesitas ayuda para encontrar el archivo descargado?
