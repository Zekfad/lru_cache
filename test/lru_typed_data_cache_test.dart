import 'dart:typed_data';

import 'package:lru/src/lru_typed_data_cache.dart';
import 'package:test/test.dart';

void main() {
  group('LruTypedDataCache', () {
    test('should updata lengthInBytes', () {
      final cache = LruTypedDataCache<int, Uint8List>(capacity: 100, byteCapacity: 1024 * 3);
      cache[1] = Uint8List(1024)..[0] = 1;
      cache[2] = Uint8List(1024)..[0] = 2;

      expect(cache.lengthInBytes, equals(1024 * 2));
    });

    test('should updata lengthInBytes after evict', () {
      final cache = LruTypedDataCache<int, Uint8List>(capacity: 100, byteCapacity: 1024 * 2);
      cache[1] = Uint8List(1024)..[0] = 1;
      cache[2] = Uint8List(1024)..[0] = 2;
      cache[3] = Uint8List(512)..[0] = 3;

      expect(cache.lengthInBytes, equals(1024 + 512));
    });

    test('should evict entries on bytes overflow', () {
      final cache = LruTypedDataCache<int, Uint8List>(capacity: 100, byteCapacity: 1024 * 3);
      cache[1] = Uint8List(1024)..[0] = 1;
      cache[2] = Uint8List(1024)..[0] = 2;
      cache[3] = Uint8List(1024)..[0] = 3;
      cache[4] = Uint8List(1024 * 2)..[0] = 4;

      expect(cache[1], isNull);
      expect(cache[2], isNull);
      expect(cache[3], isNotNull);
      expect(cache[3]![0], equals(3));
      expect(cache[4], isNotNull);
      expect(cache[4]![0], equals(4));
    });

    test('should add entries with size of capacity', () {
      final cache = LruTypedDataCache<int, Uint8List>(capacity: 100, byteCapacity: 1024);
      cache[1] = Uint8List(1024)..[0] = 1;

      expect(cache[1], isNotNull);
      expect(cache[1]![0], equals(1));
    });

    test('should skip entries with size bigger that capacity', () {
      final cache = LruTypedDataCache<int, Uint8List>(capacity: 100, byteCapacity: 2048);
      cache[1] = Uint8List(1024)..[0] = 1;
      cache[2] = Uint8List(3048)..[0] = 2;

      expect(cache.lengthInBytes, equals(1024));

      expect(cache[2], isNull);
      expect(cache[1], isNotNull);
      expect(cache[1]![0], equals(1));
    });
  });
}
