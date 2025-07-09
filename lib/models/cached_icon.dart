import 'package:objectbox/objectbox.dart';

@Entity()
class CachedIcon {
  int id = 0;

  @Index()
  String key;

  @Property(type: PropertyType.byteVector)
  List<int> bytes;

  CachedIcon({
    required this.key,
    required this.bytes,
  });
}
