import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future<Uint8List> getBitmapDescriptorFromSvgAsset(
  String assetName,
  double devicePixelRatio, [
  Size? size,
]) async {
  final effectiveSize = size ?? const Size(20, 20);
  final pictureInfo = await vg.loadPicture(SvgAssetLoader(assetName), null);

  int width = (effectiveSize.width * devicePixelRatio).toInt();
  int height = (effectiveSize.height * devicePixelRatio).toInt();

  final scaleFactor = min(
    width / pictureInfo.size.width,
    height / pictureInfo.size.height,
  );

  final recorder = ui.PictureRecorder();

  ui.Canvas(recorder)
    ..scale(scaleFactor)
    ..drawPicture(pictureInfo.picture);

  final rasterPicture = recorder.endRecording();

  final image = await rasterPicture.toImage(width, height);
  final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;

  return bytes.buffer.asUint8List();
}
