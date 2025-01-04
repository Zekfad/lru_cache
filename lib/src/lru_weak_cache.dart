import 'package:weak_cache/expando_compatible.dart';
import 'package:weak_cache/weak_cache.dart';

import 'lru_cache.dart';
import 'lru_cache_entry.dart';


/// [LruCache] with additional [WeakCache] that holds recently removed entries
/// until they garbage collected. If such entry is accessed it is returned to
/// main cache.
/// Does not work on numbers, strings, booleans, records, `null`, `dart:ffi`
/// pointers, `dart:ffi` structs, or `dart:ffi` unions.
/// 
/// Note: [remove] method may return value from [WeakCache] that is no longer in
/// LRU, this allows you to peek to removed value before it's garbage collected
/// but you cannot distinguish wether element was in LRU or in [WeakCache].
/// This detail makes it unsuitable for further extension, hence class is final.
final class LruWeakCache<K, V extends Object> extends LruCache<K, V> {
  /// Create new LRU cache with [capacity] that have additional
  /// [WeakCache] layer.
  /// Does not work on numbers, strings, booleans, records, `null`, `dart:ffi`
  /// pointers, `dart:ffi` structs, or `dart:ffi` unions.
  LruWeakCache(super.capacity) : assert(
    expandoCompatible<V>(),
    'Weak cache cannot hold a string, number, boolean, record, null, Pointer, '
    'Struct or Union'
  );

  /// Internal weak cache that holds recently removed entries.
  final _weakCache = WeakCache<K, V>();

  @override
  LruCacheEntry<K, V>? evictListEntry(LruCacheEntry<K, V> entry) {
    final evictedEntry = super.evictListEntry(entry);
    if (evictedEntry != null)
      _weakCache[evictedEntry.key] = evictedEntry.value;
    return evictedEntry;
  }

  @override
  V? operator [](Object? key) {
    if (super[key] case final value?)
      return value;
    if (_weakCache[key] case final value?) {
      assert(
        key != null && key is K,
        'Impossible state: weak Cache contains key '
        'that is null or not subtype of K',
      );
      return this[key! as K] = value;
    }
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
    super.containsKey(key) || _weakCache.containsKey(key);

  @override
  bool containsValue(Object? value) =>
    super.containsValue(value) || _weakCache.containsValue(value);

  @override
  V? remove(Object? key) {
    if (super.remove(key) case final value?)
      return value;
    return _weakCache.remove(key);
  }
}
