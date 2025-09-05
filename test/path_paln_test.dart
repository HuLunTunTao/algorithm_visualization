// test_path_plan.dart

import 'dart:io';
import '../lib/struct/tree.dart';
import '../lib/struct/my_stack.dart';
import '../lib/algo/guide_learningway.dart';

void main() {
  print('--- 开始测试路径规划功能 ---');

  // 1. 创建一棵树作为测试数据
  print('\n## 1. 建立测试树结构');
  final rootKnowledge = Knowledge('学习根目录', 0, 0.0);
  final tree = MyTree<Knowledge>(rootKnowledge);
  final rootNode = tree.root;

  // 添加一些节点来模拟学习路径
  final nodeA = tree.addNode(Knowledge('数学基础', 10, 0.6), rootNode);
  final nodeB = tree.addNode(Knowledge('物理基础', 15, 0.7), rootNode);
  final nodeA1 = tree.addNode(Knowledge('微积分I', 20, 0.8), nodeA);
  final nodeA2 = tree.addNode(Knowledge('线性代数', 25, 0.9), nodeA);
  final nodeA1_1 = tree.addNode(Knowledge('微积分II', 30, 0.85), nodeA1);

  tree.dfsPrint(rootNode);

  // 2. 测试：找到一个学习路径
  print('\n## 2. 测试找到一个学习路径');
  final foundPath = pathPlan(tree, '微积分II');

  if (foundPath != null) {
    print('找到的学习路径（从目标节点到根节点）：');
    while (!foundPath.isEmpty()) {
      final item = foundPath.top();
      if (item != null) {
        print('  - 名称: ${item.value.name}, 学习时间: ${item.value.time}');
        foundPath.pop();
      }
    }
  } else {
    print('未找到学习路径。');
  }

  // 3. 测试：未找到学习路径
  print('\n## 3. 测试未找到学习路径');
  final notFoundPath = pathPlan(tree, '化学基础');
  if (notFoundPath == null) {
    print('未找到该学习目标，符合预期。');
  }

  print('\n--- 测试结束 ---');
}