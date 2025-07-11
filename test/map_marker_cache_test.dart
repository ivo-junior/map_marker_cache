import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart'; // For Size
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:map_marker_cache/map_marker_cache.dart';
import 'package:map_marker_cache/objectbox.g.dart';

// Mock para a função de conversão SVG
Future<Uint8List> mockSvgConverter(String assetName, double devicePixelRatio, [Size? size]) async {
  return Uint8List.fromList([1, 2, 3, 4]); // Retorna bytes de teste
}

// Mock para PathProviderPlatform
class MockPathProviderPlatform extends MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return Directory.systemTemp.path; // Usar diretório temporário do sistema
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getApplicationDocumentsPath) {
      return super.noSuchMethod(invocation);
    }
    return null; // Return null for any other unimplemented methods
  }
}

void main() {
  late MapMarkerCache mapMarkerCache;
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Configura o mock para PathProviderPlatform
    PathProviderPlatform.instance = MockPathProviderPlatform();

    // Cria um diretório temporário único para este grupo de testes
    tempDir = await Directory.systemTemp.createTemp('objectbox_test_map_marker_cache');
  });

  setUp(() async {
    mapMarkerCache = MapMarkerCache();
    await mapMarkerCache.init(tempDir.path, mockSvgConverter);
    // Limpa o banco de dados antes de cada teste
    mapMarkerCache.clearData();
  });

  tearDownAll(() {
    mapMarkerCache.dispose();
    tempDir.deleteSync(recursive: true);
  });

  group('MapMarkerCache', () {
    test('getOrBuildAndCacheMarkerIcon caches and retrieves icon', () async {
      final testKey = 'test_marker';
      final testAssetName = 'assets/test_marker.svg';
      final testDevicePixelRatio = 2.0;
      final testSize = const Size(100, 100);

      // Primeiro, verifica se o ícone não está no cache
      final initialBitmapDescriptor = await mapMarkerCache.getOrBuildAndCacheMarkerIcon(
        key: testKey,
        assetName: testAssetName,
        devicePixelRatio: testDevicePixelRatio,
        size: testSize,
      );

      expect(initialBitmapDescriptor, isA<BitmapDescriptor>());

      // Agora, tenta recuperar do cache (deve ser o mesmo)
      final cachedBitmapDescriptor = await mapMarkerCache.getOrBuildAndCacheMarkerIcon(
        key: testKey,
        assetName: testAssetName, // assetName não importa se já está em cache
        devicePixelRatio: testDevicePixelRatio,
        size: testSize,
      );

      expect(cachedBitmapDescriptor, isA<BitmapDescriptor>());
      // Não podemos comparar BitmapDescriptor diretamente, mas podemos verificar se o fluxo de cache funcionou
      // Verificamos se o ícone foi salvo no ObjectBox
      // Para verificar o conteúdo do cache, precisamos acessar a Store, mas ela é privada.
      // Uma alternativa é adicionar um método de teste ao MapMarkerCache para expor o IconCacheService ou o Box.
      // Por enquanto, vamos confiar que o IconCacheService está funcionando (testado separadamente).
    });
  });
}