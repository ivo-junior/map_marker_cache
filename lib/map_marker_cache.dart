import 'dart:typed_data';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

import 'services/icon_cache_service.dart';

class MapMarkerCache {
  final IconCacheService _iconCacheService;

  MapMarkerCache({
    IconCacheService? iconCacheService,
  }) : _iconCacheService = iconCacheService ?? IconCacheService();

  Future<void> init() async {
    await _iconCacheService.init();
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

  void dispose() {
    _iconCacheService.close();
  }
}
