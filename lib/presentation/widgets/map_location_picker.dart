import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapLocationPicker extends StatefulWidget {
  final LatLng? initialPosition;

  const MapLocationPicker({Key? key, this.initialPosition}) : super(key: key);

  @override
  _MapLocationPickerState createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  LatLng? _pickedLocation;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialPosition;
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onTap(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar Ubicación')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialPosition ?? const LatLng(0, 0),
              zoom: 15,
            ),
            onMapCreated: _onMapCreated,
            onTap: _onTap,
            markers: _pickedLocation != null
                ? {Marker(markerId: const MarkerId('pickedLocation'), position: _pickedLocation!)}
                : {},
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _pickedLocation != null ? () => Navigator.of(context).pop(_pickedLocation) : null,
              child: const Text('Confirmar Ubicación'),
            ),
          ),
        ],
      ),
    );
  }
}
