import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/config.dart';

class BusinessDesktopTable extends StatelessWidget {
  final List<Map<String, dynamic>> businessesData;
  final void Function(Map<String, dynamic>) onCatalogPressed;

  const BusinessDesktopTable({
    Key? key,
    required this.businessesData,
    required this.onCatalogPressed,
  }) : super(key: key);

  void _launchMaps(String? ubicacion) async {
    if (ubicacion == null) return;
    final url = 'https://www.google.com/maps/search/?api=1&query=$ubicacion';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

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
        return DataRow(
          cells: [
            DataCell(business['imagen'] != null
                ? Image.network(AppConfig.getImageUrl(business['imagen']), width: 40)
                : const Icon(Icons.storefront)),
            DataCell(Text(business['nombre'] ?? '')),
            DataCell(ElevatedButton(onPressed: () => _launchMaps(business['ubicacion']), child: const Text('Ver Mapa'))),
            DataCell(Text(business['estado'] == 1 ? 'Abierto' : 'Cerrado')),
            DataCell(ElevatedButton(onPressed: () => onCatalogPressed(business), child: const Text('Ver Catálogo'))),
          ],
        );
      }).toList(),
    );
  }
}
