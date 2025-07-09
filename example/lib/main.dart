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
  final LatLng _center = const LatLng(45.521563, -122.677433);
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _mapMarkerCache = MapMarkerCache();
    _initCacheAndMarkers();
  }

  Future<void> _initCacheAndMarkers() async {
    await _mapMarkerCache.init();
    final BitmapDescriptor markerIcon = await _mapMarkerCache.getOrBuildAndCacheMarkerIcon(
      key: 'my_custom_marker',
      assetName: 'assets/marker.svg',
      devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
      size: const Size(50, 50),
    );

    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('my_marker'),
          position: _center,
          icon: markerIcon,
        ),
      );
    });
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
        body: GoogleMap(
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