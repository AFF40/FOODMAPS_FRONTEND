# 🎯 EL CAMBIO MÁS IMPORTANTE

## TL;DR (Resumen Ejecutivo)

**Tu aplicación se colgaba porque:**
1. Estaba configurada para emulador Android (`10.0.2.2`)
2. Tu dispositivo físico no podía acceder a esa dirección
3. Sin timeouts, esperaba indefinidamente

**Lo que hicimos:**
```dart
// ANTES (Emulador solo):
static const String apiBaseUrl = 'http://10.0.2.2:8000/api';

// DESPUÉS (Configurable):
static const String _serverHost = 'localhost';  // ← CAMBIA ESTO
static const String apiBaseUrl = 'http://$_serverHost:8000/api';
```

**Resultado:** Funciona en emulador, dispositivo físico, y localhost.

---

## ¿POR QUÉ `10.0.2.2`?

```
Emulador Android:
┌─────────────────────────────────────┐
│ Máquina Virtual (Emulador)          │
│ ┌──────────────────────────────────┐│
│ │  App Flutter                     ││
│ │  (ve el mundo desde adentro)     ││
│ └──────────────────────────────────┘│
│                                     │
│  Para hablar con host (PC):         │
│  → Usa 10.0.2.2 (alias mágico)    │
└─────────────────────────────────────┘

Dispositivo Físico:
┌─────────────────────────────────────┐
│  Teléfono Real en Red Local         │
│ ┌──────────────────────────────────┐│
│ │  App Flutter                     ││
│ │  (ve la red real)                ││
│ └──────────────────────────────────┘│
│                                     │
│  Para hablar con servidor:          │
│  → Usa 192.168.1.100 (IP real)    │
│  → NO funciona 10.0.2.2            │
└─────────────────────────────────────┘
```

---

## EL CAMBIO CLAVE

### Archivo: `lib/core/config/config.dart`

```dart
// ANTIGUO (líneas 1-2)
static const String apiBaseUrl = 'http://10.0.2.2:8000/api';
static const String storageBaseUrl = 'http://10.0.2.2:8000/storage/';

// NUEVO (líneas 6-9)
static const String _serverHost = 'localhost';  // ← TÚ CAMBIAS ESTO
static const int _serverPort = 8000;

static const String apiBaseUrl = 'http://$_serverHost:$_serverPort/api';
static const String storageBaseUrl = 'http://$_serverHost:$_serverPort/storage/';
```

### ¿Qué Cambiar?

**Si usas emulador:**
```dart
static const String _serverHost = '10.0.2.2';
```

**Si usas dispositivo físico:**
```dart
static const String _serverHost = '192.168.1.100';  // Tu IP local
```

**Si usas localhost:**
```dart
static const String _serverHost = 'localhost';
```

---

## EJEMPLOS REALES

### Ejemplo 1: Laptop + Emulador Android
```
Laptop (Windows):
  IP: 192.168.1.100
  Servidor corriendo en: http://localhost:8000

Emulador Android corriendo en la laptop:
  
  Debe usar: 10.0.2.2 (alias para localhost de la host)
  
  Código:
  static const String _serverHost = '10.0.2.2';
```

### Ejemplo 2: Laptop + Teléfono en Red WiFi
```
Laptop (Windows):
  IP: 192.168.1.100
  Servidor corriendo en: http://localhost:8000

Teléfono (mismo WiFi):
  
  Debe usar: 192.168.1.100 (IP real de la laptop)
  
  Código:
  static const String _serverHost = '192.168.1.100';
```

### Ejemplo 3: Servidor Remoto
```
Servidor:
  IP: 195.201.94.123
  Dominio: api.myapp.com

Teléfono (cualquier lugar):
  
  Debe usar: 195.201.94.123 o api.myapp.com
  
  Código:
  static const String _serverHost = 'api.myapp.com';
  // o
  static const String _serverHost = '195.201.94.123';
```

---

## CÓMO ENCONTRAR TU IP LOCAL

### Windows
```powershell
ipconfig

Busca: "Dirección IPv4"
Ejemplo: 192.168.1.100
```

### Linux
```bash
ip addr show
# o
ifconfig

Busca inet bajo tu interface activo (eth0, wlan0, etc)
Ejemplo: 192.168.1.100
```

