# map_marker_cache

`map_marker_cache` is a Flutter library designed to optimize the loading of custom marker icons for Google Maps by caching `BitmapDescriptor` objects locally using ObjectBox. This significantly reduces the performance overhead associated with converting images (like SVGs) to `BitmapDescriptor` at runtime, especially for applications with many markers or offline capabilities.

## Features
- **Performance Optimization**: Reduces marker rendering time by caching `BitmapDescriptor` objects.
- **Offline Support**: Stores converted image data locally, enabling instant loading even without an internet connection.
- **Simple API**: Provides an easy-to-use API for Flutter developers integrating with Google Maps.
- **SVG to Uint8List Conversion**: Built-in utility for converting SVG assets to `Uint8List` for storage.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  map_marker_cache: ^1.0.0 # Replace with the latest version
```

Then, install it by running:
```bash
flutter pub get
```

## Usage

### 1. Initialize the Cache

First, get an instance of `MapMarkerCache` and initialize it. This should be done once when your application starts.

```dart
import 'package:map_marker_cache/map_marker_cache.dart';

// Initialize MapMarkerCache (singleton)
await MapMarkerCache.instance.init();
```

### 2. Get or Create a Marker Icon

Use the `getOrBuildAndCacheMarkerIcon` method to get a `BitmapDescriptor`. If the icon is already in the cache, it will be loaded instantly. If not, it will be created from the asset, cached, and then returned.

```dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_marker_cache/map_marker_cache.dart';

// Get a cached BitmapDescriptor
final BitmapDescriptor markerIcon = await MapMarkerCache.instance.getOrBuildAndCacheMarkerIcon(
  assetPath: 'assets/your_marker.svg', // Path to your SVG asset
  // Optional: A unique key for your icon. If not provided, the assetPath is used as the key.
  // key: 'unique_marker_id', 
  // Optional: Specify the desired size.
  // size: const Size(90, 90),
);

// Use the BitmapDescriptor with a Google Maps Marker
Marker(
  markerId: const MarkerId('marker_1'),
  position: const LatLng(45.521563, -122.677433),
  icon: markerIcon,
);
```

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
