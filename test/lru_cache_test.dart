import 'package:lru/lru.dart';
import 'package:test/test.dart';

bool get isDebugMode {
  var isDebug = false;
  assert(isDebug = true, 'always true in debug');
  return isDebug;
}

void main() {
  group('LruCache', () {
    test('should add and retrieve values', () {
      final cache = LruCache<int, String>(2);
      cache[1] = 'one';
      cache[2] = 'two';

      expect(cache[1], equals('one'));
      expect(cache[2], equals('two'));
    });

    test('should evict least recently used item', () {
      final cache = LruCache<int, String>(2);
      cache[1] = 'one';
      cache[2] = 'two';
      cache[3] = 'three';

      expect(cache[1], isNull);
      expect(cache[2], equals('two'));
      expect(cache[3], equals('three'));
    });

    test('should update value of existing key', () {
      final cache = LruCache<int, String>(2);
      cache[1] = 'one';
      cache[1] = 'uno';

      expect(cache[1], equals('uno'));
    });

    test('should update value of existing key when cache is full', () {
      final cache = LruCache<int, String>(2);
      cache[1] = 'one';
      cache[2] = 'two';
      cache[1] = 'uno';

      expect(cache[1], equals('uno'));
      expect(cache[2], equals('two'));
    });

    test('should not evict any entries when updating', () {
      final cache = LruCache<int, String>(2);
      cache[1] = 'one';
      expect(cache.length, equals(1));
      cache[1] = 'uno';
      expect(cache.length, equals(1));
      cache[2] = 'two';
      expect(cache.length, equals(2));
      cache[2] = 'dos';
      expect(cache.length, equals(2));
    });

    test('should evict when updating only if the cache is full', () {
      const capacity = 3;
      final cache = LruCache<String, int>(capacity);
      for (var i = 0; i < capacity + 1; i++) {
        cache['key'] = i;
        expect(cache.length, equals(1));
      }
    });

    test('should not evict recently used item', () {
      final cache = LruCache<int, String>(2);
      cache[1] = 'one';
      cache[2] = 'two';
      expect(cache[1], equals('one')); // accesses 1 and moves it up
      cache[3] = 'three';

      expect(cache[1], equals('one'));
      expect(cache[2], isNull);
      expect(cache[3], equals('three'));
    });

    test('should support manual key removal', () {
      final cache = LruCache<int, String>(2);
      cache[1] = 'one';
      cache[2] = 'two';
      cache.remove(2);

      expect(cache[1], equals('one'));
      expect(cache[2], isNull);
    });

    test('should return null for non-existent key', () {
      final cache = LruCache<int, String>(2);
      cache[1] = 'one';
      cache[2] = 'two';

      expect(cache[1], equals('one'));
      expect(cache[2], equals('two'));
      expect(cache[3], isNull);
    });

    test('should return correct size', () {
      final cache = LruCache<int, String>(2);
      cache[1] = 'one';

      expect(cache.length, equals(1));
    });

    test('should be able to clear all items', () {
      final cache = LruCache<int, String>(2);
      cache[1] = 'one';
      cache[2] = 'one';
      cache.clear();

      expect(cache.length, equals(0));
      expect(cache[1], isNull);
      expect(cache[2], isNull);
    });

    test('should not allow negative capacity in debug', skip: !isDebugMode, () {
      expect(() => LruCache<int, String>(-1), throwsA(isA<AssertionError>()));
    });

    test('should allow zero capacity', () {
      expect(LruCache<int, String>(0), isA<LruCache<int, String>>());
    });
  });
}
