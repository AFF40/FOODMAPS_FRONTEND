import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

// Importaciones de la nueva arquitectura
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/auth/phone_verification_screen.dart';
import 'presentation/screens/cliente/client_home_screen.dart';
import 'presentation/screens/owner/owner_home_screen.dart';
import 'presentation/screens/owner/new_business_screen.dart';
import 'presentation/screens/owner/business_selector_screen.dart';

// Importaciones de la capa Core
import 'core/config/theme_provider.dart';
import 'core/config/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'FoodMaps 360',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(builder: (_) => const AuthWrapper());
              case '/login':
                return MaterialPageRoute(builder: (_) => const LoginScreen());
              case '/register':
                return MaterialPageRoute(builder: (_) => const RegistroScreen());
              case '/phone_verification':
                final email = settings.arguments as String? ?? '';
                return MaterialPageRoute(builder: (_) => PhoneVerificationScreen(email: email));
              case '/new_business':
                return MaterialPageRoute(builder: (_) => const NewBusinessScreen());
              case '/business_selector':
                final businesses = settings.arguments as List<Map<String, dynamic>>;
                return MaterialPageRoute(
                  builder: (_) => BusinessSelectorScreen(businesses: businesses),
                );
              case '/owner_home':
                final businessId = settings.arguments as int? ?? 0;
                return MaterialPageRoute(
                  builder: (_) => OwnerHomeScreen(businessId: businessId),
                );
              case '/client_home':
                return MaterialPageRoute(builder: (_) => const ClientHomeScreen());
              default:
                return MaterialPageRoute(
                  builder: (_) => Scaffold(
                    body: Center(child: Text('Ruta no encontrada: \'${settings.name}\'')),
                  ),
                );
            }
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<Map<String, dynamic>> _getAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString('auth_token'),
      'userRole': prefs.getInt('userRole') ?? 1,
      'businessId': prefs.getInt('business_id'),
      'businesses': jsonDecode(prefs.getString('businesses') ?? '[]'),
      'isPhoneVerified': prefs.getBool('is_phone_verified') ?? false,
      'email': prefs.getString('email'),
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getAuthState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final auth = snapshot.data ?? {};
        final token = auth['token'];
        final isPhoneVerified = auth['isPhoneVerified'] ?? false;
        final email = auth['email'] ?? '';

        if (token == null || token.isEmpty) {
          return const LoginScreen();
        }
        
        if (!isPhoneVerified) {
          return PhoneVerificationScreen(email: email);
        }

        final userRole = auth['userRole'];
        
        if (userRole == 2) { // Lógica para el Dueño
          final businesses = auth['businesses'] as List;
          final businessId = auth['businessId'];

          if (businesses.isEmpty) {
            return const NewBusinessScreen();
          }
          if (businesses.length > 1 && businessId == null) {
            return BusinessSelectorScreen(businesses: businesses.cast<Map<String, dynamic>>());
          }
          
          final selectedId = businessId ?? businesses.first['id'];
          return OwnerHomeScreen(businessId: selectedId);
        }
        
        return const ClientHomeScreen();
      },
    );
  }
}
