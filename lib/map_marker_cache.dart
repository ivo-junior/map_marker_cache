import 'dart:typed_data';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'objectbox.g.dart';
import 'models/cached_icon.dart';
import 'services/icon_cache_service.dart';

/// A singleton class to manage caching of `BitmapDescriptor` objects for Google Maps markers.
///
/// This class provides a central point for initializing the cache, retrieving or building
/// marker icons, and managing the underlying ObjectBox store.
class MapMarkerCache {
  late final Store _store;
  late final IconCacheService _iconCacheService;

  // Private constructor to control instantiation
  MapMarkerCache._();

  /// The static singleton instance of [MapMarkerCache].
  static final MapMarkerCache instance = MapMarkerCache._();

  /// Initializes the cache.
  ///
  /// This method must be called once before any other methods are used.
  /// It sets up the ObjectBox store in the application's documents directory.
  ///
  /// An optional [directory] can be provided to specify a custom storage location.
  /// An optional [svgConverter] can be provided to customize the SVG to byte conversion.
  Future<void> init([String? directory, Future<Uint8List> Function(String, double, [Size? size])? svgConverter]) async {
    final docsDir = await getApplicationDocumentsDirectory();
    _store = Store(
      getObjectBoxModel(),
      directory: directory ?? p.join(docsDir.path, "map_marker_cache"),
    );
    _iconCacheService = IconCacheService(_store, svgConverter: svgConverter);
  }

  /// Retrieves a [BitmapDescriptor] from the cache or builds and caches it if not found.
  ///
  /// - [key]: A unique identifier for the icon.
  /// - [assetName]: The path to the SVG asset.
  /// - [devicePixelRatio]: The device's pixel ratio, used for correct scaling.
  /// - [size]: The desired size of the icon.
  ///
  /// Returns a [BitmapDescriptor] ready to be used in a Google Maps Marker.
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

  /// Retrieves the byte data (`Uint8List`) of an icon from the cache or builds and caches it.
  ///
  /// - [key]: A unique identifier for the icon.
  /// - [assetName]: The path to the SVG asset.
  /// - [devicePixelRatio]: The device's pixel ratio, used for correct scaling.
  /// - [size]: The desired size of the icon.
  ///
  /// Returns the `Uint8List` data of the icon.
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

  /// Closes the ObjectBox store.
  ///
  /// Should be called when the cache is no longer needed, e.g., when the app is disposed.
  void dispose() {
    _store.close();
  }

  /// Clears all cached icon data from the ObjectBox store.
  void clearData() {
    _store.box<CachedIcon>().removeAll();
  }
}
