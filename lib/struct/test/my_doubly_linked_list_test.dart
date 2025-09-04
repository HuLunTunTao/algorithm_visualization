import 'dart:math';

import '../my_doubly_linked_list.dart';

void main() {
  print("=== 双向链表测试开始 ===");
  var random = Random();
  final maxRandomInt = 100;

  MyDoublyLinkedList<int> list = MyDoublyLinkedList<int>();

  print("测试插入");
  for (int i = 0; i < 5; i++) {
    list.insertHead(random.nextInt(maxRandomInt));
  }
  list.printAll();
  print("链表长度：${list.length}");

  int numToInsert = random.nextInt(maxRandomInt);
  print("在头部插入数字$numToInsert");
  list.insertHead(numToInsert);
  list.printAll();
  print("链表长度：${list.length}");

  numToInsert = random.nextInt(maxRandomInt);
  print("在尾部插入数字$numToInsert");
  list.insertTail(numToInsert);
  list.printAll();
  print("链表长度：${list.length}");

  print("测试双向遍历");
  print("正向遍历：");
  list.printAll();
  print("反向遍历：");
  list.printAllReverse();

  print("获得头");
  print(list.getHead());

  print("获得尾");
  print(list.getTail());

  print("测试指定位置插入");
  numToInsert = random.nextInt(maxRandomInt);
  print("在位置2插入数字$numToInsert");
  list.insertAt(2, numToInsert);
  list.printAll();
  print("链表长度：${list.length}");

  print("测试指定位置获取");
  print("获取位置2的元素：${list.getAt(2)}");
  print("获取位置0的元素：${list.getAt(0)}");
  print("获取位置${list.length - 1}的元素：${list.getAt(list.length - 1)}");

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

  print("测试指定位置删除");
  if (list.length > 2) {
    print("删除位置1的元素");
    list.removeAt(1);
    list.printAll();
    print("链表长度：${list.length}");
  }

  print("全部清空");
  list.clear();
  list.printAll();
  print("链表长度：${list.length}");

  print("边界测试：头部插入一个 从尾部删除一个");
  list.insertHead(random.nextInt(maxRandomInt));
  list.printAll();
  print("链表长度：${list.length}");
  list.removeTail();
  list.printAll();
  print("链表长度：${list.length}");

  print("边界测试：尾部插入一个 从头部删除一个");
  list.insertTail(random.nextInt(maxRandomInt));
  list.printAll();
  print("链表长度：${list.length}");
  list.removeHead();
  list.printAll();
  print("链表长度：${list.length}");

  print("=== 双向链表测试结束 ===");
}