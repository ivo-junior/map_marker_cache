import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';

import '../objectbox.g.dart'; // generated code
import '../models/cached_icon.dart';
import '../utils/svg_converter.dart';

class IconCacheService {
  late Store _store;
  late Box<CachedIcon> _cachedIconBox;
  final Future<Uint8List> Function(String, double, [Size? size]) _svgConverter;

  IconCacheService({
    Future<Uint8List> Function(String, double, [Size? size])? svgConverter,
  }) : _svgConverter = svgConverter ?? getBitmapDescriptorFromSvgAsset;

  Future<void> init() async {
    final docsDir = await getApplicationDocumentsDirectory();
    // Future versions of ObjectBox will allow to place the database file in a sub-directory.
    // For now, we use the main directory.
    _store = Store(
      getObjectBoxModel(),
      directory: p.join(docsDir.path, "objectbox"),
    );
    _cachedIconBox = _store.box<CachedIcon>();
  }

  Future<Uint8List> getOrBuildAndCacheIcon({
    String? key,
    String? assetName,
    double? devicePixelRatio,
    Size? size = const Size(20, 20),
  }) async {
    CachedIcon? cachedIcon =
        _cachedIconBox.query(CachedIcon_.key.equals(key!)).build().findFirst();

    if (cachedIcon != null) {
      return Uint8List.fromList(cachedIcon.bytes);
    } else {
      final Uint8List bytes = await _svgConverter(
        assetName!,
        devicePixelRatio!,
        size,
      );
      final newCachedIcon = CachedIcon(key: key, bytes: bytes);
      _cachedIconBox.put(newCachedIcon);
      return bytes;
    }
  }

  void close() {
    _store.close();
  }
}
