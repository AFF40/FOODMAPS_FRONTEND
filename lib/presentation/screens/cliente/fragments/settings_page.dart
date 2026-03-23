import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/theme_provider.dart';
import '../../../../core/config/config.dart';
import '../../owner/new_business_screen.dart'; // Ruta actualizada y generalizada

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<bool> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Sí')),
        ],
      ),
    );

    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    if (token != null) {
      try {
        await http
            .post(
              Uri.parse(AppConfig.getApiUrl(AppConfig.logoutEndpoint)),
              headers: {'Authorization': 'Bearer $token'},
            )
            .timeout(AppConfig.httpTimeout);
      } catch (e) {
        print('Error al llamar a la API de logout: $e');
      }
    }

    await prefs.clear();
    await prefs.setBool('theme_dark', isDarkMode); // Guardar el tema actual de forma más simple

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // Cierra el loader
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesión cerrada'), backgroundColor: Colors.green));
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkAuth(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data == false) {
          Future.microtask(() {
             if(context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          });
          return const SizedBox.shrink();
        }

        final themeProvider = Provider.of<ThemeProvider>(context);
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark ? [Colors.black, Colors.grey.shade900] : [Colors.white, Colors.red.shade50],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  elevation: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_pin, size: 64, color: Colors.red.shade400),
                        const SizedBox(height: 12),
                        Text("Ajustes de Usuario", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        SwitchListTile(
                          title: const Text("Modo oscuro"),
                          value: isDark,
                          onChanged: (value) => themeProvider.toggleTheme(value),
                          secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        Divider(thickness: 1.2, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NewBusinessScreen())),
                            icon: const Icon(Icons.add_business),
                            label: const Text("Agregar mi negocio"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _confirmLogout(context),
                            icon: const Icon(Icons.logout, color: Colors.red),
                            label: const Text("Cerrar Sesión"),
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
