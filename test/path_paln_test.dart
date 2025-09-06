// main.dart
import 'dart:io';

import 'package:algorithm_visualization/struct/tree.dart';
import 'package:algorithm_visualization/model/KnowledgePoint.dart';
import 'package:algorithm_visualization/algo/guide_learningway.dart';
import 'package:algorithm_visualization/struct/my_queue.dart';

// 这是一个简单的辅助函数，用于将学习路径队列打印出来
void printLearningPath(String targetName, MyQueue<Node<Knowledge>>? pathQueue) {
  print('---');
  if (pathQueue == null) {
    print('无法找到目标知识点：“$targetName”的学习路径。');
    return;
  }

  print('为知识点 “$targetName” 规划的学习路径如下：');
  final pathList = [];
  while (!pathQueue.isEmpty()) {
    final node = pathQueue.dequeue();
    if (node != null) {
      pathList.add(node.value.name);
    }
  }
  print(pathList.join(' -> '));
  print('---');
}

void main() {
  print("开始运行简单的学习路径规划测试...\n");

  // 1. 构建知识图
  // 我们手动构建一个简单的依赖链来测试，以确保可控性

  // 将 KnowledgePoint 对象转换为 Knowledge 对象
  Knowledge transform(KnowledgePoint kp) {
    return Knowledge(
      name: kp.name,
      prerequisites: kp.prerequisites,
      difficulty: kp.difficulty,
      studyTime: kp.studyTime,
    );
  }

  final rootKnowledge = transform(KnowledgePointRepository.getKnowledgePointByName('时间复杂度') as KnowledgePoint);
  final tree = MyTree<Knowledge>(rootKnowledge);

  // 添加一些关键知识点来构建图，模拟实际的依赖关系
  final spaceComplexity = transform(KnowledgePointRepository.getKnowledgePointByName('空间复杂度') as KnowledgePoint);
  final array = transform(KnowledgePointRepository.getKnowledgePointByName('数组') as KnowledgePoint);
  final linkedList = transform(KnowledgePointRepository.getKnowledgePointByName('链表') as KnowledgePoint);
  final stack = transform(KnowledgePointRepository.getKnowledgePointByName('栈') as KnowledgePoint);
  final recursion = transform(KnowledgePointRepository.getKnowledgePointByName('递归') as KnowledgePoint);
  final binaryTree = transform(KnowledgePointRepository.getKnowledgePointByName('二叉树') as KnowledgePoint);
  final binarySearchTree = transform(KnowledgePointRepository.getKnowledgePointByName('二叉搜索树') as KnowledgePoint);
  final dynamicProgramming = transform(KnowledgePointRepository.getKnowledgePointByName('动态规划') as KnowledgePoint);
  final bfs = transform(KnowledgePointRepository.getKnowledgePointByName('BFS') as KnowledgePoint);
  final dfs = transform(KnowledgePointRepository.getKnowledgePointByName('DFS') as KnowledgePoint);
  final shortestPath = transform(KnowledgePointRepository.getKnowledgePointByName('最短路径') as KnowledgePoint);
  final graphRepresentation = transform(KnowledgePointRepository.getKnowledgePointByName('图的表示') as KnowledgePoint);

  // 使用addNode方法手动连接它们，模拟图的结构
  final nodeSpaceComplexity = tree.addNode(spaceComplexity, [tree.root]);
  final nodeArray = tree.addNode(array, [nodeSpaceComplexity]);
  final nodeLinkedList = tree.addNode(linkedList, [nodeArray]);
  final nodeStack = tree.addNode(stack, [nodeLinkedList]);
  final nodeRecursion = tree.addNode(recursion, [nodeStack]);
  final nodeBinaryTree = tree.addNode(binaryTree, [nodeRecursion]);
  final nodeBinarySearchTree = tree.addNode(binarySearchTree, [nodeBinaryTree]);
  final nodeDynamicProgramming = tree.addNode(dynamicProgramming, [nodeBinarySearchTree]);

  // 构建图的路径
  final nodeGraphRepresentation = tree.addNode(graphRepresentation, []); // 假设这是一个独立入口
  final nodeBfs = tree.addNode(bfs, [nodeGraphRepresentation]);
  final nodeDfs = tree.addNode(dfs, [nodeGraphRepresentation]);
  final nodeShortestPath = tree.addNode(shortestPath, [nodeBfs, nodeDfs]);

  // 2. 运行并验证算法

  // 测试用例1：规划到“动态规划”的学习路径
  print("\n--- 测试用例1：规划到“动态规划”的学习路径 ---");
  final path1 = pathPlan(tree, '动态规划');
  printLearningPath('动态规划', path1);

  // 测试用例2：规划到“最短路径”的学习路径
  print("\n--- 测试用例2：规划到“最短路径”的学习路径 ---");
  final path2 = pathPlan(tree, '最短路径');
  printLearningPath('最短路径', path2);

  // 测试用例3：规划一个不存在的知识点
  print("\n--- 测试用例3：规划一个不存在的知识点 ---");
  final path3 = pathPlan(tree, '不存在的知识点');
  printLearningPath('不存在的知识点', path3);

  print("\n所有测试已完成。");
}