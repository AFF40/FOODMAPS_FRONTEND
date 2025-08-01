import 'package:cases/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cases/config/safe_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool obscureText = true;

  @override
  void initState() {
    super.initState();
    _checkSavedCredentials();
  }

  Future<void> _checkSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    final savedPassword = prefs.getString('password');
    final keepSession = prefs.getBool('mantenersesion') ?? false;

    // Solo hacer auto-login si el usuario eligió mantener la sesión
    if (keepSession && savedUsername != null && savedPassword != null) {
      _attemptAutoLogin(savedUsername, savedPassword);
    }
  }

  Future<void> _attemptAutoLogin(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.100.9:8081/FoodMaps_API/public/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        // Redirigir al home y limpiar el stack de navegación
        Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
                (route) => false
        );
      } else {
        // Si el auto-login falla, limpiar las credenciales
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('username');
        await prefs.remove('password');
      }
    } catch (e) {
      print('Auto-login fallido: $e');
      // Limpiar credenciales si hay error
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('username');
      await prefs.remove('password');
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String password = _passwordController.text;
      int rol = 1; // Rol de cliente

      const String apiUrl = 'http://192.168.100.9:8081/FoodMaps_API/public/api/auth/login';

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': username,
            'password': password,
            'user_role': rol,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final token = data['access_token'];

          final prefs = await SharedPreferences.getInstance();
          // Guardar todos los datos necesarios
          await prefs.setString('auth_token', token);
          await prefs.setString('username', username);
          await prefs.setString('password', password);
          await prefs.setBool('mantenersesion', true); // Asegúrate de guardar esto
          await prefs.setInt('userRole', rol);

          // Verifica que los datos se hayan guardado
          print('Datos guardados en SharedPreferences:');
          print('Token: ${prefs.getString('auth_token')}');
          print('Username: ${prefs.getString('username')}');
          print('Mantener sesión: ${prefs.getBool('mantenersesion')}');

          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Usuario o contraseña incorrectos')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión: $e')),
        );
      }
    }
  }

  // Metodo para imprimir todos los valores en SharedPreferences
  Future<void> _printAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    print('Todos los valores en SharedPreferences:');
    prefs.getKeys().forEach((key) {
      print('$key: ${prefs.get(key)}');
    });
  }

// Llama a este metodo después de guardar los datos en el login
// y al iniciar la aplicación en el AuthWrapper

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: screenWidth > 600 ? 400 : double.infinity,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        Assets.logo,
                        height: screenHeight * 0.2,
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      const Text(
                        'FOODMAPS',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      const Text(
                        'INICIAR SESIÓN',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Usuario:',
                          prefixIcon: Icon(Icons.person, color: Colors.red),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingrese su usuario';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: obscureText,
                        decoration: InputDecoration(
                          labelText: 'Contraseña:',
                          prefixIcon: const Icon(Icons.lock, color: Colors.red),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureText ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureText = !obscureText;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingrese su contraseña';
                          } else if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      SafeButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.2 > 200 ? 50 : screenWidth * 0.2,
                            vertical: screenHeight * 0.015,
                          ),
                        ),
                        child: const Text(
                          'Ingresar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      const Text("¿No tienes una cuenta aún?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text(
                          "Click aquí para crear una",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
