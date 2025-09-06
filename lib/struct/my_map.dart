class MyMap<K, V> {
  late List<List<_MapEntry<K, V>>> _buckets;
  int _size = 0;
  static const int _initialCapacity = 16;
  static const double _loadFactor = 0.75;

  MyMap() {
    _buckets = List.generate(_initialCapacity, (index) => <_MapEntry<K, V>>[]);
  }

  MyMap.from(Map<K, V> other) {
    _buckets = List.generate(_initialCapacity, (index) => <_MapEntry<K, V>>[]);
    _size = 0;
    addAll(other);
  }

  MyMap.fromIterable(Iterable<K> iterable, {V Function(K)? value}) {
    _buckets = List.generate(_initialCapacity, (index) => <_MapEntry<K, V>>[]);
    _size = 0;
    for (K key in iterable) {
      if (value != null) {
        this[key] = value(key);
      }
    }
  }

  int get length => _size;

  bool get isEmpty => _size == 0;

  bool get isNotEmpty => _size > 0;

  int _hash(K key) {
    return key.hashCode.abs() % _buckets.length;
  }

  void _resize() {
    if (_size > _buckets.length * _loadFactor) {
      final oldBuckets = _buckets;
      _buckets = List.generate(_buckets.length * 2, (index) => <_MapEntry<K, V>>[]);
      final oldSize = _size;
      _size = 0;

      for (final bucket in oldBuckets) {
        for (final entry in bucket) {
          this[entry.key] = entry.value;
        }
      }
    }
  }

  V? operator [](K key) {
    final bucketIndex = _hash(key);
    final bucket = _buckets[bucketIndex];

    for (final entry in bucket) {
      if (entry.key == key) {
        return entry.value;
      }
    }
    return null;
  }

  void operator []=(K key, V value) {
    final bucketIndex = _hash(key);
    final bucket = _buckets[bucketIndex];

    // 查找是否已存在该键
    for (int i = 0; i < bucket.length; i++) {
      if (bucket[i].key == key) {
        bucket[i] = _MapEntry(key, value); // 更新值
        return;
      }
    }

    // 添加新键值对
    bucket.add(_MapEntry(key, value));
    _size++;
    _resize();
  }

  V? remove(K key) {
    final bucketIndex = _hash(key);
    final bucket = _buckets[bucketIndex];

    for (int i = 0; i < bucket.length; i++) {
      if (bucket[i].key == key) {
        final removedEntry = bucket.removeAt(i);
        _size--;
        return removedEntry.value;
      }
    }
    return null;
  }

  bool containsKey(K key) {
    final bucketIndex = _hash(key);
    final bucket = _buckets[bucketIndex];

    for (final entry in bucket) {
      if (entry.key == key) {
        return true;
      }
    }
    return false;
  }

  bool containsValue(V value) {
    for (final bucket in _buckets) {
      for (final entry in bucket) {
        if (entry.value == value) {
          return true;
        }
      }
    }
    return false;
  }

  List<K> get keys {
    final result = <K>[];
    for (final bucket in _buckets) {
      for (final entry in bucket) {
        result.add(entry.key);
      }
    }
    return result;
  }

  List<V> get values {
    final result = <V>[];
    for (final bucket in _buckets) {
      for (final entry in bucket) {
        result.add(entry.value);
      }
    }
    return result;
  }

  List<MapEntry<K, V>> get entries {
    final result = <MapEntry<K, V>>[];
    for (final bucket in _buckets) {
      for (final entry in bucket) {
        result.add(MapEntry(entry.key, entry.value));
      }
    }
    return result;
  }

  void addAll(Map<K, V> other) {
    other.forEach((key, value) {
      this[key] = value;
    });
  }

  void addEntries(Iterable<MapEntry<K, V>> newEntries) {
    for (final entry in newEntries) {
      this[entry.key] = entry.value;
    }
  }

  void removeWhere(bool Function(K key, V value) test) {
    final keysToRemove = <K>[];
    for (final bucket in _buckets) {
      for (final entry in bucket) {
        if (test(entry.key, entry.value)) {
          keysToRemove.add(entry.key);
        }
      }
    }
    for (final key in keysToRemove) {
      remove(key);
    }
  }

  void clear() {
    _buckets = List.generate(_initialCapacity, (index) => <_MapEntry<K, V>>[]);
    _size = 0;
  }

  void forEach(void Function(K key, V value) action) {
    for (final bucket in _buckets) {
      for (final entry in bucket) {
        action(entry.key, entry.value);
      }
    }
  }

  Map<RK, RV> map<RK, RV>(MapEntry<RK, RV> Function(K key, V value) transform) {
    final result = <RK, RV>{};
    for (final bucket in _buckets) {
      for (final entry in bucket) {
        final transformed = transform(entry.key, entry.value);
        result[transformed.key] = transformed.value;
      }
    }
    return result;
  }

  V putIfAbsent(K key, V Function() ifAbsent) {
    if (containsKey(key)) {
      return this[key]!;
    }
    final value = ifAbsent();
    this[key] = value;
    return value;
  }

  V? update(K key, V Function(V value) update, {V Function()? ifAbsent}) {
    if (containsKey(key)) {
      final currentValue = this[key]!;
      final newValue = update(currentValue);
      this[key] = newValue;
      return newValue;
    } else if (ifAbsent != null) {
      final newValue = ifAbsent();
      this[key] = newValue;
      return newValue;
    }
    return null;
  }

  void updateAll(V Function(K key, V value) update) {
    for (final bucket in _buckets) {
      for (int i = 0; i < bucket.length; i++) {
        final entry = bucket[i];
        final newValue = update(entry.key, entry.value);
        bucket[i] = _MapEntry(entry.key, newValue);
      }
    }
  }

  @override
  String toString() {
    if (isEmpty) return '{}';

    final buffer = StringBuffer('{');
    bool first = true;
    for (final bucket in _buckets) {
      for (final entry in bucket) {
        if (!first) buffer.write(', ');
        buffer.write('${entry.key}: ${entry.value}');
        first = false;
      }
    }
    buffer.write('}');
    return buffer.toString();
  }

  void printAll() => print(toString());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MyMap<K, V>) return false;
    if (length != other.length) return false;

    for (final key in keys) {
      if (!other.containsKey(key) || other[key] != this[key]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    int hash = 0;
    for (final bucket in _buckets) {
      for (final entry in bucket) {
        hash ^= entry.key.hashCode ^ entry.value.hashCode;
      }
    }
    return hash;
  }
}

// 内部使用的键值对类
class _MapEntry<K, V> {
  final K key;
  final V value;

  _MapEntry(this.key, this.value);
}
