import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/assets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/config.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool obscureText = true;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '950416338317-q4b6gfh1a43c2ouigfqrnps6vpjuuq17.apps.googleusercontent.com',
    scopes: ['openid', 'email', 'profile'],
  );

  @override
  void initState() {
    super.initState();
    _checkSavedCredentials();
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    try {
      setState(() => _isLoading = true);

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      // SOLUCIÓN: Usar accessToken en lugar de idToken para la web.
      final String? accessToken = googleAuth.accessToken;

      if (accessToken == null) {
        throw Exception('No se pudo obtener el access_token de Google.');
      }

      final response = await http.post(
        Uri.parse(AppConfig.getApiUrl(AppConfig.googleLoginEndpoint)),
        headers: {'Content-Type': 'application/json'},
        // SOLUCIÓN: Enviar access_token al backend.
        body: jsonEncode({'access_token': accessToken}),
      ).timeout(const Duration(seconds: 30));

      // Pasar el email del usuario de Google a _processLoginResponse
      await _processLoginResponse(response, email: googleUser.email);

    } catch (e) {
      print("Error en inicio de sesión con Google: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al iniciar sesión con Google.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    final savedPassword = prefs.getString('password');
    final keepSession = prefs.getBool('mantenersesion') ?? false;

    if (keepSession && savedUsername != null && savedPassword != null) {
      _attemptAutoLogin(savedUsername, savedPassword);
    }
  }

  Future<void> _attemptAutoLogin(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(AppConfig.getApiUrl(AppConfig.loginEndpoint)),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(
            AppConfig.httpTimeout,
            onTimeout: () => throw TimeoutException('Timeout en auto-login'),
          );
      await _processLoginResponse(response, username: username, password: password);
    } catch (e) {
      print('Fallo el auto-login: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('username');
      await prefs.remove('password');
    }
  }

  Future<void> _login() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);
      final response = await http
          .post(
            Uri.parse(AppConfig.getApiUrl(AppConfig.loginEndpoint)),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': _usernameController.text,
              'password': _passwordController.text,
            }),
          )
          .timeout(AppConfig.httpTimeout);

      await _processLoginResponse(response, username: _usernameController.text, email: _usernameController.text, password: _passwordController.text);

    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tiempo de espera agotado.'), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de conexión.'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _processLoginResponse(http.Response response, {String? username, String? email, String? password}) async {
    final prefs = await SharedPreferences.getInstance();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];
      final user = data['user'];

      if (token == null || user == null) {
        throw Exception('Datos incompletos desde el servidor');
      }
      
      // Guardar datos de sesión
      await prefs.setString('auth_token', token);
      await prefs.setInt('userRole', user['role'] ?? 1);
      await prefs.setInt('user_id', user['id']);
      if(email != null) await prefs.setString('email', email);
      if (username != null && password != null) {
        await prefs.setString('username', username);
        await prefs.setString('password', password);
      }
      await prefs.setBool('mantenersesion', true);

      // --- Lógica de Verificación de Teléfono ---
      final bool isVerified = user['is_verified'] ?? false;
      await prefs.setBool('is_phone_verified', isVerified);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicio de sesión exitoso'), backgroundColor: Colors.green),
      );

      if (!isVerified) {
        Navigator.pushNamedAndRemoveUntil(context, '/phone_verification', (route) => false, arguments: email);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); // Dejar que AuthWrapper decida
      }

    } else {
      // Manejo de errores de login
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales inválidas o error del servidor.'), backgroundColor: Colors.red),
      );
    }
  }

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
                constraints: BoxConstraints(maxWidth: screenWidth > 600 ? 400 : double.infinity),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(Assets.logo, height: screenHeight * 0.2),
                      const SizedBox(height: 24),
                      const Text('FOODMAPS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('INICIAR SESIÓN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 40),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Usuario o Email:', // Acepta ambos
                          prefixIcon: Icon(Icons.person, color: Colors.red),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? 'Ingrese su usuario o email' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: obscureText,
                        decoration: InputDecoration(
                          labelText: 'Contraseña:',
                          prefixIcon: const Icon(Icons.lock, color: Colors.red),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => obscureText = !obscureText),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Por favor, ingrese su contraseña';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        ),
                        child: _isLoading 
                            ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red)) 
                            : const Text('Ingresar', style: TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                        icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red),
                        label: const Text('Ingresar con Google', style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          side: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/register'),
                        child: const Text("¿No tienes una cuenta aún? Click aquí para crear una", style: TextStyle(color: Colors.blue)),
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
