# LRU Cache

[![pub package](https://img.shields.io/pub/v/lru.svg)](https://pub.dev/packages/lru)
[![package publisher](https://img.shields.io/pub/publisher/lru.svg)](https://pub.dev/packages/lru/publisher)

Cache based on Least Recently Used evict strategy.

Supports caching more than capacity via Week references (such values are cached
until they garbage collected).

## Features

* Supports full `Map` interface.
* Store `TypedData` and evict entries by bytes capacity via `LruTypedDataCache`.
* Expando compatible objects can be optionally cached via `LruWeakCache`.

## Usage

Create cache, add values, when space is exhausted;

```dart
// no weak cache, because String is not supported by Expando
final cache = new LruCache<int, String>(2);

cache[0] = '0';
cache[1] = '1';
cache[2] = '2'; // key 0 is evicted here

cache[0]; // try to touch

print(cache[0]); // null
print(cache[1]); // 1
print(cache[2]); // 2
```

Example with bytes capacity for `TypedData`.

```dart
// use capacityInBytes as additional eviction strategy
final cache = LruTypedDataCache<int, Uint8List>(capacity: 100, capacityInBytes: 2);
cache[0] = Uint8List(1)..[0] = 0;
cache[1] = Uint8List(1)..[0] = 1;
cache[2] = Uint8List(1)..[0] = 2;

print(cache[0]); // null
print(cache[1]); // [1]
print(cache[2]); // [2]
```

Example with Weak Cache support:

```dart
/// Helper class to demonstrate LruWeakCache
class Key {
  const Key(this.key);
  final String key;
  @override
  String toString() => key;
}

void main() {
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
```
