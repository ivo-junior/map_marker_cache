# map_marker_cache

Bem-vindo à documentação oficial do **map_marker_cache**, um pacote Flutter que facilita o cache local de ícones personalizados de marcadores do Google Maps. Ideal para aplicações com muitos marcadores e necessidades offline.

## Sumário
- [Visão Geral](#visão-geral)
- [Instalação](#instalação)
- [Uso Básico](#uso-básico)
- [Uso com Google Maps](#uso-com-google-maps)
- [Testes](#testes)
- [Arquitetura](docs/arquitetura.md)
- [API (Swagger)](docs/api.md)
- [Exemplos de uso](docs/exemplos.md)
- [Notas para IA](ai-notes.md)
- [FAQ](docs/faq.md)
- [Changelog](docs/changelog.md)
- [Contribuindo](docs/contribuindo.md)

## Visão Geral
`map_marker_cache` foi criado para resolver um problema comum em apps com mapas: o custo elevado de transformar imagens (como SVGs) em `BitmapDescriptor` toda vez que os dados são carregados ou sincronizados.

Este pacote permite:
- Conversão única de imagens para `Uint8List`
- Armazenamento local usando ObjectBox
- Recuperação rápida e eficiente de ícones no mapa
- Redução drástica do tempo de renderização de marcadores
- Compatibilidade com uso offline

Público-alvo: Desenvolvedores Flutter que trabalham com Google Maps, Firebase, apps com sincronização offline-first e performance sensível ao carregamento de marcadores.

## Instalação
Adicione ao seu `pubspec.yaml`:

```yaml
dependencies:
  map_marker_cache:
    path: ../
```

Para uso em um projeto real, após a publicação no pub.dev, a dependência será:

```yaml
dependencies:
  map_marker_cache: ^latest_version
```

Não se esqueça de executar `flutter pub get` após adicionar a dependência.

## Uso Básico

### 1. Inicialização
`MapMarkerCache` é um singleton. Obtenha a instância e inicialize-a uma vez no ciclo de vida da sua aplicação (por exemplo, no `main()` ou no `initState` do seu widget principal). É importante chamar `init()` para configurar o ObjectBox.

```dart
import 'package:map_marker_cache/map_marker_cache.dart';

// No seu main() ou initState de um widget de nível superior
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necessário para acessar assets
  await MapMarkerCache.instance.init(); // Correto: use a instância singleton
  runApp(const MyApp());
}
```

### 2. Obtendo Bytes de Ícones Cacheado
Use o método `getOrBuildAndCacheBytes` para obter um `Uint8List` representando o ícone. Se o ícone já estiver no cache, ele será retornado instantaneamente; caso contrário, será convertido a partir do SVG e armazenado.

Certifique-se de ter o SVG adicionado aos seus assets no `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/your_marker.svg
```

Exemplo de uso:

```dart
import 'dart:typed_data';
import 'package:flutter/material.dart';

Future<Uint8List> _loadIconBytes() async {
  // Acesse a instância singleton diretamente
  final Uint8List iconBytes = await MapMarkerCache.instance.getOrBuildAndCacheBytes(
    key: 'unique_icon_id', // Uma chave única para o seu ícone
    assetName: 'assets/your_icon.svg', // Caminho para o seu arquivo SVG
    devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
    size: const Size(50, 50), // Tamanho desejado para o ícone
  );
  return iconBytes;
}

// Para exibir o ícone:
Image.memory(iconBytes, width: 50, height: 50);
```

### 3. Descarte
Não se esqueça de chamar `dispose()` na instância de `MapMarkerCache` quando a aplicação for encerrada ou quando os recursos não forem mais necessários (por exemplo, no `dispose` do seu widget principal ou em um `onAppLifecycleStateChanged` listener).

```dart
@override
void dispose() {
  MapMarkerCache.instance.dispose(); // Correto: use a instância singleton
  super.dispose();
}
```

## Uso com Google Maps
Para usar `map_marker_cache` com `google_maps_flutter`, você precisará adicionar `google_maps_flutter` ao seu `pubspec.yaml` e configurar sua chave de API do Google Maps nos arquivos de projeto nativos (Android: `android/app/src/main/AndroidManifest.xml`, iOS: `ios/Runner/Info.plist`).

Então, você pode usar o método `getOrBuildAndCacheMarkerIcon` para obter objetos `BitmapDescriptor`:

```dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_marker_cache/map_marker_cache.dart';

// Obtenha a instância singleton e inicialize-a (se ainda não o fez)
final mapMarkerCache = MapMarkerCache();
// await mapMarkerCache.init(); // Se não inicializado globalmente

// Obtenha um BitmapDescriptor cacheado
final BitmapDescriptor markerIcon = await mapMarkerCache.getOrBuildAndCacheMarkerIcon(
  key: 'unique_marker_id', // Uma chave única para o seu ícone
  assetName: 'assets/your_marker.svg', // Caminho para o seu arquivo SVG
  devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
  size: const Size(50, 50), // Tamanho desejado para o ícone
);

// Use o BitmapDescriptor com um Marker do Google Maps
Marker(
  markerId: const MarkerId('marker_1'),
  position: const LatLng(45.521563, -122.677433),
  icon: markerIcon,
);
```

## Testes
O `map_marker_cache` é projetado para ser facilmente testável. Você pode mockar as dependências do ObjectBox e do carregamento de SVG para isolar a lógica de cache.

Para testes de unidade, certifique-se de:
1.  **Inicializar o Flutter Binding**: Adicione `TestWidgetsFlutterBinding.ensureInitialized();` no `setUpAll` do seu arquivo de teste.
2.  **Mockar `PathProviderPlatform`**: Para controlar o diretório de armazenamento do ObjectBox em testes.
3.  **Injetar `svgConverter`**: Ao inicializar `MapMarkerCache` em testes, você pode injetar uma função mock para `svgConverter` no método `init` para controlar o retorno da conversão de SVG.

Exemplo de `setUpAll` e `setUp` em um arquivo de teste:

```dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter/material.dart'; // For Size

import 'package:map_marker_cache/map_marker_cache.dart';
import 'package:map_marker_cache/objectbox.g.dart';
import 'package:map_marker_cache/models/cached_icon.dart';

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

// Mock para a função de conversão SVG
Future<Uint8List> mockSvgConverter(String assetName, double devicePixelRatio, [Size? size]) async {
  return Uint8List.fromList([1, 2, 3, 4]); // Retorna bytes de teste
}

void main() {
  late MapMarkerCache mapMarkerCache;
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    PathProviderPlatform.instance = MockPathProviderPlatform();
    tempDir = await Directory.systemTemp.createTemp('objectbox_test_map_marker_cache');
  });

  setUp(() async {
    mapMarkerCache = MapMarkerCache();
    await mapMarkerCache.init(tempDir.path, mockSvgConverter);
    mapMarkerCache.clearData();
  });

  tearDownAll(() {
    mapMarkerCache.dispose();
    tempDir.deleteSync(recursive: true);
  });

  group('MapMarkerCache', () {
    test('getOrBuildAndCacheMarkerIcon caches and retrieves icon', () async {
      // ... seu teste aqui
    });
  });
}
```

Para um exemplo completo, consulte o diretório `example/` neste repositório.