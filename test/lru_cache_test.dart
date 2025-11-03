import 'package:lru/lru.dart';
import 'package:test/test.dart';

bool get isDebugMode {
  var isDebug = false;
  assert(isDebug = true, 'always true in debug');
  return isDebug;
}

class TestObject {
  TestObject(this.value);

  final String value;

  @override
  String toString() => value;
}

void expectLength<K, V extends Object>(LruCache<K, V> cache, dynamic matcher) {
  expect(cache.length, matcher);
  expect(cache.cache.length, matcher);
  expect(cache.list.length, matcher);
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
      cache[1] = 'uno';
      cache[2] = 'two';
      cache[2] = 'dos';

      expect(cache[1], equals('uno'));
      expect(cache[2], equals('dos'));
    });

    test('updating same with the value should delay object eviction', () {
      final cache = LruCache<int, TestObject>(2);
      final one = TestObject('one');
      final two = TestObject('two');
      final three = TestObject('three');
      cache[1] = one;
      final oneEntry = cache.cache[1];
      expect(oneEntry, isNotNull);
      cache[2] = two;
      cache[1] = one;
      cache[3] = three;

      // check that entry is preserved and not recreated
      expect(cache.cache[1], equals(oneEntry));
      expect(cache[1], equals(one));
      expect(cache[2], isNull);
      expect(cache[3], equals(three));
    });

    test('should maintain size when updating items', () {
      // this test checks that list and map is in sync (same size)
      // during update operation
      const capacity = 3;
      final cache = LruCache<String, int>(capacity);
      expectLength(cache, equals(0));
      for (var i = 0; i < capacity + 1; i++) {
        cache['key'] = i;
        expectLength(cache, equals(1));
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
      // this test checks that list and map is in sync (same size)
      // during multiple add and update operations
      final cache = LruCache<int, TestObject>(2);
      final one = TestObject('one');
      final two = TestObject('two');
      final three = TestObject('three');
      final uno = TestObject('uno');
      final dos = TestObject('dos');

      expectLength(cache, equals(0));
      cache[1] = one;
      expectLength(cache, equals(1));
      cache[2] = two;
      expectLength(cache, equals(2));
      cache[3] = three;
      expectLength(cache, equals(2));
      cache[1] = uno;
      expectLength(cache, equals(2));
      cache[2] = dos;
      expectLength(cache, equals(2));
      // special case: we must ensure that list doesn't grow if we replace
      // object with the same value
      cache[2] = dos;
      expectLength(cache, equals(2));
    });

    test('should be able to clear all items', () {
      final cache = LruCache<int, String>(2);
      cache[1] = 'one';
      cache[2] = 'one';
      cache.clear();

      expectLength(cache, equals(0));
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
