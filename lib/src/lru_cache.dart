import 'dart:collection';

import 'package:meta/meta.dart';

import 'lru_cache_entry.dart';


/// Cache implementation based on least recently used eviction strategy.
///
/// {@template lru_cache_docs}
/// Elements are stored in a [Map] and expected to have a constant access time
/// or in worst-case linear access time for particularly bad [Object.hashCode]
/// implementation for stored elements.
/// 
/// Usage metadata is tracked via a [LinkedList].
/// 
/// Implements full [Map] interface with efficient [Map.length].
/// {@endtemplate}
/// 
/// Implementation details for subclasses:
/// 
/// Replacing already present key will trigger removal of element first and
/// adding new value afterwards.
/// 
/// Adding already present element with the same key will push them to
/// the beginning of linked list without removing them.
base class LruCache<K, V extends Object> with MapBase<K, V> {
  /// Create new LRU cache with maximum [capacity] of elements.
  ///
  /// {@macro lru_cache_docs}
  LruCache(this.capacity) : assert(capacity >= 0, 'Capacity must not be negative');

  /// Maximum count of elements this cache can hold at any given moment.
  final int capacity;

  /// Map used to speed up access to cache entries.
  @protected
  @visibleForTesting
  final cache = <K, LruCacheEntry<K, V>>{};

  /// Linked list used to keep track of access order of cache entries.
  @protected
  @visibleForTesting
  final list = LinkedList<LruCacheEntry<K, V>>();

  /// Unlinks [entry] form the [list] and re-links it the beginning.
  /// 
  /// If [entry] is the beginning of [list] this is no-op.
  /// 
  /// If [entry] is not present in the [list] it will be added to the beginning.
  /// 
  /// After [entry] relink if there are more entries than [capacity] old entries
  /// will be removed until there are no more than [capacity] entries.
  /// 
  /// It is assumed that [cache] already contains [entry].
  /// It is assumed that [entry] created only for this cache instance.
  /// 
  /// Subclasses MUST NOT pass unrelated entries, otherwise it will can break
  /// this data structure.
  @protected
  void touchListEntry(LruCacheEntry<K, V> entry) {
    if (entry == list.firstOrNull) {
      return;
    }
    if (entry.list != null) {
      entry.unlink();
    }
    list.addFirst(entry);
    if (list.length > capacity) {
      evictListEntry(list.last);
    }
  }

  /// Called upon cache overflow as a measure to shrink the cache.
  /// 
  /// Removes [entry] from linked [list] and [cache] map.
  @protected
  LruCacheEntry<K, V>? evictListEntry(LruCacheEntry<K, V> entry) =>
    cache.remove(entry.key)?..unlink();

  // MapBase required methods

  @override
  V? operator [](Object? key) {
    if (cache[key] case final entry?) {
      list.addFirst(entry..unlink());
      return entry.value;
    }
    return null;
  }

  @override
  void operator []=(K key, V value) {
    if (cache[key] case final entry?) {
      if (identical(entry.value, value)) {
        // replacing key with the same value, we only need to move
        // entry to the beginning of the list
        touchListEntry(entry);
        return;
      }
      // replacing key, we need first to remove existing entry from the list
      //
      // using remove instead of evictListEntry because semantically this method
      // is designed to be the same as
      //   cache.remove(key);
      //   cache[key] = value;
      // This helps to differentiate elements that became obsolete as part of
      // LRU strategy and elements that were replaced by user manually.
      final removed = remove(key);
      assert(null != removed, 'Remove did not return entry, but key is supposedly present');
      assert(identical(removed, entry.value), 'Removed unrelated entry');
    }
    final entry = cache[key] = LruCacheEntry(key, value);
    touchListEntry(entry);
  }

  @override
  V? remove(Object? key) => (cache.remove(key)?..unlink())?.value;

  @override
  void clear() {
    cache.clear();
    list.clear();
  }

  // MapBase performance overrides and fixes that ensures no LRU updates on
  // contains checks.

  @override
  bool containsKey(Object? key) => cache.containsKey(key);

  @override
  bool containsValue(Object? value) {
    for (final entry in cache.values) {
      if (entry.value == value) {
        return true;
      }
    }
    return false;
  }

  @override
  bool get isNotEmpty => cache.isNotEmpty;

  @override
  bool get isEmpty => cache.isEmpty;

  @override
  Iterable<K> get keys => cache.keys;

  @override
  Iterable<V> get values => cache.values.map((e) => e.value);
}
