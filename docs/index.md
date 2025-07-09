# map_marker_cache

Bem-vindo à documentação oficial do **map_marker_cache**, um pacote Flutter que facilita o cache local de ícones personalizados de marcadores do Google Maps. Ideal para aplicações com muitos marcadores e necessidades offline.

## Sumário
- [Visão Geral](#visão-geral)
- [Instalação](docs/instalacao.md)
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
  map_marker_cache: ^0.0.1
