class MySet<T> {
  late List<List<T>> _buckets;
  int _size = 0;
  static const int _initialCapacity = 16;
  static const double _loadFactor = 0.75;

  MySet() {
    _buckets = List.generate(_initialCapacity, (index) => <T>[]);
  }

  MySet.from(Iterable<T> elements) {
    _buckets = List.generate(_initialCapacity, (index) => <T>[]);
    _size = 0;
    addAll(elements);
  }

  int get length => _size;

  bool isEmpty() {
    return _size == 0;
  }

  bool isNotEmpty() {
    return _size > 0;
  }

  int _hash(T element) {
    return element.hashCode.abs() % _buckets.length;
  }

  void _resize() {
    if (_size > _buckets.length * _loadFactor) {
      final oldBuckets = _buckets;
      _buckets = List.generate(_buckets.length * 2, (index) => <T>[]);
      final oldSize = _size;
      _size = 0;

      for (final bucket in oldBuckets) {
        for (final element in bucket) {
          add(element);
        }
      }
    }
  }

  bool add(T element) {
    final bucketIndex = _hash(element);
    final bucket = _buckets[bucketIndex];

    if (!bucket.contains(element)) {
      bucket.add(element);
      _size++;
      _resize();
      return true;
    }
    return false;
  }

  void addAll(Iterable<T> elements) {
    for (final element in elements) {
      add(element);
    }
  }

  bool contains(T element) {
    final bucketIndex = _hash(element);
    return _buckets[bucketIndex].contains(element);
  }

  bool containsAll(Iterable<T> elements) {
    for (final element in elements) {
      if (!contains(element)) return false;
    }
    return true;
  }

  bool remove(T element) {
    final bucketIndex = _hash(element);
    final bucket = _buckets[bucketIndex];

    if (bucket.remove(element)) {
      _size--;
      return true;
    }
    return false;
  }

  void removeAll(Iterable<T> elements) {
    for (final element in elements) {
      remove(element);
    }
  }

  void clear() {
    _buckets = List.generate(_initialCapacity, (index) => <T>[]);
    _size = 0;
  }

  MySet<T> union(MySet<T> other) {
    final result = MySet<T>.from(toList());
    result.addAll(other.toList());
    return result;
  }

  MySet<T> intersection(MySet<T> other) {
    final result = MySet<T>();
    for (final element in toList()) {
      if (other.contains(element)) {
        result.add(element);
      }
    }
    return result;
  }

  MySet<T> difference(MySet<T> other) {
    final result = MySet<T>();
    for (final element in toList()) {
      if (!other.contains(element)) {
        result.add(element);
      }
    }
    return result;
  }

  List<T> toList() {
    final result = <T>[];
    for (final bucket in _buckets) {
      for (final element in bucket) {
        result.add(element);
      }
    }
    return result;
  }

  void forEach(void Function(T) action) {
    for (final bucket in _buckets) {
      for (final element in bucket) {
        action(element);
      }
    }
  }

  List<R> map<R>(R Function(T) transform) {
    final result = <R>[];
    for (final bucket in _buckets) {
      for (final element in bucket) {
        result.add(transform(element));
      }
    }
    return result;
  }

  List<T> where(bool Function(T) test) {
    final result = <T>[];
    for (final bucket in _buckets) {
      for (final element in bucket) {
        if (test(element)) {
          result.add(element);
        }
      }
    }
    return result;
  }

  bool any(bool Function(T) test) {
    for (final bucket in _buckets) {
      for (final element in bucket) {
        if (test(element)) return true;
      }
    }
    return false;
  }

  bool every(bool Function(T) test) {
    for (final bucket in _buckets) {
      for (final element in bucket) {
        if (!test(element)) return false;
      }
    }
    return true;
  }

  R fold<R>(R initialValue, R Function(R previous, T element) combine) {
    R result = initialValue;
    for (final bucket in _buckets) {
      for (final element in bucket) {
        result = combine(result, element);
      }
    }
    return result;
  }

  T? reduce(T Function(T value, T element) combine) {
    if (isEmpty()) return null;

    final list = toList();
    T result = list.first;
    for (int i = 1; i < list.length; i++) {
      result = combine(result, list[i]);
    }
    return result;
  }

  @override
  String toString() {
    final elements = toList();
    return '{${elements.join(', ')}}';
  }

  void printAll() => print(toString());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MySet<T>) return false;
    if (length != other.length) return false;
    return containsAll(other.toList());
  }

  @override
  int get hashCode {
    int hash = 0;
    for (final bucket in _buckets) {
      for (final element in bucket) {
        hash ^= element.hashCode;
      }
    }
    return hash;
  }
}
