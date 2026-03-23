import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddItemPage extends StatefulWidget {
  final int businessId;
  final int catalogId;

  const AddItemPage({Key? key, required this.businessId, required this.catalogId}) : super(key: key);

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  Uint8List? _imageBytes;
  bool _isSaving = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final url = AppConfig.getApiUrl(AppConfig.itemsPorCatalogoEndpoint(widget.businessId, widget.catalogId));

    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['nombre'] = _nameController.text
      ..fields['precio'] = _priceController.text
      ..fields['descripcion'] = _descriptionController.text;

    if (_imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes('imagen', _imageBytes!, filename: 'item_image.jpg'));
    }

    try {
      final response = await request.send();
      if (response.statusCode == 201) {
        Navigator.pop(context, true); // Indicate success
      } else {
        final respStr = await response.stream.bytesToString();
        _showError('Error: ${response.statusCode}\n$respStr');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }

    setState(() => _isSaving = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Nuevo Ítem')),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nombre del Ítem'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
                    TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Requerido' : null),
                    TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Descripción'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: _pickImage, child: const Text('Seleccionar Imagen')),
                    if (_imageBytes != null) Image.memory(_imageBytes!, height: 100),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: _saveItem, child: const Text('Guardar Ítem')),
                  ],
                ),
              ),
            ),
    );
  }
}
