# Exemplos de Uso

Este documento fornece exemplos práticos de como utilizar a biblioteca `map_marker_cache` em suas aplicações Flutter.

## Exemplo Básico (Sem Google Maps)

Este exemplo demonstra o funcionamento do cache de ícones, exibindo lado a lado ícones carregados do cache e ícones carregados "normalmente" (sem cache). Isso permite visualizar a diferença de performance e o benefício do cache.

**Código Fonte Completo:** Consulte o arquivo `example/lib/main.dart` no repositório.

**Visão Geral do Código:**

```dart
import 'package:flutter/material.dart';
import 'package:map_marker_cache/map_marker_cache.dart';
import 'dart:typed_data';
import 'package:map_marker_cache/utils/svg_converter.dart'; // Importar para carregamento normal

void main() {
  runApp(const MyApp());
}

enum MarkerType {
  red, green, blue
}

class MarkerData {
  final MarkerType type;
  final String assetName;
  final Size size;

  MarkerData({
    required this.type,
    required this.assetName,
    required this.size,
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MapMarkerCache _mapMarkerCache;
  final Map<MarkerType, Uint8List> _cachedMarkerBytes = {};
  final Map<MarkerType, Uint8List> _normalMarkerBytes = {};
  bool _isLoadingCache = true;
  bool _isLoadingNormal = true;
  String? _errorCache;
  String? _errorNormal;

  final List<MarkerData> _markerData = [
    MarkerData(
      type: MarkerType.red,
      assetName: 'assets/marker.svg',
      size: const Size(50, 50),
    ),
    MarkerData(
      type: MarkerType.green,
      assetName: 'assets/marker.svg',
      size: const Size(60, 60),
    ),
    MarkerData(
      type: MarkerType.blue,
      assetName: 'assets/marker.svg',
      size: const Size(70, 70),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _mapMarkerCache = MapMarkerCache();
    _initCacheAndMarkers();
    _loadNormalMarkers();
  }

  Future<void> _initCacheAndMarkers() async {
    try {
      await _mapMarkerCache.init();

      for (final data in _markerData) {
        final Uint8List bytes = await _mapMarkerCache.getOrBuildAndCacheBytes(
          key: data.type.toString(),
          assetName: data.assetName,
          devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
          size: data.size,
        );
        _cachedMarkerBytes[data.type] = bytes;
      }
    } catch (e) {
      setState(() {
        _errorCache = 'Failed to load cached markers: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoadingCache = false;
      });
    }
  }

  Future<void> _loadNormalMarkers() async {
    try {
      await Future.delayed(const Duration(seconds: 2)); // Atraso artificial para demonstração
      for (final data in _markerData) {
        final Uint8List bytes = await getBitmapDescriptorFromSvgAsset(
          data.assetName,
          MediaQuery.of(context).devicePixelRatio,
          data.size,
        );
        _normalMarkerBytes[data.type] = bytes;
      }
    } catch (e) {
      setState(() {
        _errorNormal = 'Failed to load normal markers: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoadingNormal = false;
      });
    }
  }

  @override
  void dispose() {
    _mapMarkerCache.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Map Marker Cache Example'),
        ),
        body: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Cached Markers', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  _isLoadingCache
                      ? const Center(child: CircularProgressIndicator())
                      : _errorCache != null
                          ? Center(child: Text('Error: $_errorCache'))
                          : Expanded(
                              child: ListView.builder(
                                itemCount: _markerData.length,
                                itemBuilder: (context, index) {
                                  final data = _markerData[index];
                                  final bytes = _cachedMarkerBytes[data.type];
                                  if (bytes == null) return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text('${data.type.name} (Cached)'),
                                        Image.memory(
                                          bytes,
                                          width: data.size.width,
                                          height: data.size.height,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Normal Markers', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  _isLoadingNormal
                      ? const Center(child: CircularProgressIndicator())
                      : _errorNormal != null
                          ? Center(child: Text('Error: $_errorNormal'))
                          : Expanded(
                              child: ListView.builder(
                                itemCount: _markerData.length,
                                itemBuilder: (context, index) {
                                  final data = _markerData[index];
                                  final bytes = _normalMarkerBytes[data.type];
                                  if (bytes == null) return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text('${data.type.name} (Normal)'),
                                        Image.memory(
                                          bytes,
                                          width: data.size.width,
                                          height: data.size.height,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Exemplo de Uso com Google Maps

Este exemplo demonstra como integrar `map_marker_cache` com o pacote `google_maps_flutter` para exibir marcadores otimizados.

**Pré-requisitos:**
- Adicione `google_maps_flutter` ao seu `pubspec.yaml`.
- Configure sua chave de API do Google Maps nos arquivos de projeto nativos (Android: `android/app/src/main/AndroidManifest.xml`, iOS: `ios/Runner/Info.plist`).

**Código Fonte:**

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_marker_cache/map_marker_cache.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MapMarkerCache _mapMarkerCache;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  String? _error;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  @override
  void initState() {
    super.initState();
    _mapMarkerCache = MapMarkerCache();
    _initCacheAndMarkers();
  }

  Future<void> _initCacheAndMarkers() async {
    try {
      await _mapMarkerCache.init();

      final BitmapDescriptor markerIcon = await _mapMarkerCache.getOrBuildAndCacheMarkerIcon(
        key: 'my_custom_marker',
        assetName: 'assets/marker.svg',
        devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
        size: const Size(50, 50),
      );

      _markers.add(
        Marker(
          markerId: const MarkerId('my_marker'),
          position: _center,
          icon: markerIcon,
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to load markers: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _mapMarkerCache.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Map Marker Cache Example'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : GoogleMap(
                    onMapCreated: (GoogleMapController controller) {},
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 11.0,
                    ),
                    markers: _markers,
                  ),
      ),
    );
  }
}
```