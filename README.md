# map_marker_cache

`map_marker_cache` is a Flutter library designed to optimize the loading of custom marker icons for Google Maps by caching `BitmapDescriptor` objects locally using ObjectBox. This significantly reduces the performance overhead associated with converting images (like SVGs) to `BitmapDescriptor` at runtime, especially for applications with many markers or offline capabilities.

## Features
- **Performance Optimization**: Reduces marker rendering time by caching `BitmapDescriptor` objects.
- **Offline Support**: Stores converted image data locally, enabling instant loading even without an internet connection.
- **Simple API**: Provides an easy-to-use API for Flutter developers integrating with Google Maps.
- **SVG to Uint8List Conversion**: Built-in utility for converting SVG assets to `Uint8List` for storage.

## Running the Example
To see `map_marker_cache` in action, you can run the example project:

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

    This will launch a simple Flutter application displaying a Google Map with a custom marker loaded from cache.

## Documentation
For detailed information on installation, basic usage, and architecture, please refer to the [official documentation](docs/index.md).