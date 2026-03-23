import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/config/config.dart';
import '../../widgets/map_location_picker.dart';

class NewBusinessScreen extends StatefulWidget {
  const NewBusinessScreen({Key? key}) : super(key: key);

  @override
  _NewBusinessScreenState createState() => _NewBusinessScreenState();
}

class _NewBusinessScreenState extends State<NewBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Uint8List? _imageBytes;
  int? _selectedCategoryId;
  LatLng? _selectedLatLng;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final url = AppConfig.getApiUrl(AppConfig.categoriasEndpoint);
      final response = await http
          .get(Uri.parse(url))
          .timeout(AppConfig.httpTimeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        setState(() {
          _categories = data.cast<Map<String, dynamic>>();
        });
      }
    } on TimeoutException {
      _showError('Timeout: No se pudo conectar al servidor.');
    } catch (e) {
      _showError('No se pudieron cargar las categorías.');
    }
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _selectLocation() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapLocationPicker(initialPosition: _selectedLatLng)),
    );
    if (result != null) {
      setState(() {
        _selectedLatLng = result;
        _locationController.text = '${result.latitude.toStringAsFixed(6)}, ${result.longitude.toStringAsFixed(6)}';
      });
    }
  }

  Future<void> _registerBusiness() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userId = prefs.getInt('user_id');

    var request = http.MultipartRequest('POST', Uri.parse(AppConfig.getApiUrl(AppConfig.negociosEndpoint)))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['nombre'] = _nameController.text
      ..fields['descripcion'] = _descriptionController.text
      ..fields['celular'] = _phoneController.text
      ..fields['ubicacion'] = _locationController.text
      ..fields['user_id'] = userId.toString()
      ..fields['categoria_id'] = _selectedCategoryId.toString();

    if (_imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes('imagen', _imageBytes!, filename: 'business_image.jpg'));
    }

    try {
      final response = await request.send();
      if (response.statusCode == 201) {
        // Handle success, maybe refresh user data and navigate
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        final respStr = await response.stream.bytesToString();
        _showError('Error: ${response.statusCode}\n$respStr');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }

    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Nuevo Negocio')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nombre del Negocio'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
                    TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Descripción'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
                    TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Celular'), keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Requerido' : null),
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      items: _categories.map((c) => DropdownMenuItem<int>(value: c['id'] as int, child: Text(c['nombre'] as String))).toList(),
                      onChanged: (v) => setState(() => _selectedCategoryId = v),
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      validator: (v) => v == null ? 'Requerido' : null,
                    ),
                    TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: 'Ubicación'), readOnly: true, onTap: _selectLocation, validator: (v) => v!.isEmpty ? 'Requerido' : null),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: _selectImage, child: const Text('Seleccionar Imagen')),
                    if (_imageBytes != null) Image.memory(_imageBytes!, height: 100),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: _registerBusiness, child: const Text('Registrar Negocio')),
                  ],
                ),
              ),
            ),
    );
  }
}
