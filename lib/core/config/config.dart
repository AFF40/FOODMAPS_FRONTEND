class AppConfig {
  // CONFIGURACIÓN: Cambia estas URLs según tu entorno
  // Para desarrollo local: usa 'localhost' o la IP de tu máquina (ej: '192.168.1.100')
  // Para emulador Android: usa '10.0.2.2'
  // Para dispositivo físico: usa la IP local del servidor
  static const String _serverHost = '192.168.100.83'; // CAMBIA ESTO según tu servidor
  static const int _serverPort = 8000;
  
  static const String apiBaseUrl = 'http://$_serverHost:$_serverPort/api';
  static const String storageBaseUrl = 'http://$_serverHost:$_serverPort/storage/';

  // --- Timeouts para prevenir cuelgues ---
  static const Duration httpTimeout = Duration(seconds: 15);
  static const Duration websocketTimeout = Duration(seconds: 10);

  // --- Autenticación ---
  static const String registerEndpoint = '/auth/register';
  static const String verifyEndpoint = '/auth/verify';
  static const String sendCodeEndpoint = '/auth/send-code';
  static const String loginEndpoint = '/auth/login';
  static const String googleLoginEndpoint = '/auth/google';
  static const String logoutEndpoint = '/auth/logout';
  static const String meEndpoint = '/auth/me';

  // --- Gestión (Dueños/Admin) ---
  static const String negociosEndpoint = '/negocios/';
  static String negocioDetalleEndpoint(int id) => '/negocios/$id/';
  static String negocioChangeStatusEndpoint(int id) => '/negocios/$id/change-status/';

  static const String catalogosEndpoint = '/catalogos/';
  static String catalogoDetailEndpoint(int id) => '/catalogos/$id/';

  static const String itemsEndpoint = '/items/';
  static String itemDetailEndpoint(int id) => '/items/$id/';

  // --- Rutas Anidadas ---
  static String itemsPorCatalogoEndpoint(int negocioId, int catalogoId) => '/negocios/$negocioId/catalogos/$catalogoId/items/';

  // --- Endpoints Públicos (Clientes) ---
  static const String negociosPublicosEndpoint = '/clientes/negocios/';
  static String negocioPublicoDetailEndpoint(int id) => '/clientes/negocios/$id/';

  // --- Suscripciones y Pagos ---
  static const String planesEndpoint = '/planes/';
  static const String suscripcionesEndpoint = '/suscripciones/';
  static const String pagosEndpoint = '/pagos/';

  // --- Normalización ---
  static const String ciudadesEndpoint = '/ciudades/';
  static const String categoriasEndpoint = '/categorias/';
  static const String tiposItemEndpoint = '/tipos-item/';

  // --- WebSocket ---
  // NOTA: Para dispositivo físico, cambia 'localhost' por la IP del servidor
  static const String websocketBaseUrl = 'ws://$_serverHost:9000';
  static const String websocketChannelNegocios = 'negocios';

  // --- Métodos de Ayuda ---
  static String getApiUrl(String endpoint) => '$apiBaseUrl$endpoint';

  static String getImageUrl(String? imagen) {
    if (imagen == null || imagen.isEmpty) return '';
    if (imagen.startsWith('http')) return imagen;
    return storageBaseUrl + imagen;
  }
}
