import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/config.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pass1Controller = TextEditingController();
  final TextEditingController _pass2Controller = TextEditingController();

  bool _loading = false;
  String? _selectedRol;

  Future<void> _registrar() async {
    if (_loading || !mounted) return;
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      final String apiUrl = AppConfig.getApiUrl(AppConfig.registerEndpoint);
      final String email = _emailController.text.trim();

      try {
        final response = await http
            .post(
              Uri.parse(apiUrl),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'username': _usernameController.text.trim(),
                'celular': _celularController.text.trim(),
                'email': email,
                'password': _pass1Controller.text.trim(),
                'password_confirmation': _pass2Controller.text.trim(),
                'rol': _selectedRol == 'cliente' ? 'Cliente' : 'Dueño',
              }),
            )
            .timeout(AppConfig.httpTimeout);

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registro exitoso. Revisa tu WhatsApp para el código de verificación.'), backgroundColor: Colors.green),
            );
            Navigator.pushNamedAndRemoveUntil(context, '/phone_verification', (route) => false, arguments: email);
          }
        } else {
          final data = jsonDecode(response.body);
          final msg = data['message'] ?? 'Ocurrió un error en el registro.';
          // imprimir mensaje de error

          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
        }
      } on TimeoutException {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Timeout: No se pudo conectar al servidor.'), backgroundColor: Colors.orange));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión.'), backgroundColor: Colors.red));
      }
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
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
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Text("REGISTRARSE", style: TextStyle(fontSize: 40, color: textColor, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(prefixIcon: Icon(Icons.person, color: textColor), hintText: "Nombre de usuario", filled: true, fillColor: isDark ? Colors.grey[900] : Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      style: TextStyle(fontSize: 18, color: textColor),
                      validator: (v) => (v == null || v.isEmpty) ? 'Ingrese un nombre de usuario' : null,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _celularController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(prefixIcon: Icon(Icons.phone, color: textColor), hintText: "Celular", filled: true, fillColor: isDark ? Colors.grey[900] : Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      style: TextStyle(fontSize: 18, color: textColor),
                      validator: (v) => (v == null || v.isEmpty) ? 'Ingrese un número de celular' : null,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(prefixIcon: Icon(Icons.email, color: textColor), hintText: "Email", filled: true, fillColor: isDark ? Colors.grey[900] : Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      style: TextStyle(fontSize: 18, color: textColor),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingrese su email';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Ingrese un email válido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _pass1Controller,
                      obscureText: true,
                      decoration: InputDecoration(prefixIcon: Icon(Icons.lock, color: textColor), hintText: "Contraseña", filled: true, fillColor: isDark ? Colors.grey[900] : Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      style: TextStyle(fontSize: 18, color: textColor),
                      validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _pass2Controller,
                      obscureText: true,
                      decoration: InputDecoration(prefixIcon: Icon(Icons.lock_outline, color: textColor), hintText: "Repita su contraseña", filled: true, fillColor: isDark ? Colors.grey[900] : Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      style: TextStyle(fontSize: 18, color: textColor),
                      validator: (v) => (v != _pass1Controller.text) ? 'Las contraseñas no coinciden' : null,
                    ),
                    const SizedBox(height: 30),
                    DropdownButtonFormField<String>(
                      value: _selectedRol,
                      dropdownColor: isDark ? Colors.grey[900] : Colors.white,
                      decoration: InputDecoration(prefixIcon: Icon(Icons.person_outline, color: textColor), hintText: "Seleccione su rol", filled: true, fillColor: isDark ? Colors.grey[900] : Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      items: const [DropdownMenuItem(value: 'cliente', child: Text('Cliente')), DropdownMenuItem(value: 'dueño', child: Text('Dueño'))],
                      onChanged: (value) => setState(() => _selectedRol = value),
                      validator: (v) => (v == null || v.isEmpty) ? 'Seleccione un rol' : null,
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _registrar,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: _loading ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : const Text("REGISTRAR", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("¿Ya tienes una cuenta? ", style: TextStyle(fontSize: 16, color: textColor)),
                        GestureDetector(onTap: () => Navigator.pushNamed(context, '/login'), child: const Text("Iniciar sesión", style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
