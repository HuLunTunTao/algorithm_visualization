
import 'dart:io';

import 'package:algorithm_visualization/struct/tree.dart';
import 'package:algorithm_visualization/model/KnowledgePoint.dart';
import 'package:algorithm_visualization/algo/guide_learningway.dart';
import 'package:algorithm_visualization/struct/my_queue.dart';

// 辅助函数：将学习路径队列转换为列表，方便验证
List<String> getPathAsList(MyQueue<Node<KnowledgePoint>>? pathQueue) {
  final pathList = <String>[];
  if (pathQueue == null) {
    return pathList;
  }
  while (!pathQueue.isEmpty()) {
    final node = pathQueue.dequeue();
    if (node != null) {
      pathList.add(node.value.name);
    }
  }
  return pathList;
}

// 辅助函数：将 KnowledgePoint 对象转换为 Knowledge 对象
KnowledgePoint transform(KnowledgePoint kp) {
  return KnowledgePoint(
    name: kp.name,
    prerequisites: kp.prerequisites,
    difficulty: kp.difficulty,
    studyTime: kp.studyTime,
  );
}

void main() {
  print("开始运行简单的学习路径规划测试...\n");

  // 1. 构建知识图
  // 按照只有一个根节点的实际情况构建图
  final rootKnowledge = transform(KnowledgePointRepository.getKnowledgePointByName('时间复杂度') as KnowledgePoint);
  final tree = MyTree<KnowledgePoint>(rootKnowledge);

  // 添加一系列知识点，模拟实际的依赖关系，所有节点都连接到唯一的根节点
  final spaceComplexity = transform(KnowledgePointRepository.getKnowledgePointByName('空间复杂度') as KnowledgePoint);
  final array = transform(KnowledgePointRepository.getKnowledgePointByName('数组') as KnowledgePoint);
  final linkedList = transform(KnowledgePointRepository.getKnowledgePointByName('链表') as KnowledgePoint);
  final stack = transform(KnowledgePointRepository.getKnowledgePointByName('栈') as KnowledgePoint);
  final recursion = transform(KnowledgePointRepository.getKnowledgePointByName('递归') as KnowledgePoint);
  final binaryTree = transform(KnowledgePointRepository.getKnowledgePointByName('二叉树') as KnowledgePoint);
  final binarySearchTree = transform(KnowledgePointRepository.getKnowledgePointByName('二叉搜索树') as KnowledgePoint);
  final dynamicProgramming = transform(KnowledgePointRepository.getKnowledgePointByName('动态规划') as KnowledgePoint);
  final graphRepresentation = transform(KnowledgePointRepository.getKnowledgePointByName('图的表示') as KnowledgePoint);
  final bfs = transform(KnowledgePointRepository.getKnowledgePointByName('BFS') as KnowledgePoint);
  final dfs = transform(KnowledgePointRepository.getKnowledgePointByName('DFS') as KnowledgePoint);
  final shortestPath = transform(KnowledgePointRepository.getKnowledgePointByName('最短路径') as KnowledgePoint);

  // 使用addNode方法手动连接它们，模拟一个连通图的结构
  final nodeSpaceComplexity = tree.addNode(spaceComplexity, [tree.root]);
  final nodeArray = tree.addNode(array, [nodeSpaceComplexity]);
  final nodeLinkedList = tree.addNode(linkedList, [nodeArray]);
  final nodeStack = tree.addNode(stack, [nodeLinkedList]);
  final nodeRecursion = tree.addNode(recursion, [nodeStack]);
  final nodeBinaryTree = tree.addNode(binaryTree, [nodeRecursion]);
  final nodeBinarySearchTree = tree.addNode(binarySearchTree, [nodeBinaryTree]);
  final nodeDynamicProgramming = tree.addNode(dynamicProgramming, [nodeBinarySearchTree]);

  // 将“图的表示”添加到主树上，使其成为一个子路径
  final nodeGraphRepresentation = tree.addNode(graphRepresentation, [nodeDynamicProgramming]); 
  final nodeBfs = tree.addNode(bfs, [nodeGraphRepresentation]);
  final nodeDfs = tree.addNode(dfs, [nodeGraphRepresentation]);
  final nodeShortestPath = tree.addNode(shortestPath, [nodeBfs, nodeDfs]);


  // 2. 运行并验证算法
  
  // 测试用例1：规划到“动态规划”的学习路径
  print("\n--- 测试用例1：规划到“动态规划”的学习路径 ---");
  final path1 = pathPlan(tree, '动态规划');
  final pathList1 = getPathAsList(path1);
  final expectedPath1 = [
    '时间复杂度',
    '空间复杂度',
    '数组',
    '链表',
    '栈',
    '递归',
    '二叉树',
    '二叉搜索树',
    '动态规划'
  ];
  print('预期路径：${expectedPath1.join(' -> ')}');
  print('实际路径：${pathList1.join(' -> ')}');
  print('结果是否正确: ${pathList1.join(' -> ') == expectedPath1.join(' -> ')}\n');

  // 测试用例2：规划到“最短路径”的学习路径（现在它已连接到主图）
  print("--- 测试用例2：规划到“最短路径”的学习路径 ---");
  final path2 = pathPlan(tree, '最短路径');
  final pathList2 = getPathAsList(path2);
  final isPath2Correct = pathList2.first == '时间复杂度' &&
      pathList2.last == '最短路径' &&
      pathList2.contains('图的表示') &&
      pathList2.contains('BFS') &&
      pathList2.contains('DFS');
  print('预期结果：路径以"时间复杂度"开始，以"最短路径"结束，并包含"图的表示"、"BFS"和"DFS"等');
  print('实际路径：${pathList2.join(' -> ')}');
  print('结果是否正确: $isPath2Correct\n');

  // 测试用例3：规划一个不存在的知识点
  print("--- 测试用例3：规划一个不存在的知识点 ---");
  final path3 = pathPlan(tree, '不存在的知识点');
  final pathList3 = getPathAsList(path3);
  print('预期结果：返回一个空队列');
  print('实际路径：${pathList3.isEmpty ? '空' : pathList3.join(' -> ')}');
  print('结果是否正确: ${pathList3.isEmpty}\n');
  
  // 测试用例4：规划根节点
  print("--- 测试用例4：规划根节点 ---");
  final path4 = pathPlan(tree, '时间复杂度');
  final pathList4 = getPathAsList(path4);
  final expectedPath4 = ['时间复杂度'];
  print('预期路径：${expectedPath4.join(' -> ')}');
  print('实际路径：${pathList4.join(' -> ')}');
  print('结果是否正确: ${pathList4.join(' -> ') == expectedPath4.join(' -> ')}\n');

  print("所有测试已完成。");
}