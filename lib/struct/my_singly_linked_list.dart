class MySinglyLinkedList<T> {
  _Node<T>? _head;
  _Node<T>? _tail;
  int length=0;

  bool isEmpty(){
    return length==0;
  }

  T? getTail()=>_tail?.data;

  T? getHead()=>_head?.data;


  void insertHead(T data){
    final newNode=_Node(data);
    if(_head==null){
      _head=newNode;
      _tail=newNode;
    }else{
      newNode.next=_head;
      _head=newNode;
    }
    length++;
  }

  void insertTail(T data){
    final newNode=_Node(data);
    if(_tail==null){
      _head=newNode;
      _tail=newNode;
    }else{
      _tail!.next=newNode;
      _tail=newNode;
    }
    length++;
  }

  void removeHead(){
    if(_head==null) return;
    _head=_head?.next as _Node<T>?;
    length--;
  }

  void removeTail(){
    if(_head==null) return;
    if(_head==_tail){
      _head=_tail=null;
    }
    _Node<T>? newTail=_head;
    while(newTail?.next!=_tail){
      newTail=newTail?.next as _Node<T>?;
    }
    _tail=newTail;
  }

  void printAll(){
    _Node<T>? node=_head;
    String toPrint="";
    while(node!=null){
      toPrint+="${node.data} ";
      node=node.next as _Node<T>?;
    }
    print(toPrint);

  }
}

class _Node<T>{
  _Node? next;
  late T data;

  _Node(this.data);
}