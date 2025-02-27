import 'dart:typed_data';

import 'package:lru/src/lru_typed_data_cache.dart';
import 'package:test/test.dart';


bool get isDebugMode {
  var isDebug = false;
  assert(isDebug = true, 'always true in debug');
  return isDebug;
}

void main() {
  group('LruTypedDataCache', () {
    test('should track lengthInBytes', () {
      final cache = LruTypedDataCache<int, Uint8List>(capacity: 100, capacityInBytes: 1024 * 3);
      cache[1] = Uint8List(1024)..[0] = 1;
      cache[2] = Uint8List(1024)..[0] = 2;

      expect(cache.lengthInBytes, equals(1024 * 2));
    });

    test('should evict entries on bytes overflow', () {
      final cache = LruTypedDataCache<int, Uint8List>(capacity: 100, capacityInBytes: 1024 * 3);
      cache[1] = Uint8List(1024)..[0] = 1;
      cache[2] = Uint8List(1024)..[0] = 2;
      cache[3] = Uint8List(1024)..[0] = 3;
      cache[4] = Uint8List(1024 * 2)..[0] = 4;

      expect(cache[1], isNull);
      expect(cache[2], isNull);
      final third = cache[3];
      expect(third, isNotNull);
      expect(third![0], equals(3));
      final fourth = cache[4];
      expect(fourth, isNotNull);
      expect(fourth![0], equals(4));
    });

    test('should update lengthInBytes after entry eviction', () {
      final cache = LruTypedDataCache<int, Uint8List>(capacity: 100, capacityInBytes: 1024 * 2);
      cache[1] = Uint8List(1024)..[0] = 1;
      cache[2] = Uint8List(1024)..[0] = 2;
      cache[3] = Uint8List(512)..[0] = 3;

      expect(cache.lengthInBytes, equals(1024 + 512));
    });

    test('should not add entries that are larger than capacity in bytes', () {
      final cache = LruTypedDataCache<int, Uint8List>(capacity: 100, capacityInBytes: 2048);
      cache[1] = Uint8List(1024)..[0] = 1;
      cache[2] = Uint8List(3072)..[0] = 2;

      expect(cache.lengthInBytes, equals(1024));

      expect(cache[2], isNull);
      final first = cache[1];
      expect(first, isNotNull);
      expect(first![0], equals(1));
    });

    test('should add entries that are same size as capacity in bytes', () {
      final cache = LruTypedDataCache<int, Uint8List>(capacity: 100, capacityInBytes: 1024);
      cache[1] = Uint8List(1024)..[0] = 1;

      expect(cache.lengthInBytes, equals(1024));
      expect(cache.lengthInBytes, equals(cache.capacityInBytes));

      final first = cache[1];
      expect(first, isNotNull);
      expect(first![0], equals(1));
    });

    test('should not allow negative capacity in debug', skip: !isDebugMode, () {
      expect(
        () => LruTypedDataCache<int, Uint8List>(capacity: -1, capacityInBytes: 1024),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should allow zero capacity', () {
      expect(
        LruTypedDataCache<int, Uint8List>(capacity: 0, capacityInBytes: 1024),
        isA<LruTypedDataCache<int, Uint8List>>(),
      );
    });

    test('should not allow negative bytes capacity in debug', skip: !isDebugMode, () {
      expect(
        () => LruTypedDataCache<int, Uint8List>(capacity: 1, capacityInBytes: -1024),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should allow zero bytes capacity capacity', () {
      expect(
        LruTypedDataCache<int, Uint8List>(capacity: 1, capacityInBytes: 0),
        isA<LruTypedDataCache<int, Uint8List>>(),
      );
    });
  });
}
