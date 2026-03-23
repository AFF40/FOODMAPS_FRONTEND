import 'package:flutter/material.dart';
import '../../core/config/config.dart';
import '../screens/public/catalog_screen.dart'; // Asumiendo la futura pantalla de catálogo

String getBusinessImageUrl(String? imagen) {
  if (imagen == null || imagen.isEmpty) return '';
  if (imagen.startsWith('http')) return imagen;
  // Usar el método centralizado de AppConfig
  final url = AppConfig.getImageUrl(imagen);
  print('[INFO_WINDOW][LOGO] Ruta completa de imagen: $url');
  return url;
}

class BusinessInfoWindow extends StatelessWidget {
  final Map<String, dynamic> businessData;
  final VoidCallback? onCatalogPressed;

  const BusinessInfoWindow({
    Key? key,
    required this.businessData,
    this.onCatalogPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = getBusinessImageUrl(businessData['imagen']?.toString());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF232526) : Colors.grey[100]!;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color buttonColor = isDark ? Colors.red.shade700 : Colors.black;
    final Color buttonTextColor = Colors.white;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxButtonWidth = constraints.maxWidth < 180 ? constraints.maxWidth : 140;

        return SizedBox(
          width: constraints.maxWidth,
          height: 130, // Altura ajustada para el contenido
          child: Card(
            elevation: 6,
            margin: EdgeInsets.zero,
            color: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    businessData['nombre'] ?? '', // Nombre genérico del negocio
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 70,
                              height: 70,
                              color: isDark ? Colors.grey[800] : Colors.grey[300],
                              child: Icon(Icons.image, size: 40, color: isDark ? Colors.white54 : Colors.grey),
                            ),
                          )
                        : Container(
                            width: 70,
                            height: 70,
                            color: isDark ? Colors.grey[800] : Colors.grey[300],
                            child: Icon(Icons.storefront, size: 40, color: isDark ? Colors.white54 : Colors.grey), // Icono genérico
                          ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 32,
                    width: maxButtonWidth,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(80, 32),
                        maximumSize: Size(maxButtonWidth, 32),
                      ),
                      icon: Icon(Icons.storefront, size: 16, color: buttonTextColor), // Icono genérico
                      label: Text('Ver Catálogo', style: TextStyle(fontSize: 12, color: buttonTextColor)), // Texto genérico
                      onPressed: () {
                        print('[INFO_WINDOW] Botón Ver Catálogo presionado');

                        final int businessId = businessData['id'] as int? ?? 0;
                        final String name = businessData['nombre'] ?? '';
                        final String phone = businessData['celular']?.toString() ?? '';
                        final String imageUrlParam = businessData['imagen']?.toString() ?? '';

                        print('[INFO_WINDOW] Navegando a catálogo: businessId=$businessId, name=$name');

                        // Navegar a una pantalla de catálogo genérica (que crearemos más adelante)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CatalogScreen(
                              businessId: businessId,
                              name: name,
                              phone: phone,
                              imageUrl: imageUrlParam,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
