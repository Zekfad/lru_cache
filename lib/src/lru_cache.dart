import 'dart:collection';

import 'package:meta/meta.dart';

import 'cache.dart';
import 'lru_cache_entry.dart';


base class LruCache<K, V extends Object> extends Cache<K, V> {
  LruCache(super.maxCapacity) : super.internal();

  final cache = <K, (LruCacheEntry<K>, V)>{};
  final list = LinkedList<LruCacheEntry<K>>();

  @protected
  void touchListEntry(LruCacheEntry<K> entry) {
    if (entry == list.firstOrNull)
      return;
    if (entry.list != null)
      entry.unlink();
    list.addFirst(entry);
    if (list.length > maxCapacity)
      evictListEntry(list.last);
  }

  @protected
  (LruCacheEntry<K>, V)? evictListEntry(LruCacheEntry<K> entry) {
    final evictedEntry = cache.remove(entry.index);
    if (evictedEntry?.$1 case final entry?)
      entry.unlink();
    return evictedEntry;
  }

  @override
  V? operator [](Object? key) {
    if (cache[key] case (final entry, final value)?) {
      list.addFirst(entry..unlink());
      return value;
    }
  }

  @override
  void operator []=(K key, V value) {
    final entry = cache[key]?.$1 ?? LruCacheEntry(key);
    touchListEntry(entry);
    cache[key] = (entry, value);
  }

  @override
  V? remove(Object? key) {
    if (cache.remove(key) case (final entry, final value)?) {
      entry.unlink();
      return value;
    }
  }

  @override
  void clear() {
    cache.clear();
    list.clear();
  }

  @override
  bool containsKey(Object? key) => cache.containsKey(key);
  @override
  bool get isNotEmpty => cache.isNotEmpty;
  @override
  bool get isEmpty => cache.isEmpty;
  @override
  Iterable<K> get keys => cache.keys;
  @override
  Iterable<V> get values => cache.values.map((e) => e.$2);
}
