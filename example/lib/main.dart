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
    _initCacheAndMarkers();
    _loadNormalMarkers();
  }

  Future<void> _initCacheAndMarkers() async {
    final double currentDevicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    try {
      await MapMarkerCache.instance.init();

      for (final data in _markerData) {
        final Uint8List bytes = await MapMarkerCache.instance.getOrBuildAndCacheBytes(
          key: data.type.toString(),
          assetName: data.assetName,
          devicePixelRatio: currentDevicePixelRatio,
          size: data.size,
        );
        _cachedMarkerBytes[data.type] = bytes;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorCache = 'Failed to load cached markers: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCache = false;
        });
      }
    }
  }

  Future<void> _loadNormalMarkers() async {
    final double currentDevicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    try {
      await Future.delayed(const Duration(seconds: 2)); // Atraso artificial para demonstração
      for (final data in _markerData) {
        final Uint8List bytes = await getBitmapDescriptorFromSvgAsset(
          data.assetName,
          currentDevicePixelRatio,
          data.size,
        );
        _normalMarkerBytes[data.type] = bytes;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorNormal = 'Failed to load normal markers: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingNormal = false;
        });
      }
    }
  }

  @override
  void dispose() {
    MapMarkerCache.instance.dispose();
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