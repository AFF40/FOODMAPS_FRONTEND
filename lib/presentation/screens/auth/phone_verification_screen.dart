import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../../core/config/config.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String email;
  final String? initialPhoneNumber;

  const PhoneVerificationScreen({
    Key? key,
    required this.email,
    this.initialPhoneNumber,
  }) : super(key: key);

  @override
  _PhoneVerificationScreenState createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _codeSent = false;
  bool _isLoading = false;
  String _selectedCountryCode = '+591'; // Bolivia por defecto

  final Map<String, String> _countryCodes = {
    '+591': 'BO',
    '+54': 'AR',
    '+55': 'BR',
    '+56': 'CL',
    '+57': 'CO',
    '+51': 'PE',
    '+1': 'US',
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialPhoneNumber != null) {
      _phoneController.text = widget.initialPhoneNumber!;
    }
  }

  Future<void> _sendVerificationCode() async {
    if (_phoneController.text.length < 8) {
      _showError('Por favor, ingrese un número de teléfono válido.');
      return;
    }
    setState(() => _isLoading = true);

    final url = AppConfig.getApiUrl(AppConfig.sendCodeEndpoint);

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': widget.email,
              'celular': '$_selectedCountryCode${_phoneController.text}',
            }),
          )
          .timeout(AppConfig.httpTimeout);

      if (response.statusCode == 200) {
        setState(() {
          _codeSent = true;
        });
        _showSuccess('Código de verificación enviado a $_selectedCountryCode ${_phoneController.text}');
      } else {
        final data = jsonDecode(response.body);
        _showError(data['error'] ?? 'Error enviando código');
      }
    } on TimeoutException {
      _showError('Timeout: No se pudo conectar al servidor.');
    } catch (e) {
      _showError('Error de conexión: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.length < 4) { 
      _showError('Por favor, ingrese el código completo.');
      return;
    }
    setState(() => _isLoading = true);

    final url = AppConfig.getApiUrl(AppConfig.verifyEndpoint);
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': widget.email,
              'code': _codeController.text,
              'celular': '$_selectedCountryCode${_phoneController.text}',
            }),
          )
          .timeout(AppConfig.httpTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setBool('is_phone_verified', true);
        
        _showSuccess('¡Cuenta verificada con éxito!');
        if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        _showError('Código incorrecto o expirado.');
      }
    } catch (e) {
      _showError('Error de conexión.');
    }

    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }
  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificación de Teléfono')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_codeSent)
              const Text('Ingresa tu número para recibir un código de verificación.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            if (_codeSent)
              Text('Se ha enviado un código a $_selectedCountryCode ${_phoneController.text}', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            const SizedBox(height: 32),
            Row(
              children: [
                DropdownButton<String>(
                  value: _selectedCountryCode,
                  items: _countryCodes.keys.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text('$value (${_countryCodes[value]})'),
                    );
                  }).toList(),
                  onChanged: _codeSent ? null : (newValue) {
                    setState(() => _selectedCountryCode = newValue!);
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Número', border: OutlineInputBorder()),
                    keyboardType: TextInputType.phone,
                    enabled: !_codeSent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!_codeSent)
              ElevatedButton(
                onPressed: _isLoading ? null : _sendVerificationCode,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Enviar Código'),
              ),
            if (_codeSent) ...[
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(labelText: 'Código de Verificación', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Verificar y Activar Cuenta'),
                ),
                 TextButton(
                  onPressed: _isLoading ? null : () => setState(() => _codeSent = false),
                  child: const Text('Cambiar número'),
                )
              ],
          ],
        ),
      ),
    );
  }
}
