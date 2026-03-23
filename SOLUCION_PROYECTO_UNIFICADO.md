# 🔧 SOLUCIÓN: CLIENTS DEBEN ESTAR EN EL MISMO PROYECTO

## 🔴 ERROR ACTUAL

```
Server returned error: Android clients and Web clients (server client ID) must be in the same project
```

**Problema:** El `google-services.json` tiene un client ID web/server que pertenece a un proyecto diferente al proyecto donde está registrado el client ID de Android.

---

## 🎯 CAUSA DEL PROBLEMA

Tu `google-services.json` contiene:
```json
"oauth_client": [
  {
    "client_id": "694127351749-oq023jfre25981d8bitc7bqolm2igp3s.apps.googleusercontent.com",
    "client_type": 3  // ← Este es un client ID web/server
  }
]
```

Este client ID web/server **NO está en el mismo proyecto** que tu client ID de Android.

---

## ✅ SOLUCIÓN: UNIFICAR PROYECTOS

### PASO 1: Verifica tu proyecto actual

Ve a Google Cloud Console:
```
https://console.cloud.google.com/
```

**¿Qué proyecto ves seleccionado?** Anota el nombre del proyecto.

### PASO 2: Verifica que TODOS los client IDs estén en el mismo proyecto

#### 2.1 Busca el client ID de Android
- APIs & Services → Credentials
- Busca tu OAuth 2.0 Client ID para Android
- Debe tener:
  - Package name: `com.foodmaps.app`
  - SHA-1: `B1:E9:AF:08:12:32:6E:1A:4C:69:81:07:9F:67:B7:A8:13:F1:CE:65`

#### 2.2 Busca el client ID web/server
- En el mismo proyecto, busca client IDs de tipo "Web application"
- El client ID debe empezar con el mismo número de proyecto

**Si NO encuentras el client ID web en el mismo proyecto:**

### PASO 3: Crea un nuevo client ID web en el mismo proyecto

1. **APIs & Services → Credentials**
2. **Create Credentials → OAuth 2.0 Client ID**
3. **Selecciona "Web application"**
4. **Nombre:** "FoodMaps Web Client"
5. **Authorized JavaScript origins:** (puedes dejar vacío por ahora)
6. **Authorized redirect URIs:** (puedes dejar vacío por ahora)
7. **Create**

### PASO 4: Actualiza Firebase

Ve a Firebase Console:
```
https://console.firebase.google.com/
```

1. **Selecciona el MISMO proyecto**
2. **Project Settings → Apps**
3. **Si no tienes app web, crea una:**
   - Add app → Web app
   - Nombre: "FoodMaps Web"
   - Firebase hosting: No (por ahora)
4. **Descarga el nuevo `google-services.json`**

### PASO 5: Reemplaza el google-services.json

1. **Descarga el nuevo archivo de Firebase**
2. **Reemplaza** `android/app/google-services.json`
3. **Verifica** que tenga el package name correcto: `"com.foodmaps.app"`

---

## 🔍 VERIFICACIÓN

### Cómo saber si está correcto:

1. **Abre** `google-services.json`
2. **Busca** todos los `"client_id"` en el archivo
3. **Todos deben** empezar con el mismo número de proyecto (ej: `694127351749-...`)

### Ejemplo correcto:
```json
{
  "client": [
    {
      "client_info": {
        "android_client_info": {
          "package_name": "com.foodmaps.app"
        }
      },
      "oauth_client": [
        {
          "client_id": "694127351749-ANDROID_CLIENT_ID.apps.googleusercontent.com",
          "client_type": 1
        },
        {
          "client_id": "694127351749-WEB_CLIENT_ID.apps.googleusercontent.com",
          "client_type": 3
        }
      ]
    }
  ]
}
```

---

## 🚀 DESPUÉS DE CORREGIR

```bash
flutter clean && flutter pub get && flutter run
```

**Espera 15 minutos** después de hacer cambios en Google Console.

---

## 📊 ESTADO ACTUAL

| Componente | Estado | Acción Necesaria |
|------------|--------|------------------|
| Proyecto Google Cloud | ❓ Verificar | Asegúrate de usar el mismo proyecto |
| Client ID Android | ✅ Registrado | Package: com.foodmaps.app |
| Client ID Web | ❌ Conflicto | Debe estar en el mismo proyecto |
| google-services.json | ⚠️ Incorrecto | Descargar nuevo de Firebase |

---

## 🎯 RESUMEN DE ACCIONES

1. **Verifica** que uses el mismo proyecto en Google Cloud y Firebase
2. **Crea** client ID web en el mismo proyecto (si no existe)
3. **Descarga** nuevo `google-services.json` de Firebase
4. **Reemplaza** el archivo en `android/app/`
5. **Reconstruye** la app
6. **Espera 15 minutos** y prueba

---

## 📞 SI SIGUES TENIENDO PROBLEMAS

### Verifica el project_id
- Abre `google-services.json`
- Busca `"project_id": "tu-proyecto-id"`
- Asegúrate de que este sea el proyecto correcto en Google Console

### Verifica que no haya proyectos mezclados
- Solo usa UN proyecto para todo
- No mezcles client IDs de diferentes proyectos

### Si nada funciona
- Crea un nuevo proyecto en Google Cloud
- Registra todo desde cero en el nuevo proyecto
- Descarga nuevo google-services.json

---

**¡El problema es que tienes client IDs de proyectos diferentes mezclados!** 🔧

Arregla esto unificando todo en el mismo proyecto y funcionará.
