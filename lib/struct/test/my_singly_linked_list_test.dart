import 'dart:math';

import '../my_singly_linked_list.dart';

void main(){
  print("测试插入");
  var random = Random();

  MySinglyLinkedList<int> list=MySinglyLinkedList<int>();
  for(int i=0;i<10;i++){
    list.insertHead(random.nextInt(100));
  }
  list.printAll();

  int numToInsert=random.nextInt(100);
  print("在头部插入数字$numToInsert");
  list.insertHead(numToInsert);
  list.printAll();

  numToInsert=random.nextInt(100);
  print("在尾部插入数字$numToInsert");
  list.insertTail(numToInsert);
  list.printAll();

  print("获得头");
  print(list.getHead());

  print("获得尾");
  print(list.getTail());
}