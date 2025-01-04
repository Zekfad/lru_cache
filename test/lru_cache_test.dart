import 'package:lru_cache/lru_cache.dart';
import 'package:test/test.dart';


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

        test('should not evict recently used item', () {
            final cache = LruCache<int, String>(2);
            cache[1] = 'one';
            cache[2] = 'two';
            final _ = cache[1];
            cache[3] = 'three';

            expect(cache[1], equals('one'));
            expect(cache[2], isNull);
            expect(cache[3], equals('three'));
        });

        test('should return null for non-existent key', () async {
            final cache = LruCache<int, String>(2);
            cache[1] = 'one';
            cache[2] = 'two';
            cache.remove(2);

            expect(cache[1], equals('one'));
            expect(cache[2], isNull);
        });

        test('should return correct size', () async {
            final cache = LruCache<int, String>(2);
            cache[1] = 'one';

            expect(cache.length, equals(1));
        });

        test('should be able to clear all items', () async {
            final cache = LruCache<int, String>(2);
            cache[1] = 'one';
            cache[2] = 'one';
            cache.clear();

            expect(cache.length, equals(0));
        });

        test('should not allow negative size', () {
            expect(() => LruCache<int, String>(-1), throwsA(isA<AssertionError>()));
        });
    });
}