### Mac
```bash
ifconfig

Busca inet bajo en.X (ethernet) o en1 (wifi)
Ejemplo: 192.168.1.100
```

---

## VERIFICAR QUE FUNCIONA

### Método 1: Desde el Teléfono
```
1. Abre navegador
2. Ve a: http://192.168.1.100:8000/api/auth/me
3. Deberías ver:
   - Error 401 (Unauthorized) ✅ = ¡Conexión funciona!
   - Error 404 = Endpoint no existe
   - Connection refused ❌ = Servidor no accesible
```

### Método 2: Desde la Laptop
```bash
# Verifica que el servidor está corriendo
curl http://localhost:8000/api/auth/me

# Deberías ver respuesta (error 401 es ok)
```

### Método 3: Desde la App
```
1. Abre la app
2. Intenta iniciar sesión
3. Si ves error de timeout → IP incorrecta o servidor apagado
4. Si ves error de autenticación → ¡Conexión OK!
```

---

## LOS OTROS CAMBIOS IMPORTANTES

Además del host, también agregamos:

### Timeouts (15 segundos)
```dart
// Antes: esperaba indefinidamente
final response = await http.get(url);

// Después: máximo 15 segundos
final response = await http
    .get(url)
    .timeout(AppConfig.httpTimeout);
```

### WebSocket Resiliente
```dart
// Antes: se colgaba si fallaba
_channel = WebSocketChannel.connect(uri);

// Después: reintentos automáticos
try {
  _channel = WebSocketChannel.connect(uri);
} catch (e) {
  Future.delayed(Duration(seconds: 5), _connectWebSocket);
}
```

### Manejo de Errores
```dart
// Antes: silencio total
} catch (e) { }

// Después: feedback al usuario
} on TimeoutException {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Servidor no responde'))
  );
}
```

---

## RESUMEN DE CAMBIOS

| Aspecto | Antes | Después |
|---------|-------|---------|
| **Host** | `10.0.2.2` (solo emulador) | Configurable |
| **Timeout HTTP** | ∞ (indefinido) | 15 segundos |
| **Timeout WS** | ∞ (indefinido) | 10 segundos |
| **Errores** | Silenciosos | Con mensajes |
| **WebSocket** | Se cuelga | Con reintentos |
| **Dispositivos** | Solo emulador | Emulador + Físico |

---

## PASO A PASO: CONFIGURAR PARA TU CASO

### Caso 1: Emulador Android
```
1. Abre: lib/core/config/config.dart
2. Línea 6, cambia a: static const String _serverHost = '10.0.2.2';
3. Guarda
4. flutter clean && flutter pub get
5. flutter run
```

### Caso 2: Dispositivo Físico
```
1. En tu laptop, abre PowerShell/Terminal
2. Ejecuta: ipconfig (Windows) o ifconfig (Linux/Mac)
3. Anota tu IPv4: 192.168.x.x
4. Abre: lib/core/config/config.dart
5. Línea 6, cambia a: static const String _serverHost = '192.168.x.x';
6. Guarda
7. flutter clean && flutter pub get
8. flutter run
```

### Caso 3: Localhost (Mismo PC)
```
1. Abre: lib/core/config/config.dart
2. Línea 6, cambia a: static const String _serverHost = 'localhost';
3. Guarda
4. flutter clean && flutter pub get
5. flutter run
```

---

## DESPUÉS DEL CAMBIO

Tu app podrá:
- ✅ Ejecutarse en emulador
- ✅ Ejecutarse en dispositivo físico
- ✅ Conectar a localhost
- ✅ Conectar a servidor remoto
- ✅ Mostrar errores claros
- ✅ Hacer reintentos automáticos

---

## ¿PREGUNTAS?

**P: ¿Necesito cambiar el puerto 8000?**
R: Solo si tu servidor usa otro puerto. Cámbialo en `_serverPort`.

**P: ¿Puedo usar un nombre de dominio?**
R: Sí. `static const String _serverHost = 'api.tuapp.com';`

**P: ¿Y si cambio de IP después?**
R: Solo cambia la línea 6 del archivo config.dart.

**P: ¿Es seguro dejar 'localhost' por defecto?**
R: No. Debes cambiar según tu entorno antes de distribuir.

---

**ESTE ES EL CAMBIO MÁS IMPORTANTE. TODO LO DEMÁS DEPENDE DE ESTO.** 🎯


