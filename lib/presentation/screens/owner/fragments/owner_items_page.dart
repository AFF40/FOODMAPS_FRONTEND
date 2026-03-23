import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../../../core/config/config.dart';
import 'add_item_page.dart';
import 'edit_item_page.dart';

class OwnerItemsPage extends StatefulWidget {
  final int businessId;

  const OwnerItemsPage({Key? key, required this.businessId}) : super(key: key);

  @override
  _OwnerItemsPageState createState() => _OwnerItemsPageState();
}

class _OwnerItemsPageState extends State<OwnerItemsPage> {
  List<dynamic> _items = [];
  bool _loading = true;
  int? _catalogId;

  @override
  void initState() {
    super.initState();
    _fetchBusinessDetails();
  }

  Future<void> _fetchBusinessDetails() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final url = AppConfig.getApiUrl(AppConfig.negocioDetalleEndpoint(widget.businessId));

    try {
      final response = await http
          .get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'})
          .timeout(AppConfig.httpTimeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        if (data['catalogos'] != null && data['catalogos'].isNotEmpty) {
           setState(() {
             _catalogId = data['catalogos'][0]['id'];
           });
        }
        if (_catalogId != null) {
          await _fetchItems();
        }
      }
    } on TimeoutException {
      print('Timeout al obtener datos del negocio');
    } catch (e) {
      // handle error
    } finally {
       setState(() => _loading = false);
    }
  }

  Future<void> _fetchItems() async {
    if (_catalogId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final url = AppConfig.getApiUrl(AppConfig.itemsEndpoint);

    try {
      final response = await http
          .get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'})
          .timeout(AppConfig.httpTimeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final filteredItems = (data as List).where((item) => item['catalogo_id'] == _catalogId).toList();
        setState(() => _items = filteredItems);
      }
    } on TimeoutException {
      print('Timeout al obtener items');
    } catch (e) {
      // handle error
    }
  }

  Future<void> _toggleAvailability(Map<String, dynamic> item) async {
    if (_catalogId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final url = AppConfig.getApiUrl(AppConfig.itemDetailEndpoint(item['id']));

    final payload = {
        'nombre': item['nombre'],
        'precio': item['precio'],
        'disponible': !(item['disponible'] == 1),
    };

    try {
        final response = await http.put(Uri.parse(url), headers: {'Content-Type':'application/json', 'Authorization': 'Bearer $token'}, body: jsonEncode(payload));
        if (response.statusCode == 200) {
            _fetchItems(); // Reload items
        } else {
            // Handle error
        }
    } catch (e) {
        // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  leading: item['imagen_url'] != null ? Image.network(AppConfig.getImageUrl(item['imagen_url'])) : const Icon(Icons.shopping_bag),
                  title: Text(item['nombre'] ?? 'Sin nombre'),
                  subtitle: Text('Bs. ${item['precio'] ?? '0'}'),
                  trailing: Switch(
                    value: item['disponible'] == 1,
                    onChanged: (value) => _toggleAvailability(item),
                  ),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditItemPage(item: item, businessId: widget.businessId, catalogId: _catalogId!))).then((_) => _fetchItems()),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddItemPage(businessId: widget.businessId, catalogId: _catalogId!))).then((_) => _fetchItems()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
