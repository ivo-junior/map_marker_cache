# map_marker_cache

`map_marker_cache` is a Flutter library designed to optimize the loading of custom marker icons for Google Maps by caching `BitmapDescriptor` objects locally using ObjectBox. This significantly reduces the performance overhead associated with converting images (like SVGs) to `BitmapDescriptor` at runtime, especially for applications with many markers or offline capabilities.

## Features
- **Performance Optimization**: Reduces marker rendering time by caching `BitmapDescriptor` objects.
- **Offline Support**: Stores converted image data locally, enabling instant loading even without an internet connection.
- **Simple API**: Provides an easy-to-use API for Flutter developers integrating with Google Maps.
- **SVG to Uint8List Conversion**: Built-in utility for converting SVG assets to `Uint8List` for storage.

## Running the Example
To see `map_marker_cache` in action, you can run the example project. The example now demonstrates the caching mechanism by displaying icons loaded from cache versus icons loaded normally (without cache) side-by-side, without requiring a Google Maps API key.

1.  Navigate to the `example/` directory:
    ```bash
    cd example
    ```

2.  Get the project dependencies:
    ```bash
    flutter pub get
    ```

3.  Run the example application:
    ```bash
    flutter run
    ```

    This will launch a simple Flutter application displaying cached and non-cached marker icons.

## Usage with Google Maps
If you wish to use `map_marker_cache` with Google Maps, you will need to add `google_maps_flutter` to your project's `pubspec.yaml` and configure your Google Maps API key in your native project files (Android: `android/app/src/main/AndroidManifest.xml`, iOS: `ios/Runner/Info.plist`).

Then, you can use the `getOrBuildAndCacheMarkerIcon` method to obtain `BitmapDescriptor` objects:

```dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_marker_cache/map_marker_cache.dart';

// Initialize MapMarkerCache (singleton)
final mapMarkerCache = MapMarkerCache();
await mapMarkerCache.init();

// Get a cached BitmapDescriptor
final BitmapDescriptor markerIcon = await mapMarkerCache.getOrBuildAndCacheMarkerIcon(
  key: 'unique_marker_id', // A unique key for your icon
  assetName: 'assets/your_marker.svg', // Path to your SVG asset
  devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
  size: const Size(50, 50), // Desired size for the icon
);

// Use the BitmapDescriptor with a Google Maps Marker
Marker(
  markerId: const MarkerId('marker_1'),
  position: const LatLng(45.521563, -122.677433),
  icon: markerIcon,
);
```

## Documentation
For detailed information on installation, basic usage, and architecture, please refer to the [official documentation](docs/index.md).