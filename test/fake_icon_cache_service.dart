import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:map_marker_cache/services/icon_cache_service.dart';

class FakeIconCacheService implements IconCacheService {
  bool initCalled = false;
  bool closeCalled = false;
  Uint8List? getOrBuildAndCacheIconResult;

  @override
  Future<void> init() async {
    initCalled = true;
  }

  @override
  void close() {
    closeCalled = true;
  }

  @override
  Future<Uint8List> getOrBuildAndCacheIcon({
    String? key,
    String? assetName,
    double? devicePixelRatio,
    Size? size,
  }) async {
    return getOrBuildAndCacheIconResult ?? Uint8List(0);
  }
}