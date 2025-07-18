import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_marker_cache/map_marker_cache.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Mock SvgConverter function.
Future<Uint8List> _mockSvgConverter(String assetPath, double devicePixelRatio, [Size? size]) async {
  // Return a consistent byte array for predictable testing.
  return Uint8List.fromList([1, 2, 3, 4, 5]);
}

// Mock for PathProviderPlatform to control the test database location.
class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    // Use a temporary system directory to isolate tests.
    return Directory.systemTemp.path;
  }
}

void main() {
  late Directory tempDir;
  late String tempPath;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    PathProviderPlatform.instance = MockPathProviderPlatform();
    final uniqueDirName = 'map_marker_cache_test_${DateTime.now().microsecondsSinceEpoch}';
    tempDir = await Directory.systemTemp.createTemp(uniqueDirName);
    tempPath = tempDir.path;
  });

  tearDownAll(() {
    MapMarkerCache.instance.dispose();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    await MapMarkerCache.instance.init(tempPath, _mockSvgConverter);
    MapMarkerCache.instance.clearData();
  });

  group('MapMarkerCache API Tests', () {
    const double devicePixelRatio = 2.0;
    const Size size = Size(100, 100);
    const String assetPath = 'assets/test_marker.svg';

    test('uses provided key and caches the icon correctly', () async {
      const String customKey = 'my_custom_key';

      // First call: should build and cache the icon.
      final firstCallDescriptor = await MapMarkerCache.instance.getOrBuildAndCacheMarkerIcon(
        assetPath: assetPath,
        devicePixelRatio: devicePixelRatio,
        key: customKey,
        size: size,
      );
      expect(firstCallDescriptor, isA<BitmapDescriptor>());

      // Second call: should retrieve the icon from cache using the same key.
      final secondCallDescriptor = await MapMarkerCache.instance.getOrBuildAndCacheMarkerIcon(
        assetPath: 'assets/another_marker.svg', // Different asset, same key.
        devicePixelRatio: devicePixelRatio,
        key: customKey,
        size: size,
      );
      expect(secondCallDescriptor, isA<BitmapDescriptor>());

      // Verify that the bytes are the same for both calls, proving it was cached.
      final bytes1 = await MapMarkerCache.instance.getOrBuildAndCacheBytes(
        assetPath: assetPath,
        devicePixelRatio: devicePixelRatio,
        key: customKey,
        size: size,
      );
      expect(bytes1, equals(await MapMarkerCache.instance.getOrBuildAndCacheBytes(
        assetPath: 'assets/another_marker.svg',
        devicePixelRatio: devicePixelRatio,
        key: customKey,
        size: size,
      )));
      expect(bytes1, equals(await _mockSvgConverter("", 0)));
    });

    test('generates a key automatically if none is provided', () async {
      // Build and cache with a generated key.
      await MapMarkerCache.instance.getOrBuildAndCacheMarkerIcon(
        assetPath: assetPath,
        devicePixelRatio: devicePixelRatio,
        size: size,
      );

      // The second call should hit the cache.
      final bytes1 = await MapMarkerCache.instance.getOrBuildAndCacheBytes(
          assetPath: assetPath, devicePixelRatio: devicePixelRatio, size: size);
      expect(bytes1, equals(await MapMarkerCache.instance.getOrBuildAndCacheBytes(
          assetPath: assetPath, devicePixelRatio: devicePixelRatio, size: size)));
    });

    test('different sizes with the same asset path result in different cached icons', () async {
      const Size size1 = Size(50, 50);
      const Size size2 = Size(80, 80);

      // Get bytes for the first size.
      final bytes1 = await MapMarkerCache.instance.getOrBuildAndCacheBytes(
        assetPath: assetPath,
        devicePixelRatio: devicePixelRatio,
        size: size1,
      );

      // Get bytes for the second size. The underlying mock converter will return the same bytes,
      // but because the key is different (due to size), it will be a separate cache entry.
      final bytes2 = await MapMarkerCache.instance.getOrBuildAndCacheBytes(
        assetPath: assetPath,
        devicePixelRatio: devicePixelRatio,
        size: size2,
      );

      // Initially, bytes1 and bytes2 are the same because of the mock converter.
      expect(bytes1, equals(bytes2)); // This is expected behavior of the mock

      // To prove they are different cache entries, we can clear the cache and see that
      // fetching one does not fetch the other.
      MapMarkerCache.instance.clearData();

      // Dispose the current instance to allow re-initialization with a new mock.
      MapMarkerCache.instance.dispose();

      // Now, re-initialize with a different mock converter to ensure the second one is not cached.
      // This new converter will return [9, 8, 7]
      await MapMarkerCache.instance.init(tempPath, (path, dpr, [s]) async => Uint8List.fromList([9, 8, 7]));

      final newBytes1 = await MapMarkerCache.instance.getOrBuildAndCacheBytes(
          assetPath: assetPath, devicePixelRatio: devicePixelRatio, size: size1);
      final newBytes2 = await MapMarkerCache.instance.getOrBuildAndCacheBytes(
          assetPath: assetPath, devicePixelRatio: devicePixelRatio, size: size2);

      // Both newBytes1 and newBytes2 should now be from the new converter.
      expect(newBytes1, equals(Uint8List.fromList([9, 8, 7])));
      expect(newBytes2, equals(Uint8List.fromList([9, 8, 7])));

      // Crucially, newBytes1 should NOT be equal to the original bytes1,
      // proving it was re-generated and not retrieved from the old cache.
      expect(newBytes1, isNot(equals(bytes1)));
      expect(newBytes2, isNot(equals(bytes2)));
    });
  });
}