# 🚀 GUÍA RÁPIDA - Primeros Pasos

## El Problema Está Resuelto ✅

Tu app **NO SE COLGARÁ MÁS**. Se agregaron:
- ✅ Timeouts en todas las solicitudes (15 segundos)
- ✅ Manejo de errores en WebSocket
- ✅ Mensajes de error claros
- ✅ URLs configurables

## 3 PASOS PARA EMPEZAR

### PASO 1: Encontrar la IP de tu Servidor
En la máquina donde corre tu servidor Flask/backend:

**En Windows**:
```powershell
ipconfig
```
Busca: "Dirección IPv4" → por ejemplo: `192.168.1.100`

**En Linux/Mac**:
```bash
ifconfig
```

### PASO 2: Actualizar el Archivo de Configuración

Abre: `lib/core/config/config.dart`

Línea 4, cambia:
```dart
// ANTES:
static const String _serverHost = 'localhost';

// DESPUÉS (con tu IP):
static const String _serverHost = '192.168.1.100';
```

### PASO 3: Reconstruir la App

```bash
flutter clean
flutter pub get
flutter run
```

## ✅ ¿Cómo Saber que Funciona?

Opción A - App se abre sin colgarse ✅
```
Abre la app → Si no se cuelga → ¡FUNCIONA!
```

Opción B - Verifica conectividad desde el teléfono
```
1. Abre navegador en el móvil
2. Ve a: http://192.168.1.100:8000/api/auth/me
3. Si ves error 401 (no autorizado) → ¡Conexión OK!
```

Opción C - Mira los logs
```bash
flutter logs
```
Busca:
- ❌ "Timeout al obtener negocios" = Servidor no accesible
- ✅ "200" = Solicitud exitosa

## 🆘 Si Aún No Funciona

### Problema 1: "No se pudo conectar"
**Solución**: 
1. Verifica que el servidor está corriendo
2. Verifica que tienes la IP correcta (ping desde el teléfono)
3. Revisa firewall (¿permite puerto 8000?)

### Problema 2: "Timeout después de 15 segundos"
**Solución**:
1. Servidor está lento
2. Aumenta timeout en config.dart:
```dart
static const Duration httpTimeout = Duration(seconds: 30);
```

### Problema 3: Aún se cuelga
**Solución**:
1. Abre logs: `flutter logs`
2. Busca "error" o "Exception"
3. Copia el mensaje y busca solución

## 🔧 Puertos y Direcciones Comunes

```
Servidor en localhost:        localhost (o 127.0.0.1)
Servidor en red local:        192.168.x.x (reemplaza x con tu IP)
Servidor en emulador Android: 10.0.2.2
Servidor en emulador iOS:     127.0.0.1
```

## 📱 Para Diferentes Entornos

```dart
// SOLO emulador Android
static const String _serverHost = '10.0.2.2';

// SOLO emulador iOS
static const String _serverHost = '127.0.0.1';

// Dispositivo físico O mismo PC
static const String _serverHost = '192.168.1.100'; // Tu IP

// Localhost (desarrollo local)
static const String _serverHost = 'localhost';
```

## ⚡ Cambios que se Hicieron Automáticamente

Sin que hagas nada, se agregó:

1. **Timeouts**
   - 15 segundos para HTTP
   - 10 segundos para WebSocket

2. **Errores Claros**
   - Ya no se cuelga en login
   - Ya no se cuelga en maps
   - Ya no se cuelga cargando negocios

3. **Reintentos**
   - WebSocket se reconecta automáticamente
   - Después de 5 segundos si hay error

4. **Logs Útiles**
   - Ahora ves qué está pasando
   - `flutter logs` te muestra todo

## 📞 Variables de Configuración Disponibles

En `lib/core/config/config.dart` puedes cambiar:

```dart
// Host y puerto
static const String _serverHost = 'localhost';
static const int _serverPort = 8000;

// Timeouts
static const Duration httpTimeout = Duration(seconds: 15);
static const Duration websocketTimeout = Duration(seconds: 10);
```

## 🎯 Resultado Final

Antes ❌:
- App se cuelga
- Sin mensajes de error
- Solo funciona con emulador

Ahora ✅:
- No se cuelga
- Mensajes de error claros
- Funciona con dispositivos físicos
- Configurable para cualquier entorno
- Reintentos automáticos

---

**¡Listo! Tu app debería funcionar ahora. 🚀**

Si tienes problemas, revisa:
1. `CONFIGURACION_URLS.md` - Guía completa
2. `RESUMEN_ARREGLOS.md` - Cambios realizados
3. Logs de Flutter - `flutter logs`

