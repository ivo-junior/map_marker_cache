import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../objectbox.g.dart'; // generated code
import '../models/cached_icon.dart';
import '../utils/svg_converter.dart';

/// A service class responsible for handling the logic of caching and retrieving icons.
///
/// This class interacts with the ObjectBox store to persist and fetch icon data.
class IconCacheService {
  final Box<CachedIcon> _cachedIconBox;
  final Future<Uint8List> Function(String, double, [Size? size]) _svgConverter;

  /// Creates an instance of [IconCacheService].
  ///
  /// Requires an ObjectBox [Store] to interact with the database.
  /// Optionally, a custom [svgConverter] function can be provided.
  IconCacheService(
    Store store, {
    Future<Uint8List> Function(String, double, [Size? size])? svgConverter,
  })  : _cachedIconBox = store.box<CachedIcon>(),
        _svgConverter = svgConverter ?? getBitmapDescriptorFromSvgAsset;

  /// Gets an icon from the cache or builds and caches it if it doesn't exist.
  ///
  /// - [key]: A unique identifier for the icon.
  /// - [assetName]: The path to the SVG asset.
  /// - [devicePixelRatio]: The device's pixel ratio for correct scaling.
  /// - [size]: The desired size of the icon.
  ///
  /// Returns the icon data as a `Uint8List`.
  Future<Uint8List> getOrBuildAndCacheIcon({
    required String key,
    required String assetName,
    required double devicePixelRatio,
    Size? size = const Size(20, 20),
  }) async {
    // Find existing icon
    CachedIcon? cachedIcon =
        _cachedIconBox.query(CachedIcon_.key.equals(key)).build().findFirst();

    if (cachedIcon != null) {
      return Uint8List.fromList(cachedIcon.bytes);
    }

    // If not found, build and cache it
    final Uint8List bytes = await _svgConverter(
      assetName,
      devicePixelRatio,
      size,
    );
    final newCachedIcon = CachedIcon(key: key, bytes: bytes);
    _cachedIconBox.put(newCachedIcon);
    return bytes;
  }
}
