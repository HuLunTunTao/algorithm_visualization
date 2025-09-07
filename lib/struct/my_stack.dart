import 'my_singly_linked_list.dart';

class MyStack<T> {
  late MySinglyLinkedList<T> list;
  MyStack(){
    list=MySinglyLinkedList<T>();
  }
  
  void push(T data)=>list.insertTail(data);

  void pop()=>list.removeTail();

  T? top()=>list.getTail();

  int get length=>list.length;

  bool isEmpty()=>list.isEmpty();

  @override
  String toString() => list.toString();

}