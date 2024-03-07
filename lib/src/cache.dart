import 'dart:collection';

import 'lru_cache.dart';


abstract base class Cache<K, V extends Object> with MapBase<K, V> implements Map<K, V> {
  factory Cache(int maxCapacity) => LruCache(maxCapacity);

  const Cache.internal(this.maxCapacity)
    : assert(maxCapacity > 0, 'Max capacity must be positive');

  final int maxCapacity;
}
