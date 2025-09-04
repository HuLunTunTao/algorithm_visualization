import 'dart:io';
import '../lib/struct/rb_tree.dart'; 

void main() {
  // 创建一个红黑树实例
  final rbt = MyRedBlackTree<int>();

  print('--- 开始插入节点 ---');
  // 插入一些字符串和整数值
  rbt.insert('banana', 10);
  rbt.insert('apple', 5);
  rbt.insert('cherry', 15);
  rbt.insert('date', 20);
  rbt.insert('fig', 25);
  rbt.insert('grape', 30);
  rbt.insert('elderberry', 18);
  rbt.insert('honeydew', 22);

  print('--- 插入完成，中序遍历打印红黑树 ---');
  // 使用 DFS 打印树，验证插入操作后的结构和颜色
  rbt.dfsPrint(rbt.root);

  print('\n--- 开始进行节点搜索 ---');
  // 测试搜索功能
  String searchName1 = 'apple';
  int? result1 = rbt.dfsFind(rbt.root, searchName1);
  if (result1 != -1) {
    print("找到了包含 '${searchName1}' 的节点，其值为: $result1");
  } else {
    print("未找到包含 '${searchName1}' 的节点。");
  }

  String searchName2 = 'grape';
  int? result2 = rbt.dfsFind(rbt.root, searchName2);
  if (result2 != -1) {
    print("找到了包含 '${searchName2}' 的节点，其值为: $result2");
  } else {
    print("未找到包含 '${searchName2}' 的节点。");
  }

  // 测试一个不存在的节点
  String searchName3 = 'watermelon';
  int? result3 = rbt.dfsFind(rbt.root, searchName3);
  if (result3 != -1) {
    print("找到了包含 '${searchName3}' 的节点，其值为: $result3");
  } else {
    print("未找到包含 '${searchName3}' 的节点。");
  }

  print('\n--- 测试完成 ---');
}