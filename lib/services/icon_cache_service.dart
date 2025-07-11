import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';

import '../objectbox.g.dart'; // generated code
import '../models/cached_icon.dart';
import '../utils/svg_converter.dart';

class IconCacheService {
  final Box<CachedIcon> _cachedIconBox;
  final Future<Uint8List> Function(String, double, [Size? size]) _svgConverter;

  IconCacheService(
    Store store, {
    Future<Uint8List> Function(String, double, [Size? size])? svgConverter,
  })  : _cachedIconBox = store.box<CachedIcon>(),
        _svgConverter = svgConverter ?? getBitmapDescriptorFromSvgAsset;

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
