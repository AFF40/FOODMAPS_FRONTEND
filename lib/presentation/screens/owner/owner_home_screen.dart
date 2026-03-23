import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/config/config.dart';
import 'fragments/owner_map_page.dart';
import 'fragments/owner_catalogs_page.dart';
import 'fragments/owner_items_page.dart';
import 'fragments/owner_settings_page.dart';

class OwnerHomeScreen extends StatefulWidget {
  final int businessId;

  const OwnerHomeScreen({Key? key, required this.businessId}) : super(key: key);

  @override
  _OwnerHomeScreenState createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  int _businessStatus = 0;
  String _businessName = '';
  String _businessImage = '';
  bool _isLoadingStatus = true;
  bool _isChangingStatus = false;

  late final List<Widget> _pages;
  final GlobalKey<OwnerMapPageState> _mapPageKey = GlobalKey<OwnerMapPageState>();

  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pages = [
      OwnerMapPage(key: _mapPageKey, businessId: widget.businessId),
      OwnerCatalogsPage(businessId: widget.businessId),
      OwnerItemsPage(businessId: widget.businessId),
      OwnerSettingsPage(businessId: widget.businessId),
    ];

    _fetchBusinessData();
    _connectWebSocket();
  }

  Future<void> _fetchBusinessData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      setState(() => _isLoadingStatus = false);
      return;
    }

    final url = AppConfig.getApiUrl(AppConfig.negocioDetalleEndpoint(widget.businessId));
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(
            AppConfig.httpTimeout,
            onTimeout: () => throw TimeoutException('Timeout al obtener datos del negocio'),
          );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        setState(() {
          _businessName = data['nombre'] ?? '';
          _businessStatus = data['estado'] ?? 0;
          _businessImage = data['imagen'] ?? '';
          _isLoadingStatus = false;
        });
        _mapPageKey.currentState?.updateBusinessStatus(_businessStatus);
      }
    } catch (e) {
      print('Error fetching business data: $e');
      setState(() => _isLoadingStatus = false);
    }
  }

  Future<void> _changeBusinessStatus(bool newStatus) async {
    setState(() => _isChangingStatus = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      setState(() => _isChangingStatus = false);
      return;
    }

    final url = AppConfig.getApiUrl(AppConfig.negocioChangeStatusEndpoint(widget.businessId));
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(
            AppConfig.httpTimeout,
            onTimeout: () => throw TimeoutException('Timeout al cambiar estado'),
          );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        final updatedStatus = data['estado'] ?? _businessStatus;
        setState(() => _businessStatus = updatedStatus);
        _mapPageKey.currentState?.updateBusinessStatus(updatedStatus);
      }
    } catch (e) {
      print('Error changing business status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar estado: $e')),
        );
      }
    } finally {
      setState(() => _isChangingStatus = false);
    }
  }

  void _connectWebSocket() {
    try {
      _channel?.sink.close();
    } catch (e) {
      print('Error cerrando WebSocket anterior: $e');
    }
    
    try {
      final wsUrl = AppConfig.websocketBaseUrl;
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _channel?.sink.add(
        jsonEncode({
          "event": "pusher:subscribe",
          "data": {"channel": AppConfig.websocketChannelNegocios}
        }),
      );
      
      _channel?.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            if (data is Map && data.containsKey('event')) {
              if (data['event'] == 'status.updated') {
                final eventData = jsonDecode(data['data'] ?? '{}');
                if (eventData['id'] == widget.businessId) {
                  setState(() => _businessStatus = eventData['estado']);
                  _mapPageKey.currentState?.updateBusinessStatus(eventData['estado']);
                }
              }
            }
          } catch (e) {
            print('Error procesando mensaje WebSocket: $e');
          }
        },
        onError: (error) {
          print('WebSocket Error: $error');
          // Reintentar conexión después de 5 segundos
          Future.delayed(const Duration(seconds: 5), _connectWebSocket);
        },
        onDone: () {
          print('WebSocket Closed, intentando reconectar...');
          // Reintentar conexión después de 5 segundos
          Future.delayed(const Duration(seconds: 5), _connectWebSocket);
        },
        cancelOnError: true,
      );
    } catch (e) {
      print('Error conectando WebSocket: $e');
      // Reintentar después de 5 segundos si hay error
      Future.delayed(const Duration(seconds: 5), _connectWebSocket);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _channel?.sink.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchBusinessData();
      _connectWebSocket();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            _businessImage.isNotEmpty ? Image.network(AppConfig.getImageUrl(_businessImage), width: 40, height: 40) : const Icon(Icons.storefront, size: 40),
            const SizedBox(width: 12),
            Expanded(child: Text(_businessName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
          ],
        ),
        actions: [_buildStatusSwitch()],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Catálogos'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Items'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }

  Widget _buildStatusSwitch() {
    if (_isLoadingStatus) return const CircularProgressIndicator();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_businessStatus == 1 ? 'Abierto' : 'Cerrado', style: TextStyle(color: _businessStatus == 1 ? Colors.green : Colors.red)),
        Switch(
          value: _businessStatus == 1,
          onChanged: _isChangingStatus ? null : _changeBusinessStatus,
          activeColor: Colors.green,
        ),
        if (_isChangingStatus) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
      ],
    );
  }
}
