import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../../core/config/config.dart';
import 'fragments/item_card.dart';

class CatalogScreen extends StatefulWidget {
  final int businessId;
  final String name;
  final String phone;
  final String imageUrl;

  const CatalogScreen({
    Key? key,
    required this.businessId,
    required this.name,
    required this.phone,
    required this.imageUrl,
  }) : super(key: key);

  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  bool _isLoading = true;
  List<dynamic> _items = [];
  int? _catalogId;

  @override
  void initState() {
    super.initState();
    _fetchCatalogAndItems();
  }

  Future<void> _fetchCatalogAndItems() async {
    setState(() => _isLoading = true);

    try {
      // Primero, obtenemos los detalles del negocio para encontrar el ID del catálogo
      final businessUrl = AppConfig.getApiUrl(AppConfig.negocioDetalleEndpoint(widget.businessId));
      final businessResponse = await http
          .get(Uri.parse(businessUrl))
          .timeout(AppConfig.httpTimeout);

      if (businessResponse.statusCode == 200) {
        final businessData = json.decode(businessResponse.body)['data'];
        if (businessData['catalogos'] != null && businessData['catalogos'].isNotEmpty) {
          _catalogId = businessData['catalogos'][0]['id']; // Asumimos el primer catálogo

          // Ahora, obtenemos los ítems de ese catálogo
          final itemsUrl = AppConfig.getApiUrl(AppConfig.itemsPorCatalogoEndpoint(widget.businessId, _catalogId!));
          final itemsResponse = await http
              .get(Uri.parse(itemsUrl))
              .timeout(AppConfig.httpTimeout);

          if (itemsResponse.statusCode == 200) {
            final itemsData = json.decode(itemsResponse.body)['data'];
            setState(() => _items = itemsData);
          }
        }
      }
    } on TimeoutException {
      print('Timeout al cargar catálogo');
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 columnas por defecto
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return ItemCard(item: _items[index]);
              },
            ),
    );
  }
}
