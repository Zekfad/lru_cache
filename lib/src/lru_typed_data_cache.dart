import 'dart:typed_data';

import 'lru_cache.dart';
import 'lru_cache_entry.dart';


final class LruTypedDataCache<K, V extends TypedData> extends LruCache<K, V> {
  LruTypedDataCache({
    required int capacity,
    required this.capacityInBytes,
  }) : super(capacity);

  /// Maximum possible total length in bytes for this cache.
  final int capacityInBytes;

  /// Total length in bytes of stored entries.
  int get lengthInBytes => _lengthInBytes;

  /// Total length in bytes of stored entries.
  int _lengthInBytes = 0;

  @override
  void touchListEntry(LruCacheEntry<K, V> entry) {
    super.touchListEntry(entry);

    while (_lengthInBytes > capacityInBytes)
      evictListEntry(list.last);
  }

  @override
  LruCacheEntry<K, V>? evictListEntry(LruCacheEntry<K, V> entry) {
    final evictedEntry = super.evictListEntry(entry);
    if (evictedEntry != null)
      _lengthInBytes -= evictedEntry.value.lengthInBytes;
    return evictedEntry;
  }

  @override
  V? remove(Object? key) {
    if (super.remove(key) case final value?) {
      _lengthInBytes -= value.lengthInBytes;
      return value;
    }
    return null;
  }

  @override
  void operator []=(K key, V value) {
    final len = value.lengthInBytes;
    if (len >= capacityInBytes) {
      if (len > capacityInBytes)
        return;
      // clear is faster than removing all linked list entries individually
      // because removing single entry you need to relink adjacent entries
      clear();
    }

    _lengthInBytes += len;
    super[key] = value;
  }

  @override
  void clear() {
    _lengthInBytes = 0;
    super.clear();
  }
}
