import 'package:objectbox/objectbox.dart';

/// An ObjectBox entity representing a cached icon.
@Entity()
class CachedIcon {
  /// The unique ID of the entity.
  int id = 0;

  /// A unique key to identify the cached icon.
  @Index()
  String key;

  /// The byte data of the icon, stored as a `Uint8List`.
  @Property(type: PropertyType.byteVector)
  List<int> bytes;

  /// Creates a new instance of [CachedIcon].
  CachedIcon({
    required this.key,
    required this.bytes,
  });
}
