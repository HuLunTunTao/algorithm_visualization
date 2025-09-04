import 'dart:math';

import '../my_singly_linked_list.dart';

void main(){
  print("测试插入");
  var random = Random();
  final maxRandomInt=100;

  MySinglyLinkedList<int> list=MySinglyLinkedList<int>();
  for(int i=0;i<10;i++){
    list.insertHead(random.nextInt(maxRandomInt));
  }
  list.printAll();
  print("链表长度：${list.length}");

  int numToInsert=random.nextInt(maxRandomInt);
  print("在头部插入数字$numToInsert");
  list.insertHead(numToInsert);
  list.printAll();
  print("链表长度：${list.length}");

  numToInsert=random.nextInt(maxRandomInt);
  print("在尾部插入数字$numToInsert");
  list.insertTail(numToInsert);
  list.printAll();
  print("链表长度：${list.length}");

  print("获得头");
  print(list.getHead());

  print("获得尾");
  print(list.getTail());

  print("删去头两个");
  list.removeHead();
  list.printAll();
  list.removeHead();
  list.printAll();
  print("链表长度：${list.length}");

  print("删去尾两个");
  list.removeTail();
  list.printAll();
  list.removeTail();
  list.printAll();
  print("链表长度：${list.length}");

  print("全部清空");
  list.clear();
  list.printAll();
  print("链表长度：${list.length}");

  print("头部插入一个 从尾部删除一个");
  list.insertHead(random.nextInt(maxRandomInt));
  list.printAll();
  print("链表长度：${list.length}");
  list.removeTail();
  list.printAll();
  print("链表长度：${list.length}");

  print("尾部插入一个 从头部删除一个");
  list.insertTail(random.nextInt(maxRandomInt));
  list.printAll();
  print("链表长度：${list.length}");
  list.removeHead();
  list.printAll();
  print("链表长度：${list.length}");



}