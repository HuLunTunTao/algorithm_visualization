class MySinglyLinkedList<T> {
  _Node<T>? _head;
  _Node<T>? _tail;
  int length=0;

  bool isEmpty(){
    return length==0;
  }

  void insertHead(T data){
    final newNode=_Node(data);
    if(_head==null){
      _head=newNode;
      _tail=newNode;
    }else{
      _head?.prev=newNode;
      _head=newNode;
    }
    length++;
  }

  void insertTail(T data){
    final newNode=_Node(data);
    if(_head==null){
      _head=newNode;
      _tail=newNode;
    }else{
      newNode.prev=_tail;
      _tail=newNode;
    }
    length++;
  }

  void removeHead(){
    if(_head==null) return;
    _head=_head?.prev as _Node<T>?;
    length--;
  }

  void removeTail(){
    if(_head==null) return;
    _tail=_tail?.prev as _Node<T>?;
    length--;
  }
}

class _Node<T>{
  _Node? prev;
  late T data;

  _Node(this.data);
}