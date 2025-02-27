import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'lru_cache.dart';
import 'lru_cache_entry.dart';


/// Least recently used cache for storing typed data elements.
/// 
/// {@macro lru_cache_docs}
/// 
/// {@template lru_typed_data_cache_docs}
/// Additionally this implementation ensures that total size of all stored typed
/// data elements ate not greater than provided [capacityInBytes].
/// {@endtemplate}
final class LruTypedDataCache<K, V extends TypedData> extends LruCache<K, V> {
  /// Create new typed data LRU cache with provided elements count [capacity]
  /// and [capacityInBytes].
  /// 
  /// {@macro lru_cache_docs}
  /// 
  /// {@macro lru_typed_data_cache_docs}
  LruTypedDataCache({
    required int capacity,
    required this.capacityInBytes,
  }) :
    assert(capacityInBytes >= 0, 'Capacity in bytes must not be negative'),
    super(capacity);

  /// Maximum possible total length in bytes for this cache.
  final int capacityInBytes;

  /// Total length in bytes of stored entries.
  int get lengthInBytes => _lengthInBytes;

  /// Total length in bytes of stored entries.
  int _lengthInBytes = 0;

  @override
  @protected
  void touchListEntry(LruCacheEntry<K, V> entry) {
    super.touchListEntry(entry);

    while (list.isNotEmpty && _lengthInBytes > capacityInBytes)
      evictListEntry(list.last);
  }

  @override
  @protected
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
      // because removing single entry requires to relink adjacent entries
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
