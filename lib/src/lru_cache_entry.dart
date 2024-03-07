import 'dart:collection';


base class LruCacheEntry<T> extends LinkedListEntry<LruCacheEntry<T>> {
  LruCacheEntry(this.index);

  final T index;
}
