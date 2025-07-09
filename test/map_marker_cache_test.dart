import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart'; // For Size

import 'package:map_marker_cache/map_marker_cache.dart';
import 'package:map_marker_cache/services/icon_cache_service.dart';
import 'fake_icon_cache_service.dart';

void main() {
  late MapMarkerCache mapMarkerCache;
  late FakeIconCacheService fakeIconCacheService;

  setUp(() {
    fakeIconCacheService = FakeIconCacheService();
    mapMarkerCache = MapMarkerCache(iconCacheService: fakeIconCacheService);
  });

  group('MapMarkerCache', () {
    test('init calls iconCacheService.init', () async {
      await mapMarkerCache.init();
      expect(fakeIconCacheService.initCalled, isTrue);
    });

    test('dispose calls iconCacheService.close', () {
      mapMarkerCache.dispose();
      expect(fakeIconCacheService.closeCalled, isTrue);
    });

    test('getOrBuildAndCacheMarkerIcon calls iconCacheService.getOrBuildAndCacheIcon and returns BitmapDescriptor', () async {
      final testBytes = Uint8List.fromList([5, 6, 7, 8]);
      fakeIconCacheService.getOrBuildAndCacheIconResult = testBytes;

      final resultBitmapDescriptor = await mapMarkerCache.getOrBuildAndCacheMarkerIcon(
        key: 'test_marker',
        assetName: 'assets/test_marker.svg',
        devicePixelRatio: 2.0,
        size: const Size(100, 100),
      );

      expect(resultBitmapDescriptor, isA<BitmapDescriptor>());
      // We can't verify the exact arguments with a simple fake, but we can check the result.
    });
  });
}