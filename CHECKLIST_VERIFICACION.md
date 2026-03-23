# ✅ CHECKLIST DE VERIFICACIÓN

## ANTES DE EMPEZAR

Antes de ejecutar tu app, completa esta lista:

### 📍 Configuración Inicial

- [ ] Identifiqué la IP de mi servidor ejecutando `ipconfig` (Windows) o `ifconfig` (Linux/Mac)
- [ ] Anoté mi IP: `________________` (ejemplo: 192.168.1.100)
- [ ] Mi servidor está ejecutándose en puerto `8000` ✓
- [ ] El servidor responde correctamente

### 🔧 Cambios en el Código

- [ ] Abrí `lib/core/config/config.dart`
- [ ] Cambié `_serverHost` por mi IP: `'192.168.x.x'`
- [ ] Guardé el archivo
- [ ] Ejecuté `flutter clean`
- [ ] Ejecuté `flutter pub get`

### ✅ Validación de Cambios

- [ ] Sin errores de compilación
- [ ] `flutter analyze` muestra 0 errores críticos
- [ ] Los imports de `dart:async` están presentes
- [ ] No hay warnings de TimeoutException

---

## DURANTE LA EJECUCIÓN

### 🚀 Prueba de Arranque

- [ ] La app abre sin colgarse
- [ ] La pantalla de login aparece en menos de 5 segundos
- [ ] No hay spinner infinito

### 📡 Prueba de Conectividad

Intenta:
1. [ ] Inicia sesión en la app
2. [ ] Si ves "Tiempo de espera agotado" → El servidor no está accesible
3. [ ] Si ves "Inicio de sesión exitoso" → ¡Conexión OK!

### 🗺️ Prueba de Mapas (Cliente)

- [ ] La pantalla de mapas carga en menos de 15 segundos
- [ ] Los marcadores de negocios aparecen
- [ ] El filtro de estado funciona

### 📊 Prueba de Propietario

- [ ] El dashboard carga sin colgarse
- [ ] Los catálogos se muestran
- [ ] El cambio de estado funciona

---

## SOLUCIÓN DE PROBLEMAS

### ❌ Problema: "Tiempo de espera agotado"
```
Significa: El servidor no responde

Soluciones:
□ Verifica que el servidor esté corriendo
□ Verifica que tienes la IP correcta
□ Intenta ping: ping 192.168.x.x
□ Aumenta timeout a 30 segundos:
  static const Duration httpTimeout = Duration(seconds: 30);
```

### ❌ Problema: "No se pudo conectar"
```
Significa: No hay conexión de red

Soluciones:
□ Revisa que ambos (móvil y servidor) están en la MISMA red
□ Desactiva firewall temporalmente para probar
□ Intenta con localhost si está en el mismo PC:
  static const String _serverHost = 'localhost';
```

### ❌ Problema: App sigue colgándose
```
Soluciones:
□ Revisa logs: flutter logs
□ Busca "error" o "Exception"
□ Aumenta los timeouts
□ Limpia y reconstruye: flutter clean && flutter pub get
```

### ❌ Problema: WebSocket no conecta
```
Nota: WebSocket es OPCIONAL (para actualizaciones en tiempo real)
La app debe funcionar sin él

Si quieres que funcione:
□ Verifica que tienes un WebSocket corriendo en puerto 9000
□ O descomenta el error en los logs para ver qué falla
```

---

## VERIFICACIÓN FINAL

Marca cuando todo funcione:

### Login Screen
- [ ] Pantalla carga sin cuelgues
- [ ] Puedo escribir credenciales
- [ ] Botón "Ingresar" responde
- [ ] Login exitoso → Pantalla siguiente

### Client Home Screen
- [ ] Mapas cargan sin colgarse
- [ ] Marcadores se muestran
- [ ] Bottom navigation funciona
- [ ] Cambio de tab sin problemas

### Owner Home Screen
- [ ] Dashboard carga
- [ ] Catálogos visibles
- [ ] Items listados
- [ ] Cambio de estado funciona

### Settings
- [ ] Logout funciona
- [ ] Vuelve a login sin problemas

---

## LOGS ESPERADOS

Cuando todo está bien, en `flutter logs` verás:

```
I/flutter (xxxxx): [Mapa cargó]
I/flutter (xxxxx): [200] (respuestas exitosas)
```

Cuando hay errores, verás:

```
I/flutter (xxxxx): Timeout al obtener negocios
I/flutter (xxxxx): Error: [descripción]
W/flutter (xxxxx): WebSocket Error: [error]
```

---

## CHECKLIST DE PREPARACIÓN PARA PRODUCCIÓN

- [ ] Cambié `_serverHost` a IP correcta
- [ ] Probé login
- [ ] Probé mapas
- [ ] Probé cambio de estado (propietario)
- [ ] Revisé los logs
- [ ] No hay cuelgues
- [ ] Los timeouts funcionan

---

## INFORMACIÓN DE CONTACTO CON SERVIDOR

Mi servidor:
- **Host/IP**: `_________________________________`
- **Puerto**: `_________________________________`
- **URL API**: `_________________________________`
- **WebSocket**: `_________________________________`

---

## NOTAS ADICIONALES

Escribe aquí cualquier problema específico:

```
_____________________________________________________________

_____________________________________________________________

_____________________________________________________________

_____________________________________________________________
```

---

## RESUMEN DE ARCHIVOS MODIFICADOS

Total: **14 archivos de código** modificados

```
✅ lib/core/config/config.dart (centralización)
✅ lib/presentation/screens/auth/ (3 archivos)
✅ lib/presentation/screens/cliente/ (2 archivos)
✅ lib/presentation/screens/owner/ (6 archivos)
✅ lib/presentation/screens/public/ (1 archivo)
```

Documentación agregada:
```
✅ INICIO_RAPIDO.md
✅ CONFIGURACION_URLS.md
✅ RESUMEN_ARREGLOS.md
✅ CHECKLIST_VERIFICACION.md (este archivo)
```

---

## ¡LISTO! 🎉

Si marcaste todas las casillas anteriores sin problemas:

**✅ Tu aplicación está COMPLETAMENTE ARREGLADA**

- No se cuelga
- Maneja errores correctamente
- Funciona con dispositivos físicos
- Timeouts configurables
- WebSocket resiliente

¡A disfrutar! 🚀


