import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/config/config.dart';
import '../../widgets/map_location_picker.dart'; // Widget de mapa reutilizable

class EditBusinessScreen extends StatefulWidget {
  final int businessId;
  final Map<String, dynamic> businessData;

  const EditBusinessScreen({
    Key? key,
    required this.businessId,
    required this.businessData,
  }) : super(key: key);

  @override
  State<EditBusinessScreen> createState() => _EditBusinessScreenState();
}

class _EditBusinessScreenState extends State<EditBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _imageModified = false;
  Uint8List? _imageBytes;
  String? _currentImageUrl;
  int? _selectedCategoryId;

  late final TextEditingController _nombreController;
  late final TextEditingController _ubicacionController;
  late final TextEditingController _celularController;
  late final TextEditingController _descripcionController; // Generalizado desde tematica

  LatLng? _selectedLatLng;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadBusinessData();
    _fetchCategories();
  }

  void _loadBusinessData() {
    final data = widget.businessData;
    _nombreController = TextEditingController(text: data['nombre'] ?? '');
    _ubicacionController = TextEditingController(text: data['ubicacion'] ?? '');
    _celularController = TextEditingController(text: data['celular']?.toString() ?? '');
    _descripcionController = TextEditingController(text: data['descripcion'] ?? '');
    _selectedCategoryId = data['categoria_id'];

    if (data['imagen'] != null) _currentImageUrl = AppConfig.getImageUrl(data['imagen']);
    
    final parts = (data['ubicacion'] ?? '').split(',');
    if (parts.length >= 2) {
      _selectedLatLng = LatLng(double.tryParse(parts[0]) ?? 0.0, double.tryParse(parts[1]) ?? 0.0);
    }
  }
  
  Future<void> _fetchCategories() async {
    final url = AppConfig.getApiUrl(AppConfig.categoriasEndpoint);
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(AppConfig.httpTimeout);
      if(response.statusCode == 200) {
        setState(() => _categories = List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']));
      }
    } on TimeoutException {
      print('Timeout al obtener categorías');
    } catch (e) { /* handle error */ }
  }

  Future<void> _selectImage() async {
     final picker = ImagePicker();
     final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
     if (pickedFile != null) {
       final bytes = await pickedFile.readAsBytes();
       setState(() {
         _imageBytes = bytes;
         _imageModified = true;
       });
     }
  }

  Future<void> _selectLocationOnMap() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (context) => MapLocationPicker(initialPosition: _selectedLatLng)),
    );
    if (result != null) {
      setState(() {
        _selectedLatLng = result;
        _ubicacionController.text = '${result.latitude},${result.longitude}';
      });
    }
  }

  Future<void> _updateBusiness() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;
    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final url = AppConfig.getApiUrl(AppConfig.negocioDetalleEndpoint(widget.businessId));

    try {
      http.Response response;
      if (_imageModified && _imageBytes != null) {
        var request = http.MultipartRequest('POST', Uri.parse(url)) // POST para simular PUT con imagen
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['_method'] = 'PUT'
          ..fields['nombre'] = _nombreController.text
          ..fields['ubicacion'] = _ubicacionController.text
          ..fields['celular'] = _celularController.text
          ..fields['descripcion'] = _descripcionController.text
          ..fields['categoria_id'] = _selectedCategoryId.toString()
          ..files.add(http.MultipartFile.fromBytes('imagen', _imageBytes!, filename: 'logo.png'));
        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        response = await http.put(Uri.parse(url), 
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
          body: jsonEncode({
            'nombre': _nombreController.text,
            'ubicacion': _ubicacionController.text,
            'celular': _celularController.text,
            'descripcion': _descripcionController.text,
            'categoria_id': _selectedCategoryId,
          }),
        );
      }
      _handleResponse(response);
    } catch (e) {
      _showError('Error de conexión: $e');
    }
    setState(() => _isLoading = false);
  }

  void _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      _showSuccess('Negocio actualizado');
      Navigator.pop(context, true); // Regresa indicando que hubo cambios
    } else {
      _showError('Error al actualizar: ${response.body}');
    }
  }
  
  void _showError(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  void _showSuccess(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Negocio')),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _selectImage,
                child: CircleAvatar(radius: 60, backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : (_currentImageUrl != null ? NetworkImage(_currentImageUrl!) : null) as ImageProvider, child: _imageBytes == null && _currentImageUrl == null ? const Icon(Icons.add_a_photo) : null),
              ),
              TextFormField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre del Negocio'), validator: (v) => v!.isEmpty ? 'Campo requerido' : null),
              TextFormField(controller: _celularController, decoration: const InputDecoration(labelText: 'Celular'), validator: (v) => v!.isEmpty ? 'Campo requerido' : null),
              TextFormField(controller: _descripcionController, decoration: const InputDecoration(labelText: 'Descripción'), validator: (v) => v!.isEmpty ? 'Campo requerido' : null),
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                items: _categories.map((c) => DropdownMenuItem<int>(value: c['id'], child: Text(c['nombre']))).toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
                decoration: const InputDecoration(labelText: 'Categoría'),
                validator: (v) => v == null ? 'Seleccione una categoría' : null,
              ),
              TextFormField(controller: _ubicacionController, decoration: const InputDecoration(labelText: 'Ubicación'), readOnly: true, onTap: _selectLocationOnMap, validator: (v) => v!.isEmpty ? 'Seleccione una ubicación' : null),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _updateBusiness, child: const Text('Guardar Cambios')),
            ],
          ),
        ),
      ),
    );
  }
}
