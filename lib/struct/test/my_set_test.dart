import 'dart:math';
import '../my_set.dart';

void main() {
  print("=== MySet测试开始 ===\n");
  var random = Random();
  final maxRandomInt = 100;

  print("测试基本添加操作");
  MySet<int> set = MySet<int>();
  for (int i = 0; i < 10; i++) {
    int numToAdd = random.nextInt(maxRandomInt);
    print("添加数字: $numToAdd");
    bool added = set.add(numToAdd);
    print("添加${added ? '成功' : '失败（已存在）'}");
  }
  set.printAll();
  print("集合长度：${set.length}");
  print("集合是否为空：${set.isEmpty()}");

  print("测试重复添加");
  int duplicateNum = 50;
  print("尝试添加数字: $duplicateNum");
  bool result1 = set.add(duplicateNum);
  print("第一次添加结果: $result1");
  bool result2 = set.add(duplicateNum);
  print("第二次添加结果: $result2");
  set.printAll();
  print("集合长度：${set.length}");

  print("测试contains操作");
  for (int i = 0; i < 5; i++) {
    int numToCheck = random.nextInt(maxRandomInt);
    bool contains = set.contains(numToCheck);
    print("数字 $numToCheck ${contains ? '存在' : '不存在'} 于集合中");
  }

  print("测试from构造函数");
  List<int> testList = [1, 2, 3, 2, 4, 1, 5];
  print("从列表创建集合: $testList");
  MySet<int> setFromList = MySet<int>.from(testList);
  setFromList.printAll();
  print("集合长度：${setFromList.length}");

  print("测试删除操作");
  List<int> elements = set.toList();
  if (elements.isNotEmpty) {
    int numToRemove = elements[0];
    print("删除数字: $numToRemove");
    bool removed = set.remove(numToRemove);
    print("删除${removed ? '成功' : '失败'}");
    set.printAll();
    print("集合长度：${set.length}");

    print("再次尝试删除相同数字: $numToRemove");
    bool removedAgain = set.remove(numToRemove);
    print("删除${removedAgain ? '成功' : '失败'}");
  }

  print("测试集合运算");
  MySet<int> set1 = MySet<int>.from([1, 2, 3, 4, 5]);
  MySet<int> set2 = MySet<int>.from([4, 5, 6, 7, 8]);
  print("集合1:");
  set1.printAll();
  print("集合2:");
  set2.printAll();

  print("并集(union):");
  MySet<int> unionSet = set1.union(set2);
  unionSet.printAll();

  print("交集(intersection):");
  MySet<int> intersectionSet = set1.intersection(set2);
  intersectionSet.printAll();

  print("差集(difference):");
  MySet<int> differenceSet = set1.difference(set2);
  differenceSet.printAll();

  print("测试迭代操作");
  print("使用forEach遍历集合1:");
  set1.forEach((element) => print("元素: $element"));

  print("使用map操作（每个元素乘以2）:");
  List<int> doubled = set1.map((e) => e * 2);
  print("结果: $doubled");

  print("使用where过滤（偶数）:");
  List<int> evenNumbers = set1.where((e) => e % 2 == 0);
  print("偶数: $evenNumbers");

  print("使用any检查（是否有大于3的数）:");
  bool hasGreaterThan3 = set1.any((e) => e > 3);
  print("结果: $hasGreaterThan3");

  print("使用every检查（是否都大于0）:");
  bool allGreaterThan0 = set1.every((e) => e > 0);
  print("结果: $allGreaterThan0");

  print("测试fold和reduce");
  int sum = set1.fold(0, (prev, element) => prev + element);
  print("使用fold计算和: $sum");

  int? product = set1.reduce((value, element) => value * element);
  print("使用reduce计算积: $product");

  print("测试addAll和removeAll");
  MySet<int> testSet = MySet<int>.from([1, 2, 3]);
  print("初始集合:");
  testSet.printAll();

  print("addAll添加 [4, 5, 6]:");
  testSet.addAll([4, 5, 6]);
  testSet.printAll();

  print("removeAll删除 [2, 4, 6]:");
  testSet.removeAll([2, 4, 6]);
  testSet.printAll();

  print("测试字符串集合");
  MySet<String> stringSet = MySet<String>();
  List<String> fruits = ['apple', 'banana', 'cherry', 'apple', 'date'];
  print("添加水果: $fruits");
  stringSet.addAll(fruits);
  stringSet.printAll();
  print("字符串集合长度: ${stringSet.length}");

  print("检查是否包含 'apple': ${stringSet.contains('apple')}");
  print("检查是否包含 'grape': ${stringSet.contains('grape')}");

  print("测试大容量（扩容测试）");
  MySet<int> largeSet = MySet<int>();
  print("添加1000个随机数...");
  for (int i = 0; i < 1000; i++) {
    largeSet.add(random.nextInt(500)); // 使用较小范围确保有重复
  }
  print("大集合长度: ${largeSet.length}");
  print("包含100: ${largeSet.contains(100)}");
  print("包含999: ${largeSet.contains(999)}");

  print("测试清空操作");
  testSet.clear();
  print("清空后集合:");
  testSet.printAll();
  print("集合长度：${testSet.length}");
  print("集合是否为空：${testSet.isEmpty()}");

  print("测试边界情况");
  MySet<int> emptySet = MySet<int>();
  print("空集合reduce结果: ${emptySet.reduce((a, b) => a + b)}");

  MySet<int> singleSet = MySet<int>.from([42]);
  print("单元素集合:");
  singleSet.printAll();
  print("单元素集合reduce结果: ${singleSet.reduce((a, b) => a + b)}");

  print("=== MySet测试完成 ===");
}
