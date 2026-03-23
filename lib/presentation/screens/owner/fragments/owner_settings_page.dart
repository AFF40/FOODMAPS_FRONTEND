import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/config.dart';
import '../../../../core/config/theme_provider.dart';
import '../edit_business_screen.dart';

class OwnerSettingsPage extends StatefulWidget {
  final int businessId;

  const OwnerSettingsPage({Key? key, required this.businessId}) : super(key: key);

  @override
  State<OwnerSettingsPage> createState() => _OwnerSettingsPageState();
}

class _OwnerSettingsPageState extends State<OwnerSettingsPage> {
  bool _keepSession = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _keepSession = prefs.getBool('mantenersesion') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingItem(
            context,
            icon: Icons.edit,
            title: 'Editar información del Negocio',
            onTap: () => _editBusinessInfo(context),
          ),
          SwitchListTile(
            title: const Text("Mantener sesión iniciada"),
            value: _keepSession,
            onChanged: (value) async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('mantenersesion', value);
              setState(() => _keepSession = value);
            },
            secondary: const Icon(Icons.login),
          ),
          _buildSettingItem(
            context,
            icon: Icons.swap_horiz,
            title: 'Cambiar de Negocio',
            onTap: () => Navigator.pushNamed(context, '/business_selector'),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text("Modo oscuro"),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(value),
            secondary: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
          ),
          const Divider(),
          _buildSettingItem(
            context,
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _editBusinessInfo(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final businessDataJson = prefs.getString('business_selected'); // Usar una clave genérica
    if (businessDataJson != null) {
      final businessData = jsonDecode(businessDataJson);
      Navigator.push(context, MaterialPageRoute(builder: (_) => EditBusinessScreen(businessId: widget.businessId, businessData: businessData)));
    }
  }

  void _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Sí')),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if(token != null) {
          try {
              await http
                  .post(
                    Uri.parse(AppConfig.getApiUrl(AppConfig.logoutEndpoint)),
                    headers: {'Authorization': 'Bearer $token'},
                  )
                  .timeout(AppConfig.httpTimeout);
          } catch (e) { /* Ignorar errores de red en logout */ }
      }
      await prefs.remove('auth_token');
      await prefs.remove('business_id');
      // Opcional: mantener el tema 
      // final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
      // await prefs.clear();
      // await prefs.setBool('theme_dark', isDark);
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }
}
