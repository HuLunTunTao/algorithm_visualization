// test_tree.dart

import 'dart:io';
import '../lib/algo/tree_kmp.dart';
import '../lib/struct/tree.dart';

void main() {
  print('--- 开始测试 ---');

  // 1. 测试创建树和添加节点
  print('\n## 1. 测试创建树和添加节点');
  final rootKnowledge = Knowledge('root_topic', 0, 0.0);
  final tree = MyTree<Knowledge>(rootKnowledge);
  final rootNode = tree.root;

  final nodeA = tree.addNode(Knowledge('Math_Fundamentals', 10, 0.6), rootNode);
  final nodeB = tree.addNode(Knowledge('Physics_Basics', 15, 0.7), rootNode);
  final nodeA1 = tree.addNode(Knowledge('Calculus_I', 20, 0.8), nodeA);
  final nodeA2 = tree.addNode(Knowledge('Linear_Algebra', 25, 0.9), nodeA);
  final nodeB1 = tree.addNode(Knowledge('Quantum_Mechanics', 30, 0.95), nodeB);
  final nodeB2 = tree.addNode(Knowledge('Thermodynamics', 28, 0.8), nodeB);

  // 2. 测试 DFS 打印树结构
  print('\n## 2. 测试 DFS 打印树结构');
  tree.dfsPrint(rootNode);

  // 3. 测试获取节点层级
  print('\n## 3. 测试获取节点层级');
  print('根节点 "${rootNode.value.name}" 的层级是: ${tree.getNodeLevel(rootNode)}');
  print('节点 "${nodeA.value.name}" 的层级是: ${tree.getNodeLevel(nodeA)}');
  print('节点 "${nodeA1.value.name}" 的层级是: ${tree.getNodeLevel(nodeA1)}');
  print('节点 "${nodeB2.value.name}" 的层级是: ${tree.getNodeLevel(nodeB2)}');

  // 4. 测试 DFS 搜索 (使用 kmp 模糊匹配)
  print('\n## 4. 测试 DFS 搜索');
  final foundNode = tree.dfsFind(rootNode, 'Calculus');
  if (foundNode != null) {
    print('通过模糊搜索 "Calculus" 找到节点: "${foundNode.value.name}"');
  } else {
    print('未找到包含 "Calculus" 的节点。');
  }

  final notFoundNode = tree.dfsFind(rootNode, 'Chemistry');
  if (notFoundNode != null) {
    print('找到节点: ${notFoundNode.value.name}');
  } else {
    print('未找到包含 "Chemistry" 的节点。');
  }

  // 5. 测试修改节点名称和学习时间
  print('\n## 5. 测试修改节点名称和学习时间');
  tree.updateName(nodeA2, 'Discrete_Mathematics', 123);
  print('修改后，再次打印树结构：');
  tree.dfsPrint(rootNode);

  // 6. 测试删除节点 (保留子节点)
  print('\n## 6. 测试删除节点 (保留子节点)');
  print('删除前，树结构为:');
  tree.dfsPrint(rootNode);
  
  tree.deleteNode_withson(nodeB);
  print('删除 "Physics_Basics" 后，树结构为:');
  tree.dfsPrint(rootNode);

  // 7. 测试删除节点 (不保留子节点)
  print('\n## 7. 测试删除节点 (不保留子节点)');
  final nodeA1_child = tree.addNode(Knowledge('Calculus_II', 20, 0.8), nodeA1);
  print('删除前，树结构为:');
  tree.dfsPrint(rootNode);

  tree.deleteNode_withoutson(nodeA1);
  print('删除 "Calculus_I" 后，树结构为:');
  tree.dfsPrint(rootNode);
  
  print('\n--- 测试结束 ---');
}