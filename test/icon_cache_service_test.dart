import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter/material.dart'; // Importar para usar Size

import 'package:map_marker_cache/services/icon_cache_service.dart';
import 'package:map_marker_cache/models/cached_icon.dart';
import 'package:map_marker_cache/objectbox.g.dart'; // generated code

// Mock para PathProviderPlatform
class MockPathProviderPlatform extends MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return './test/temp_objectbox'; // Diretório temporário para testes
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getApplicationDocumentsPath) {
      return super.noSuchMethod(invocation);
    }
    return null; // Return null for any other unimplemented methods
  }
}

// Mock manual para a função getBitmapDescriptorFromSvgAsset
class FakeSvgConverter {
  Uint8List? resultBytes;
  String? lastAssetName;
  double? lastDevicePixelRatio;
  Size? lastSize;
  int callCount = 0;

  Future<Uint8List> call(String assetName, double devicePixelRatio, [Size? size]) async {
    callCount++;
    lastAssetName = assetName;
    lastDevicePixelRatio = devicePixelRatio;
    lastSize = size;
    return resultBytes ?? Uint8List(0);
  }
}

void main() {
  late IconCacheService iconCacheService;
  late FakeSvgConverter fakeSvgConverter;
  late Store store;

  setUpAll(() async {
    // Configura o mock para PathProviderPlatform
    PathProviderPlatform.instance = MockPathProviderPlatform();

    // Inicializa o ObjectBox em um diretório temporário para testes
    store = Store(getObjectBoxModel(), directory: './test/temp_objectbox');
  });

  setUp(() {
    fakeSvgConverter = FakeSvgConverter();
    iconCacheService = IconCacheService(svgConverter: fakeSvgConverter.call);
    // Limpa o banco de dados antes de cada teste
    store.box<CachedIcon>().removeAll(); // Usar removeAll da Box
  });

  tearDownAll(() {
    // Fecha o store e limpa o diretório temporário após todos os testes
    store.close();
    // TODO: Adicionar lógica para remover o diretório temporário
  });

  group('IconCacheService', () {
    test('should cache icon if not found', () async {
      final testBytes = Uint8List.fromList([1, 2, 3, 4]);
      fakeSvgConverter.resultBytes = testBytes;

      await iconCacheService.init();
      final resultBytes = await iconCacheService.getOrBuildAndCacheIcon(
        key: 'test_key',
        assetName: 'assets/test.svg',
        devicePixelRatio: 1.0,
      );

      expect(resultBytes, testBytes);
      expect(fakeSvgConverter.callCount, 1);
      expect(fakeSvgConverter.lastAssetName, 'assets/test.svg');
      expect(fakeSvgConverter.lastDevicePixelRatio, 1.0);

      // Verifica se o ícone foi salvo no ObjectBox
      final cachedIcon = store.box<CachedIcon>().query(CachedIcon_.key.equals('test_key')).build().findFirst();
      expect(cachedIcon, isNotNull);
      expect(cachedIcon!.bytes, testBytes);
    });

    test('should retrieve icon from cache if found', () async {
      final testBytes = Uint8List.fromList([5, 6, 7, 8]);
      // Salva um ícone diretamente no cache para simular um ícone já existente
      store.box<CachedIcon>().put(CachedIcon(key: 'cached_key', bytes: testBytes));

      await iconCacheService.init();
      final resultBytes = await iconCacheService.getOrBuildAndCacheIcon(
        key: 'cached_key',
        assetName: 'assets/cached.svg',
        devicePixelRatio: 1.0,
      );

      expect(resultBytes, testBytes);
      // Verifica que a função de conversão não foi chamada
      expect(fakeSvgConverter.callCount, 0);
    });
  });
}
