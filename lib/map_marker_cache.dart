import 'dart:typed_data';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'objectbox.g.dart';
import 'models/cached_icon.dart';
import 'services/icon_cache_service.dart';

class MapMarkerCache {
  late final Store _store;
  late final IconCacheService _iconCacheService;

  // Private constructor to control instantiation
  MapMarkerCache._();

  // Static instance for the singleton
  static final MapMarkerCache _instance = MapMarkerCache._();

  // Factory constructor to return the singleton instance
  factory MapMarkerCache() {
    return _instance;
  }

  Future<void> init([String? directory, Future<Uint8List> Function(String, double, [Size? size])? svgConverter]) async {
    final docsDir = await getApplicationDocumentsDirectory();
    _store = Store(
      getObjectBoxModel(),
      directory: directory ?? p.join(docsDir.path, "map_marker_cache"),
    );
    _iconCacheService = IconCacheService(_store, svgConverter: svgConverter);
  }

  Future<BitmapDescriptor> getOrBuildAndCacheMarkerIcon({
    required String key,
    required String assetName,
    required double devicePixelRatio,
    Size size = const Size(20, 20),
  }) async {
    final Uint8List bytes = await _iconCacheService.getOrBuildAndCacheIcon(
      key: key,
      assetName: assetName,
      devicePixelRatio: devicePixelRatio,
      size: size,
    );
    return BitmapDescriptor.bytes(bytes);
  }

  Future<Uint8List> getOrBuildAndCacheBytes({
    required String key,
    required String assetName,
    required double devicePixelRatio,
    Size size = const Size(20, 20),
  }) async {
    return await _iconCacheService.getOrBuildAndCacheIcon(
      key: key,
      assetName: assetName,
      devicePixelRatio: devicePixelRatio,
      size: size,
    );
  }

  void dispose() {
    _store.close();
  }

  void clearData() {
    _store.box<CachedIcon>().removeAll();
  }
}
