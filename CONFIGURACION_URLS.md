# 🔧 Configuración de URLs para FoodMaps

## Problema Resuelto
La aplicación se quedaba cargando indefinidamente porque:
1. **URLs incorrectas**: Estaban configuradas para emulador (`10.0.2.2`), no para dispositivos físicos
2. **WebSocket sin timeout**: Se colgaba esperando conexión a `127.0.0.1:9000`
3. **Solicitudes HTTP sin timeout**: Sin límite de tiempo de espera

## ✅ Cambios Realizados

### 1. Actualización de Configuración (`lib/core/config/config.dart`)
- ✅ Agregados timeouts para todas las solicitudes HTTP (15 segundos)
- ✅ Agregados timeouts para WebSocket (10 segundos)
- ✅ Cambio de `10.0.2.2` a `localhost` como host por defecto
- ✅ WebSocket ahora con reintentos automáticos

### 2. Mejoras en Manejo de Errores
Se agregaron timeouts a todas las solicitudes HTTP en:
- ✅ `login_screen.dart` - Autenticación
- ✅ `register_screen.dart` - Registro
- ✅ `phone_verification_screen.dart` - Verificación
- ✅ `owner_home_screen.dart` - Pantalla de dueño
- ✅ `business_selector_screen.dart` - Selección de negocio
- ✅ `owner_items_page.dart` - Items del propietario
- ✅ `owner_settings_page.dart` - Configuración del propietario
- ✅ `owner_map_page.dart` - Mapa del propietario
- ✅ `new_business_screen.dart` - Nuevo negocio
- ✅ `edit_business_screen.dart` - Edición de negocio
- ✅ `catalog_screen.dart` - Catálogo público
- ✅ `settings_page.dart` - Configuración del cliente
- ✅ `maps_page.dart` - Mapa del cliente

### 3. Manejo de WebSocket Mejorado
- ✅ No se cuelga si WebSocket falla
- ✅ Reintentos automáticos después de 5 segundos
- ✅ Mensajes de error claros en logs

## 🔧 CÓMO CONFIGURAR PARA TU ENTORNO

### Para Emulador de Android
```dart
// En lib/core/config/config.dart, cambia:
static const String _serverHost = '10.0.2.2';
```

### Para Dispositivo Físico (Lo más común)
Necesitas la IP local de tu servidor en la red:

1. **En Windows (Servidor)**: Abre PowerShell y ejecuta:
```powershell
ipconfig
```
Busca la línea "Dirección IPv4" en tu adaptador de red activo (ej: `192.168.1.100`)

2. **En Linux/Mac (Servidor)**: Ejecuta:
```bash
ifconfig
```
o
```bash
ip addr show
```

3. **Actualiza la configuración en el código**:
```dart
// En lib/core/config/config.dart, cambia:
static const String _serverHost = '192.168.1.100'; // Usa tu IP local
```

### Para Localhost en Desarrollo
Si ejecutas el servidor en la misma máquina:
```dart
static const String _serverHost = 'localhost';
```

## 📋 Checklist de Configuración

- [ ] He identificado la IP o host de mi servidor
- [ ] He actualizado `_serverHost` en `lib/core/config/config.dart`
- [ ] Mi servidor está corriendo en el puerto 8000 (o he ajustado `_serverPort`)
- [ ] Verifiqué que puedo conectar desde mi dispositivo: `ping 192.168.x.x`
- [ ] Ejecuté `flutter clean && flutter pub get`
- [ ] Reconstruí la app con `flutter run`

## 🧪 Cómo Verificar que Funciona

1. Abre la app
2. Si no se cuelga en login → ¡Bien! Las URLs están correctas
3. Si ves timeouts → Verifica que el servidor esté ejecutándose
4. Si ves "No se pudo conectar" → Revisa que la IP/puerto sean correctos
5. Revisa la consola con `flutter logs` para más detalles

## 📊 Valores de Timeout

- **HTTP Timeout**: 15 segundos (puede parecer largo, pero da tiempo al servidor lento)
- **WebSocket Timeout**: 10 segundos (es opcional, se reintenta automáticamente)

Si tu servidor es lento, puedes aumentar estos valores en `config.dart`:
```dart
static const Duration httpTimeout = Duration(seconds: 30);
```

## ❓ Preguntas Frecuentes

**P: ¿Qué puerto usa mi servidor?**
R: Normalmente es `8000`. Si es diferente, actualiza `_serverPort` en config.dart

**P: ¿Por qué WebSocket no funciona?**
R: WebSocket es opcional (para actualizaciones en tiempo real). La app funcionará sin él.

**P: ¿Cómo verifico que mi servidor está accesible?**
R: Desde tu teléfono/emulador, abre el navegador e intenta:
```
http://192.168.1.100:8000/api/auth/me
```
Si ves una respuesta (error 401 es ok), la conexión funciona.

## 🆘 Si Sigue sin Funcionar

1. Verifica los logs: `flutter logs`
2. Asegúrate que el servidor esté realmente ejecutándose
3. Comprueba firewall: ¿permite conexiones en puerto 8000?
4. Intenta con `localhost` si estás en el mismo PC
5. Aumenta el timeout si el servidor responde muy lentamente

---

**Última actualización**: 2024  
**Estado**: ✅ Listo para usar

