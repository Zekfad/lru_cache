# LRU Cache

[![pub package](https://img.shields.io/pub/v/lru.svg)](https://pub.dev/packages/lru)
[![package publisher](https://img.shields.io/pub/publisher/lru.svg)](https://pub.dev/packages/lru/publisher)

Cache based on Least Recently Used eviction strategy.

Optionally supports caching above normal capacity via Week references
(such values are cached until they are garbage collected normally).

Addition implementation for `TypedData` with capacity in bytes.
That can be used for caching buffers such as raw images.

## Features

* Supports full `Map` interface.
* Store `TypedData` and evict entries on bytes capacity overflow via
  `LruTypedDataCache`.
* Expando compatible objects can be optionally cached via `LruWeakCache`.

## Usage

Create cache, add values, when capacity is reached old elements will be removed;

```dart
// Cannot use weak cache, because String is not supported by Expando
final cache = LruCache<int, String>(2);

cache[0] = '0';
cache[1] = '1';

cache[0]; // try to touch

cache[2] = '2'; // key 1 is evicted here


print(cache[0]); // 0
print(cache[1]); // null
print(cache[2]); // 2
```

Example with bytes capacity for `TypedData`.

```dart
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
```

Weak cache is a bit more complicated, because it's behavior is depended on Dart
garbage collection. Elements that are normally would be removed from LRU cache
are temporarily stored in weak cache that doesn't create strong references to
stored objects.

Following is example of Weak Cache support:

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
  cache[2] = Key('2'); // key 0 is evicted from main LRU and moved to weak cache

  // if key 0 is not garbage collected yet
  // key 1 is moved to weak cache, and key 0 is restored
  cache[0];

  print(cache[0]); // 0 if key 0 wasn't garbage collected
  print(cache[1]); // 1 if key 0 was garbage collected or if key 1 wasn't GC'd
  print(cache[2]); // 2
}
```
