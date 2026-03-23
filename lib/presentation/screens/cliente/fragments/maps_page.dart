import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_map_custom_windows/google_map_custom_windows.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../core/config/theme_provider.dart';
import '../../../../core/config/config.dart';
import '../../../widgets/business_info_window.dart';
import '../../public/catalog_screen.dart'; // Corregido

class MapsPage extends StatefulWidget {
  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  GoogleMapController? _mapController;
  final GoogleMapCustomWindowController _customController = GoogleMapCustomWindowController();
  final Set<Marker> _markers = {};
  List<Map<String, dynamic>> _businessesData = [];
  int _estadoFiltro = -1; // -1: todos, 0: cerrado, 1: abierto

  static final LatLng _defaultCenter = LatLng(-17.382202, -66.151789);

  bool? _lastIsDark;
  bool _mapStyleApplied = false;
  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    final isDesktop = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);

    if (isDesktop) {
      _fetchBusinessesFromApi();
    } else {
      _checkPermissionAndFetch();
    }
    _connectWebSocketChannel();
  }

  void _connectWebSocketChannel() {
    if (_channel != null) {
      try {
        _channel?.sink.close();
      } catch (e) {
        print('Error cerrando WebSocket anterior: $e');
      }
    }
    
    try {
      final wsUrl = AppConfig.websocketBaseUrl;
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      final subscribeMsg = {
        "event": "pusher:subscribe",
        "data": {"channel": AppConfig.websocketChannelNegocios}
      };
      
      _channel?.sink.add(jsonEncode(subscribeMsg));
      
      _channel?.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            if (data is Map && data.containsKey('event')) {
              if (data['event'] == 'status.updated') {
                _handleBusinessStatusUpdate(data['data']);
              } else if (data['event'] == 'pusher:ping') {
                _channel?.sink.add(jsonEncode({'event': 'pusher:pong', 'data': {}}));
              }
            }
          } catch (e) {
            print('Error procesando mensaje WebSocket: $e');
          }
        },
        onError: (error) {
          print('WebSocket Error: $error');
          // Reintentar conexión después de 5 segundos
          Future.delayed(const Duration(seconds: 5), _connectWebSocketChannel);
        },
        onDone: () {
          print('WebSocket Closed, intentando reconectar...');
          // Reintentar conexión después de 5 segundos
          Future.delayed(const Duration(seconds: 5), _connectWebSocketChannel);
        },
        cancelOnError: true,
      );
    } catch (e) {
      print('Error conectando WebSocket: $e');
      // Reintentar después de 5 segundos si hay error
      Future.delayed(const Duration(seconds: 5), _connectWebSocketChannel);
    }
  }

  void _handleBusinessStatusUpdate(dynamic eventData) {
    Map<String, dynamic>? parsedData = (eventData is String) ? jsonDecode(eventData) : eventData;
    if (parsedData != null && parsedData.containsKey('id') && parsedData.containsKey('estado')) {
      _updateBusinessMarker(parsedData['id'], parsedData['estado']);
    }
  }

  void _updateBusinessMarker(dynamic id, dynamic newState) {
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == id.toString());
      final business = _businessesData.firstWhere((b) => b['id'].toString() == id.toString(), orElse: () => {});
      if (business.isNotEmpty) {
        final marker = _createMarker(business);
        if(marker != null) _markers.add(marker);
      }
    });
  }

  Future<void> _applyMapStyle(bool isDark) async {
    if (_mapController == null) return;
    final stylePath = isDark ? 'assets/map_styles/map_style_no_labels_night.json' : 'assets/map_styles/map_style_no_labels.json';
    final style = await rootBundle.loadString(stylePath);
    await _mapController?.setMapStyle(style);
    _mapStyleApplied = true;
  }

  Future<void> _checkPermissionAndFetch() async {
    try {
      Position? position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        final status = await Permission.location.status;
        if (status.isGranted && await Geolocator.isLocationServiceEnabled()) {
          position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
        }
      }
      if (position != null) {
        _animateTo(position.latitude, position.longitude, 17);
      }
    } catch (e) {
      _animateTo(_defaultCenter.latitude, _defaultCenter.longitude, 15);
    }
    await _fetchBusinessesFromApi();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = !kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.macOS);
    return isDesktop ? _buildDesktopView(context) : _buildMobileView(context);
  }

  Widget _buildMobileView(BuildContext context) {
     return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        if (_mapController != null && (_lastIsDark != themeProvider.isDarkMode || !_mapStyleApplied)) {
          _applyMapStyle(themeProvider.isDarkMode);
        }
        _lastIsDark = themeProvider.isDarkMode;

        return SafeArea(
          child: Column(
            children: [
              _buildFilterChips(),
              Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: (controller) async {
                        _mapController = controller;
                        _mapStyleApplied = false;
                        await _applyMapStyle(themeProvider.isDarkMode);
                        _customController.googleMapController = controller;
                      },
                      initialCameraPosition: CameraPosition(target: _defaultCenter, zoom: 15),
                      markers: _markers,
                      myLocationEnabled: true,
                      onTap: (_) => _customController.hideInfoWindow!(),
                      onCameraMove: (_) => _customController.onCameraMove!(),
                    ),
                    CustomMapInfoWindow(
                      controller: _customController,
                      offset: const Offset(0, 30),
                      height: 170,
                      width: 180,
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopView(BuildContext context) {
    final filteredData = _businessesData.where((business) {
      final estado = business['estado'] is int ? business['estado'] : int.tryParse(business['estado'].toString()) ?? 1;
      if (_estadoFiltro == -1) return true;
      return estado == _estadoFiltro;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Negocios Disponibles'), centerTitle: true),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(child: BusinessDesktopTable(businessesData: filteredData, onCatalogPressed: _openCatalog)),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          spacing: 10,
          children: [
            FilterChip(label: 'Todos', isSelected: _estadoFiltro == -1, onSelected: () => _updateFilter(-1)),
            FilterChip(label: 'Abiertos', isSelected: _estadoFiltro == 1, onSelected: () => _updateFilter(1)),
            FilterChip(label: 'Cerrados', isSelected: _estadoFiltro == 0, onSelected: () => _updateFilter(0)),
          ],
        ),
      ),
    );
  }

  void _updateFilter(int filter) {
    setState(() {
      _estadoFiltro = filter;
      _updateMarkers();
    });
  }

  Future<void> _fetchBusinessesFromApi() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      print('No hay token disponible');
      return;
    }
    try {
      final url = AppConfig.getApiUrl(AppConfig.negociosPublicosEndpoint);
      final response = await http
          .get(
            Uri.parse(url),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(
            AppConfig.httpTimeout,
            onTimeout: () {
              print('Timeout al obtener negocios después de ${AppConfig.httpTimeout.inSeconds}s');
              throw TimeoutException('Timeout al conectar con el servidor');
            },
          );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _businessesData = List<Map<String, dynamic>>.from(data['data'] ?? []);
        _updateMarkers();
      } else {
        print('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } on TimeoutException {
      print('Timeout: No se pudo conectar al servidor. Verifica tu conexión y la URL del servidor.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Timeout: No se pudo conectar al servidor'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error al obtener negocios: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _updateMarkers() {
    _customController.hideInfoWindow!();
    _markers.clear();
    for (var business in _businessesData) {
      if (_estadoFiltro != -1 && business['estado'] != _estadoFiltro) continue;
      final marker = _createMarker(business);
      if (marker != null) _markers.add(marker);
    }
    setState(() {});
  }
  
  Marker? _createMarker(Map<String, dynamic> business) {
    final latLng = _decodeLatLng(business['ubicacion']?.toString());
    if (latLng == null) return null;

    final icon = (business['estado'] == 1) ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen) : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

    return Marker(
      markerId: MarkerId(business['id'].toString()),
      position: latLng,
      icon: icon,
      onTap: () {
        final infoWidget = BusinessInfoWindow(businessData: business, onCatalogPressed: () => _openCatalog(business));
        _customController.addInfoWindow!([infoWidget], [latLng]);
      },
    );
  }

  void _openCatalog(Map<String, dynamic> business) {
    _customController.hideInfoWindow!();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CatalogScreen(
          businessId: business['id'] as int? ?? 0,
          name: business['nombre'] ?? '',
          phone: business['celular']?.toString() ?? '',
          imageUrl: AppConfig.getImageUrl(business['imagen']?.toString()),
        ),
      ),
    );
  }

  LatLng? _decodeLatLng(String? ubicacion) {
    if (ubicacion == null || !ubicacion.contains(',')) return null;
    final parts = ubicacion.split(',');
    final lat = double.tryParse(parts[0]);
    final lng = double.tryParse(parts[1]);
    return (lat != null && lng != null) ? LatLng(lat, lng) : null;
  }
  
  Future<void> _animateTo(double lat, double lng, double zoom) async {
    await _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat, lng), zoom: zoom)));
  }
}

