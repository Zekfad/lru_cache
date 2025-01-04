import 'dart:collection';

import 'package:meta/meta.dart';

import 'lru_cache_entry.dart';


/// Least recently used cache implementation.
/// Elements are stored in [Map] and expected to have a constant (worst-case
/// linear for bad [Object.hashCode]) access time.
/// Usage metadata are tracked via [LinkedList].
base class LruCache<K, V extends Object> with MapBase<K, V> {
  /// Create new LRU cache with [maxCapacity].
  LruCache(this.maxCapacity) : assert(maxCapacity > 0, 'Max capacity must be positive');

  /// Maximum capacity of this cache.
  final int maxCapacity;

  /// Map used for quick access to cache entries.
  @protected
  final cache = <K, LruCacheEntry<K, V>>{};

  /// Linked list used to keep track of access order of cache entries.
  @protected
  final list = LinkedList<LruCacheEntry<K, V>>();

  /// Moves entry to top of linked [list].
  /// If [entry] is already first one this is noop.
  /// If after [entry] movement there more entries than [maxCapacity]
  /// old entries are removed until there are less than [maxCapacity] entries.
  /// Its is assumed that [entry] is linked to this instance [list].
  /// Subclasses should not pass unrelated to [list] entries.
  @protected
  void touchListEntry(LruCacheEntry<K, V> entry) {
    if (entry == list.firstOrNull)
      return;
    if (entry.list != null)
      entry.unlink();
    list.addFirst(entry);
    if (list.length > maxCapacity)
      evictListEntry(list.last);
  }

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
  }

  @override
  void operator []=(K key, V value) {
    final entry = cache[key] = LruCacheEntry(key, value);
    touchListEntry(entry);
  }

  @override
  V? remove(Object? key) =>
    (cache.remove(key)?..unlink())?.value;

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
    for (final entry in cache.values)
      if (entry.value == value)
        return true;
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
