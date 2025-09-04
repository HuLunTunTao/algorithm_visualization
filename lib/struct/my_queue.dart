class MyQueue<T> {
  _Node<T>? _front;
  _Node<T>? _rear;
  int _length = 0;

  int get length => _length;

  bool isEmpty() {
    return _length == 0;
  }

  T? getFront() => _front?.data;

  T? getRear() => _rear?.data;

  void enqueue(T data) {
    final newNode = _Node(data);
    if (_rear == null) {
      _front = newNode;
      _rear = newNode;
    } else {
      _rear!.next = newNode;
      _rear = newNode;
    }
    _length++;
  }

  T? dequeue() {
    if (_front == null) return null;
    
    final data = _front!.data;
    _front = _front!.next;
    
    if (_front == null) {
      _rear = null;
    }
    
    _length--;
    return data;
  }

  T? peek() {
    return _front?.data;
  }

  void clear() {
    _front = _rear = null;
    _length = 0;
  }

  List<T> toList() {
    List<T> result = [];
    _Node<T>? current = _front;
    while (current != null) {
      result.add(current.data);
      current = current.next;
    }
    return result;
  }

  @override
  String toString() {
    _Node<T>? node = _front;
    String toPrint = "Front -> ";
    while (node != null) {
      toPrint += "${node.data}";
      node = node.next;
      if (node != null) toPrint += " -> ";
    }
    toPrint += " <- Rear";
    return toPrint;
  }

  void printAll() => print(toString());
}

class _Node<T> {
  _Node<T>? next;
  late T data;

  _Node(this.data);
}
