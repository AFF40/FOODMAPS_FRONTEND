import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../../core/config/config.dart';

class BusinessSelectorScreen extends StatefulWidget {
  final List<Map<String, dynamic>> businesses;
  const BusinessSelectorScreen({Key? key, required this.businesses}) : super(key: key);

  @override
  State<BusinessSelectorScreen> createState() => _BusinessSelectorScreenState();
}

class _BusinessSelectorScreenState extends State<BusinessSelectorScreen> {
  List<Map<String, dynamic>> _businesses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.businesses.isNotEmpty) {
      _businesses = widget.businesses;
      _isLoading = false;
    } else {
      _fetchBusinesses();
    }
  }

  Future<void> _fetchBusinesses() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      // Handle no token
      return;
    }
    try {
      final url = AppConfig.getApiUrl(AppConfig.negociosEndpoint);
      final response = await http
          .get(
            Uri.parse(url),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(AppConfig.httpTimeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        setState(() => _businesses = data.cast<Map<String, dynamic>>());
      } else {
        // Handle error
      }
    } on TimeoutException {
      print('Timeout al obtener negocios');
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteBusiness(int businessId, String businessName) async {
    final bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Seguro que quieres eliminar "$businessName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final url = AppConfig.getApiUrl(AppConfig.negocioDetalleEndpoint(businessId));
    final response = await http.delete(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
    
    if (response.statusCode == 200) {
      setState(() => _businesses.removeWhere((b) => b['id'] == businessId));
      // Handle SharedPreferences update
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecciona un Negocio')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _businesses.length,
              itemBuilder: (context, index) {
                final business = _businesses[index];
                return ListTile(
                  leading: business['imagen'] != null ? Image.network(AppConfig.getImageUrl(business['imagen'])) : const Icon(Icons.storefront),
                  title: Text(business['nombre'] ?? 'Sin nombre'),
                  subtitle: Text(business['descripcion'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteBusiness(business['id'], business['nombre'] ?? 'Sin nombre'),
                  ),
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setInt('business_id', business['id']);
                    Navigator.pushReplacementNamed(context, '/owner_home', arguments: business['id']);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/new_business'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
