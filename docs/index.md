# map_marker_cache

Bem-vindo à documentação oficial do **map_marker_cache**, um pacote Flutter que facilita o cache local de ícones personalizados de marcadores do Google Maps. Ideal para aplicações com muitos marcadores e necessidades offline.

## Sumário
- [Visão Geral](#visão-geral)
- [Instalação](#instalação)
- [Uso Básico](#uso-básico)
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
Primeiro, inicialize o `MapMarkerCache` no `initState` do seu widget. É importante chamar `init()` para configurar o ObjectBox.

```dart
import 'package:map_marker_cache/map_marker_cache.dart';

late MapMarkerCache _mapMarkerCache;

@override
void initState() {
  super.initState();
  _mapMarkerCache = MapMarkerCache();
  _initCache();
}

Future<void> _initCache() async {
  await _mapMarkerCache.init();
}
```

### 2. Obtendo um `BitmapDescriptor` Cacheado
Use o método `getOrBuildAndCacheMarkerIcon` para obter um `BitmapDescriptor`. Se o ícone já estiver no cache, ele será retornado instantaneamente; caso contrário, será convertido a partir do SVG e armazenado.

Certifique-se de ter o SVG adicionado aos seus assets no `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/your_marker.svg
```

Exemplo de uso:

```dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<void> _loadMarker() async {
  final BitmapDescriptor markerIcon = await _mapMarkerCache.getOrBuildAndCacheMarkerIcon(
    key: 'unique_marker_id', // Uma chave única para o seu ícone
    assetName: 'assets/your_marker.svg', // Caminho para o seu arquivo SVG
    size: const Size(50, 50), // Tamanho desejado para o ícone
  );

  setState(() {
    _markers.add(
      Marker(
        markerId: const MarkerId('marker_1'),
        position: const LatLng(45.521563, -122.677433),
        icon: markerIcon,
      ),
    );
  });
}
```

### 3. Descarte
Não se esqueça de chamar `dispose()` no `dispose` do seu widget para fechar o banco de dados ObjectBox e liberar recursos.

```dart
@override
void dispose() {
  _mapMarkerCache.dispose();
  super.dispose();
}
```

Para um exemplo completo, consulte o diretório `example/` neste repositório.