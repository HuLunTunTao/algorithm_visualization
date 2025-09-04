class MyDoublyLinkedList<T> {
  _Node<T>? _head;
  _Node<T>? _tail;
  int _length = 0;

  int get length => _length;

  bool isEmpty() {
    return _length == 0;
  }

  T? getTail() => _tail?.data;

  T? getHead() => _head?.data;

  void insertHead(T data) {
    final newNode = _Node(data);
    if (_head == null) {
      _head = newNode;
      _tail = newNode;
    } else {
      newNode.next = _head;
      _head!.previous = newNode;
      _head = newNode;
    }
    _length++;
  }

  void insertTail(T data) {
    final newNode = _Node(data);
    if (_tail == null) {
      _head = newNode;
      _tail = newNode;
    } else {
      newNode.previous = _tail;
      _tail!.next = newNode;
      _tail = newNode;
    }
    _length++;
  }

  void removeHead() {
    if (_head == null) return;
    if (_head == _tail) {
      _head = _tail = null;
    } else {
      _head = _head!.next;
      _head!.previous = null;
    }
    _length--;
  }

  void removeTail() {
    if (_tail == null) return;
    if (_head == _tail) {
      _head = _tail = null;
    } else {
      _tail = _tail!.previous;
      _tail!.next = null;
    }
    _length--;
  }

  void insertAt(int index, T data) {
    if (index < 0 || index > _length) return;
    if (index == 0) {
      insertHead(data);
      return;
    }
    if (index == _length) {
      insertTail(data);
      return;
    }

    final newNode = _Node(data);
    _Node<T>? current;
    
    // 选择从头还是从尾开始遍历，优化性能
    if (index <= _length ~/ 2) {
      current = _head;
      for (int i = 0; i < index; i++) {
        current = current!.next;
      }
    } else {
      current = _tail;
      for (int i = _length - 1; i > index; i--) {
        current = current!.previous;
      }
    }

    newNode.next = current;
    newNode.previous = current!.previous;
    current.previous!.next = newNode;
    current.previous = newNode;
    _length++;
  }

  void removeAt(int index) {
    if (index < 0 || index >= _length) return;
    if (index == 0) {
      removeHead();
      return;
    }
    if (index == _length - 1) {
      removeTail();
      return;
    }

    _Node<T>? current;
    
    // 选择从头还是从尾开始遍历，优化性能
    if (index <= _length ~/ 2) {
      current = _head;
      for (int i = 0; i < index; i++) {
        current = current!.next;
      }
    } else {
      current = _tail;
      for (int i = _length - 1; i > index; i--) {
        current = current!.previous;
      }
    }

    current!.previous!.next = current.next;
    current.next!.previous = current.previous;
    _length--;
  }

  T? getAt(int index) {
    if (index < 0 || index >= _length) return null;
    if (index == 0) return getHead();
    if (index == _length - 1) return getTail();

    _Node<T>? current;
    
    // 选择从头还是从尾开始遍历，优化性能
    if (index <= _length ~/ 2) {
      current = _head;
      for (int i = 0; i < index; i++) {
        current = current!.next;
      }
    } else {
      current = _tail;
      for (int i = _length - 1; i > index; i--) {
        current = current!.previous;
      }
    }

    return current?.data;
  }

  void clear() {
    _head = _tail = null;
    _length = 0;
  }

  @override
  String toString() {
    _Node<T>? node = _head;
    String toPrint = "< ";
    while (node != null) {
      toPrint += "${node.data} ";
      node = node.next;
    }
    toPrint += ">";
    return toPrint;
  }

  String toStringReverse() {
    _Node<T>? node = _tail;
    String toPrint = "< ";
    while (node != null) {
      toPrint += "${node.data} ";
      node = node.previous;
    }
    toPrint += ">";
    return toPrint;
  }

  void printAll() => print(toString());

  void printAllReverse() => print(toStringReverse());
}

class _Node<T> {
  _Node<T>? next;
  _Node<T>? previous;
  late T data;

  _Node(this.data);
}
