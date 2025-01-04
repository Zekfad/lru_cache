import 'dart:collection';


/// Cache entry for LRU.
/// Instances of this class is stored in both linked list and map.
base class LruCacheEntry<K, V> extends LinkedListEntry<LruCacheEntry<K, V>> {
  /// Cache entry constructor.
  /// This is internal class and you should use it only for custom LRU
  /// implementation.
  LruCacheEntry(this.key, this.value);

  /// Associated entry key.
  /// Used to remove entry from map without unnecessary iteration.
  final K key;
  /// Associated entry value.
  final V value;
}
