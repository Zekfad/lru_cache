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
    // no weak cache, because String is not supported by Expando
    final cache = LruCache<int, String>(2);

    cache[0] = '0';
    cache[1] = '1';
    cache[2] = '2'; // key 0 is evicted here

    cache[0]; // try to touch

    print(cache[0]); // null
    print(cache[1]); // 1
    print(cache[2]); // 2
  }
  {
    // use capacityInBytes as additional eviction strategy
    final cache = LruTypedDataCache<int, Uint8List>(capacity: 100, capacityInBytes: 2);
    cache[0] = Uint8List(1)..[0] = 0;
    cache[1] = Uint8List(1)..[0] = 1;
    cache[2] = Uint8List(1)..[0] = 2;

    print(cache[0]); // null
    print(cache[1]); // [1]
    print(cache[2]); // [2]
  }
  {
    final cache = LruWeakCache<int, Key>(2);

    cache[0] = Key('0');
    cache[1] = Key('1');
    cache[2] = Key('2'); // key 0 is evicted from LRU and moved to weak cache

    // try to touch, if key 0 is not garbage collected yet
    // key 1 is moved to weak cache, and key 0 is restored
    cache[0];

    print(cache[0]); // likely 0
    print(cache[1]); // likely 1
    print(cache[2]); // 2
  }
}
