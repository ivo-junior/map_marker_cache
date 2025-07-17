# Changelog

## 1.0.0+1

*   Initial release.
*   Refactored IconCacheService for improved testability.
*   Implemented MapMarkerCache as a singleton managing ObjectBox lifecycle.
*   Enhanced example application to demonstrate cached vs. normal icon loading.
*   Updated `pubspec.yaml` with `homepage` and `repository` fields.
*   Improved `README.md` with dedicated installation and clearer usage sections.
*   Added comprehensive API documentation comments (`///`) to all public members.
*   Fixed singleton usage in `example/lib/main.dart` and `test/map_marker_cache_test.dart`.
*   Corrected `.gitignore` to properly include ObjectBox generated files (`objectbox.g.dart`, `objectbox-model.json`).
*   Renamed `docs` directory to `doc` to comply with `pub.dev` conventions.
