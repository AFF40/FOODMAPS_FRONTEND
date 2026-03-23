import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/config.dart';
import '../../../../core/config/theme_provider.dart';
import '../../../controllers/custom_info_window_controller.dart';
import '../../../widgets/business_info_window.dart';
import '../../../widgets/desktop_business_table.dart';
import '../../public/catalog_screen.dart';

class OwnerMapPage extends StatefulWidget {
  final int businessId;

  const OwnerMapPage({Key? key, required this.businessId}) : super(key: key);

  @override
  OwnerMapPageState createState() => OwnerMapPageState();
}

class OwnerMapPageState extends State<OwnerMapPage> {
  GoogleMapController? _mapController;
  final CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();
  
  Set<Marker> _markers = {};
  List<Map<String, dynamic>> _businessesData = [];
  int _filterState = -1; // -1: todos, 0: cerrado, 1: abierto

  @override
  void initState() {
    super.initState();
    _fetchBusinesses();
  }

  Future<void> _fetchBusinesses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return;

    final url = AppConfig.getApiUrl(AppConfig.negociosPublicosEndpoint);
    try {
      final response = await http
          .get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'})
          .timeout(AppConfig.httpTimeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        setState(() {
          _businessesData = data.cast<Map<String, dynamic>>();
          _updateMarkers();
        });
      }
    } on TimeoutException {
      print('Timeout al obtener negocios públicos');
    } catch (e) {
      // handle error
    }
  }

  void _updateMarkers() {
    final markers = <Marker>{};
    for (final business in _businessesData) {
      if (_filterState != -1 && business['estado'] != _filterState) continue;

      final latLng = _parseLatLng(business['ubicacion']);
      if (latLng != null) {
        markers.add(
          Marker(
            markerId: MarkerId(business['id'].toString()),
            position: latLng,
            icon: business['estado'] == 1 ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen) : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            onTap: () {
               _customInfoWindowController.showInfoWindow!([BusinessInfoWindow(businessData: business, onCatalogPressed: () => _openCatalog(business))], [latLng]);
            }
          )
        );
      }
    }
    setState(() => _markers = markers);
  }

  void updateBusinessStatus(int newStatus) {
    final business = _businessesData.firstWhere((b) => b['id'] == widget.businessId, orElse: () => {});
    if(business.isNotEmpty) {
      setState(() {
        business['estado'] = newStatus;
        _updateMarkers();
      });
    }
  }

  LatLng? _parseLatLng(String? location) {
    if (location == null || !location.contains(',')) return null;
    final parts = location.split(',');
    if (parts.length < 2) return null;
    final lat = double.tryParse(parts[0]);
    final lng = double.tryParse(parts[1]);
    if (lat != null && lng != null) return LatLng(lat, lng);
    return null;
  }
  
  void _openCatalog(Map<String, dynamic> business) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => CatalogScreen(businessId: business['id'], name: business['nombre'], phone: business['celular'], imageUrl: business['imagen'])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: const CameraPosition(
              target: LatLng(-17.38, -66.15), // Default to Cochabamba
              zoom: 12,
            ),
            markers: _markers,
          ),
          // Add other UI elements like filter buttons here
        ],
      ),
    );
  }
}
