import 'package:weak_cache/expando_compatible.dart';
import 'package:weak_cache/weak_cache.dart';

import 'lru_cache.dart';
import 'lru_cache_entry.dart';


base class LruWeakCache<K, V extends Object> extends LruCache<K, V> {
  LruWeakCache(super.maxCapacity) : assert(
    expandoCompatible<V>(),
    'Weak cache cannot hold a string, number, boolean, record, null, Pointer, '
    'Struct or Union'
  );

  final weakCache = WeakCache<K, V>();

  @override
  (LruCacheEntry<K>, V)? evictListEntry(LruCacheEntry<K> entry) {
    final evictedEntry = super.evictListEntry(entry);
    if (evictedEntry case (LruCacheEntry(:final index), final value))
      weakCache[index] = value;
    return evictedEntry;
  }

  @override
  V? operator [](Object? key) {
    if (cache[key] case (final entry, final value)?) {
      list.addFirst(entry..unlink());
      return value;
    }
    if (weakCache[key] case final value?)
      return this[key! as K] = value;
  }

  /// Usage of [containsKey] is __discouraged__.
  /// 
  /// You should use `operator[]` and store value, then check it for `null`.
  /// Otherwise it's possible that object would be garbage collected between
  /// call for [containsKey] and actual usage.
  /// 
  /// `true` value returned from this function _only_ guarantees that value
  /// _was_ in cache at exact moment of check, but it could be gone right after
  /// that.
  @override
  bool containsKey(Object? key) =>
    super.containsKey(key) || weakCache.containsKey(key);

  @override
  bool containsValue(Object? value) =>
    super.containsValue(value) || weakCache.containsValue(value);

  @override
  V? remove(Object? key) {
    if (super.remove(key) case final value?)
      return value;
    return weakCache.remove(key);
  }
}
