import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditItemPage extends StatefulWidget {
  final Map<String, dynamic> item;
  final int businessId;
  final int catalogId;

  const EditItemPage({
    Key? key,
    required this.item,
    required this.businessId,
    required this.catalogId,
  }) : super(key: key);

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late bool _isAvailable;
  Uint8List? _imageBytes;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item['nombre'] ?? '');
    _priceController = TextEditingController(text: widget.item['precio']?.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.item['descripcion'] ?? '');
    _isAvailable = widget.item['disponible'] == 1;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final url = AppConfig.getApiUrl(AppConfig.itemDetailEndpoint(widget.item['id']));

    try {
      http.Response response;
      if (_imageBytes != null) {
        var request = http.MultipartRequest('POST', Uri.parse(url))
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['_method'] = 'PUT'
          ..fields['nombre'] = _nameController.text
          ..fields['precio'] = _priceController.text
          ..fields['descripcion'] = _descriptionController.text
          ..fields['disponible'] = _isAvailable.toString()
          ..files.add(http.MultipartFile.fromBytes('imagen', _imageBytes!, filename: 'item_image.jpg'));
        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        response = await http.put(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
          body: jsonEncode({
            'nombre': _nameController.text,
            'precio': _priceController.text,
            'descripcion': _descriptionController.text,
            'disponible': _isAvailable,
          }),
        );
      }

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Ítem')),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nombre del Ítem')),
                  TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number),
                  TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Descripción')),
                  SwitchListTile(title: const Text('Disponible'), value: _isAvailable, onChanged: (val) => setState(() => _isAvailable = val)),
                  ElevatedButton(onPressed: _pickImage, child: const Text('Cambiar Imagen')),
                  if (_imageBytes != null) Image.memory(_imageBytes!, height: 100),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _saveChanges, child: const Text('Guardar Cambios')),
                ],
              ),
            ),
    );
  }
}