// --- Widgets Separados ---

class FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const FilterChip({required this.label, required this.isSelected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: Colors.red.shade400,
      backgroundColor: Colors.red.shade100,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.red.shade700),
    );
  }
}

class BusinessDesktopTable extends StatelessWidget {
  final List<Map<String, dynamic>> businessesData;
  final void Function(Map<String, dynamic>) onCatalogPressed;

  const BusinessDesktopTable({required this.businessesData, required this.onCatalogPressed});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Logo')),
        DataColumn(label: Text('Nombre')),
        DataColumn(label: Text('Ubicación')),
        DataColumn(label: Text('Estado')),
        DataColumn(label: Text('Acciones')),
      ],
      rows: businessesData.map((business) {
        return DataRow(cells: [
          DataCell(business['imagen'] != null ? Image.network(AppConfig.getImageUrl(business['imagen']), width: 40) : const Icon(Icons.storefront)),
          DataCell(Text(business['nombre'] ?? '')),
          DataCell(ElevatedButton(onPressed: () => _launchMaps(business['ubicacion']), child: const Text('Ver Mapa'))),
          DataCell(Text(business['estado'] == 1 ? 'Abierto' : 'Cerrado')),
          DataCell(ElevatedButton(onPressed: () => onCatalogPressed(business), child: const Text('Ver Catálogo'))),
        ]);
      }).toList(),
    );
  }

  void _launchMaps(String? ubicacion) async {
    if (ubicacion == null) return;
    final url = 'https://www.google.com/maps/search/?api=1&query=$ubicacion';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
} 
