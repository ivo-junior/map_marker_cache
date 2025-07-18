import 'package:flutter/material.dart';
import 'package:map_marker_cache/map_marker_cache.dart';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

/// A simple data class to hold information about a loaded marker.
class LoadedMarker {
  final Uint8List bytes;
  final Size size;
  final String assetPath;

  LoadedMarker({
    required this.bytes,
    required this.size,
    required this.assetPath,
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<LoadedMarker> _loadedMarkers = [];
  bool _isLoading = true;
  String? _error;

  // List of marker assets to load.
  final List<Map<String, dynamic>> _markerAssets = [
    {'path': 'assets/marker.svg', 'size': const Size(50, 50)},
    {'path': 'assets/marker.svg', 'size': const Size(70, 70)},
    {'path': 'assets/marker.svg', 'size': const Size(90, 90)},
  ];

  @override
  void initState() {
    super.initState();
    // We need the context to get devicePixelRatio, so we call this after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMarkers();
    });
  }

  Future<void> _loadMarkers() async {
    if (!mounted) return;
    final double dpr = MediaQuery.of(context).devicePixelRatio;

    try {
      // Initialize the cache.
      await MapMarkerCache.instance.init();

      // Load all markers in parallel.
      final futures = _markerAssets.map((asset) async {
        final String path = asset['path'] as String;
        final Size size = asset['size'] as Size;

        final Uint8List bytes = await MapMarkerCache.instance.getOrBuildAndCacheBytes(
          assetPath: path,
          devicePixelRatio: dpr,
          size: size,
        );
        
        return LoadedMarker(bytes: bytes, size: size, assetPath: path);
      });

      final results = await Future.wait(futures);

      setState(() {
        _loadedMarkers.addAll(results);
      });

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load markers: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error: $_error', textAlign: TextAlign.center),
                  ))
                : ListView.builder(
                    itemCount: _loadedMarkers.length,
                    itemBuilder: (context, index) {
                      final marker = _loadedMarkers[index];

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Image.memory(
                              marker.bytes,
                              width: marker.size.width,
                              height: marker.size.height,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Marker from "${marker.assetPath}"\n(Size: ${marker.size.width}x${marker.size.height})',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}