# Example Usage of map_marker_cache

This project demonstrates the `map_marker_cache` Flutter library in action. It showcases the performance benefits of caching marker icons by displaying two columns of SVG images: one loaded using the caching mechanism provided by `map_marker_cache`, and another loaded directly (without caching).

## Getting Started

To run this example, follow these steps:

1.  Navigate to the `example/` directory in your terminal:
    ```bash
    cd example
    ```

2.  Get the project dependencies:
    ```bash
    flutter pub get
    ```

3.  Run the application on a connected device or desktop platform (e.g., Windows, macOS, Linux):
    ```bash
    flutter run
    ```
    If you have multiple devices connected, you might need to specify one (e.g., `flutter run -d windows`).

## What You'll See

The application will display a screen with two columns:

-   **Cached Markers**: These icons are loaded and cached by `map_marker_cache`. Subsequent loads of the same icon will be significantly faster.
-   **Normal Markers**: These icons are loaded directly from assets and converted on each display, simulating a scenario without caching. You might observe a slight delay or a loading indicator for these, especially on the first load, due to an artificial delay added for demonstration purposes.

This visual comparison highlights how `map_marker_cache` can improve the loading performance of custom marker icons in your Flutter applications.

For more detailed documentation on the `map_marker_cache` library itself, including its API and how to integrate it into your own projects, please refer to the [main project documentation](../docs/index.md).