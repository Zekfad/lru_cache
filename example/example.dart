// example file
// ignore_for_file: prefer_const_constructors, unnecessary_statements

import 'dart:typed_data';

import 'package:lru/lru.dart';

/// Helper class to demonstrate LruWeakCache
class Key {
  const Key(this.key);
  final String key;
  @override
  String toString() => key;
}

void main() {
  {
    // Cannot use weak cache, because String is not supported by Expando
    final cache = LruCache<int, String>(2);

    cache[0] = '0';
    cache[1] = '1';

    cache[0]; // try to touch

    cache[2] = '2'; // key 1 is evicted here


    print(cache[0]); // 0
    print(cache[1]); // null
    print(cache[2]); // 2
  }
  {
    // Use capacityInBytes as additional eviction strategy, on overflow
    // old elements will be removed same as normal LRU capacity
    final cache = LruTypedDataCache<int, Uint8List>(capacity: 100, capacityInBytes: 2);

    cache[0] = Uint8List(1)..[0] = 0;
    cache[1] = Uint8List(1)..[0] = 1;

    cache[0]; // try to touch

    cache[2] = Uint8List(1)..[0] = 2;

    print(cache[0]); // [0]
    print(cache[1]); // null
    print(cache[2]); // [2]
  }
  {
    final cache = LruWeakCache<int, Key>(2);

    cache[0] = Key('0');
    cache[1] = Key('1');
    cache[2] = Key('2'); // key 0 is evicted from main LRU and moved to weak cache

    // if key 0 is not garbage collected yet
    // key 1 is moved to weak cache, and key 0 is restored
    cache[0];

    print(cache[0]); // 0 if key 0 wasn't garbage collected
    print(cache[1]); // 1 if key 0 was garbage collected or if key 1 wasn't GC'd
    print(cache[2]); // 2
  }
}
