import 'dart:typed_data';

import '../lru.dart';


final class LruTypedDataCache<K, V extends TypedData> extends LruCache<K, V> {
  LruTypedDataCache({
    required int capacity,
    required this.byteCapacity,
  }) : super(capacity);

  /// Space in bytes available for all object.
  final int byteCapacity;

  /// Space in bytes used by all objects in cache.
  int get lengthInBytes => _lengthInBytes;
  int _lengthInBytes = 0;

  @override
  void touchListEntry(LruCacheEntry<K, V> entry) {
    super.touchListEntry(entry);

    while (_lengthInBytes > byteCapacity)
      evictListEntry(list.last);
  }

  @override
  LruCacheEntry<K, V>? evictListEntry(LruCacheEntry<K, V> entry) {
    final evicted = super.evictListEntry(entry);
    if (evicted != null)
      _lengthInBytes -= evicted.value.lengthInBytes;

    return evicted;
  }

  @override
  V? remove(Object? key) {
    final removed = super.remove(key);

    _lengthInBytes -= removed?.lengthInBytes ?? 0;

    return removed;
  }

  @override
  void operator []=(K key, V value) {
    final lengthInBytes = value.lengthInBytes;
    if (byteCapacity < lengthInBytes)
      return;

    _lengthInBytes += lengthInBytes;

    super[key] = value;
  }

  @override
  void clear() {
    _lengthInBytes = 0;

    super.clear();
  }
}
