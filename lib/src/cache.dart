import 'lru_cache.dart';


/// Common interface for cache with capacity.
abstract interface class Cache<K, V extends Object> implements Map<K, V> {
  /// Default LRU cache implementation.
  factory Cache(int maxCapacity) = LruCache;

  /// Maximum capacity of this cache.
  int get maxCapacity;
}
