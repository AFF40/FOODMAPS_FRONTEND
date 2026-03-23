import 'package:flutter/material.dart';
import '../../../../core/config/config.dart';

class ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = AppConfig.getImageUrl(item['imagen_url']);
    final isAvailable = item['disponible'] == 1;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              Center(
                child: Image.network(
                  imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_bag, size: 120),
                ),
              ),
            const SizedBox(height: 8),
            Text(item['nombre'] ?? 'N/A', style: Theme.of(context).textTheme.titleLarge),
            Text('Bs. ${item['precio'] ?? '0.00'}', style: Theme.of(context).textTheme.titleMedium),
            if (item['descripcion'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(item['descripcion'], style: Theme.of(context).textTheme.bodyMedium),
              ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Chip(
                label: Text(isAvailable ? 'Disponible' : 'Agotado'),
                backgroundColor: isAvailable ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
