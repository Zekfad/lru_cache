import 'dart:collection';

/// {@template lru_cache_entry_docs}
/// Entry for cache basted on least recently used strategy.
/// 
/// Instances of this class are intended to be stored in both linked list and
/// map.
/// 
/// This is developer class. You should use it only for custom LRU
/// implementations.
/// {@endtemplate}
base class LruCacheEntry<K, V> extends LinkedListEntry<LruCacheEntry<K, V>> {
  /// {@macro lru_cache_entry_docs}
  LruCacheEntry(this.key, this.value);

  /// Associated entry key.
  /// Used to remove entry from map without causing unnecessary iteration.
  final K key;
  /// Associated entry value.
  final V value;
}
