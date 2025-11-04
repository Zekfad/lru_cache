/// @docImport 'lru_cache.dart';
library;

import 'dart:collection';


/// {@template lru_cache_entry_docs}
/// An entry for the cache based on the least recently used strategy.
///
/// Instances of this class are intended to be stored in both [LruCache.list]
/// and [LruCache.cache] map.
///
/// This class is intended to be used only by implementers of [LruCache].
///
/// This is a good place to store additional entry metadata such as hit count.
/// {@endtemplate}
base class LruCacheEntry<K, V> extends LinkedListEntry<LruCacheEntry<K, V>> {
  /// {@macro lru_cache_entry_docs}
  LruCacheEntry(this.key, this.value);

  /// Associated entry key.
  /// 
  /// It is used to remove entry from [LruCache.cache] map without causing
  /// unnecessary iteration.
  final K key;
  /// Associated entry value.
  final V value;
}
