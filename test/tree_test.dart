// tree_test.dart

import 'dart:io';
import '../lib/struct/tree.dart';
import '../lib/model/KnowledgePoint.dart';

void main() {
  // 验证依赖关系
  if (!KnowledgePointRepository.validateDependencies()) {
    print('知识点依赖关系验证失败。');
    return;
  }

  // 获取入门级知识点作为树根
  final entryKnowledge = KnowledgePointRepository.getEntryLevelKnowledgePoints();
  if (entryKnowledge.isEmpty) {
    print('未找到入门级知识点，无法创建树。');
    return;
  }
  // 选择第一个入门级知识点作为树的根
  // 注意：这里我们创建一个新的 Knowledge 实例来作为树根
  final rootKnowledge = Knowledge(
    name: entryKnowledge.first.name,
    prerequisites: entryKnowledge.first.prerequisites,
    difficulty: entryKnowledge.first.difficulty,
    studyTime: entryKnowledge.first.studyTime,
  );

  // 创建一个MyTree实例，使用 Knowledge 作为泛型参数
  final myTree = MyTree<Knowledge>(rootKnowledge);
  final rootNode = myTree.root;

  print('--- 树创建成功 ---');
  print('根节点: ${rootNode.value.name}');

  // 获取与根节点直接相关的知识点
  final dependentKnowledge = KnowledgePointRepository.getDependentKnowledgePoints(rootNode.value.name);

  // 向树中添加子节点
  // 使用 Knowledge 作为泛型参数
  Node<Knowledge>? childNode;
  if (dependentKnowledge.isNotEmpty) {
    // 创建一个新的 Knowledge 实例
    final childKnowledge = Knowledge(
      name: dependentKnowledge.first.name,
      prerequisites: dependentKnowledge.first.prerequisites,
      difficulty: dependentKnowledge.first.difficulty,
      studyTime: dependentKnowledge.first.studyTime,
    );
    childNode = myTree.addNode(childKnowledge, rootNode);
    print('已添加子节点: ${childNode.value.name}');
  }

  // 再次添加一个子节点
  final arrayKnowledge = KnowledgePointRepository.getKnowledgePointByName('数组');
  if (arrayKnowledge != null) {
    // 创建一个新的 Knowledge 实例
    final newArrayKnowledge = Knowledge(
      name: arrayKnowledge.name,
      prerequisites: arrayKnowledge.prerequisites,
      difficulty: arrayKnowledge.difficulty,
      studyTime: arrayKnowledge.studyTime,
    );
    myTree.addNode(newArrayKnowledge, childNode!);
    print('已添加子节点: ${newArrayKnowledge.name}');
  }

  print('\n--- DFS打印所有节点 ---');
  myTree.dfsPrint(myTree.root);

  print('\n--- 测试搜索功能 ---');
  final searchResult = myTree.dfsFind(myTree.root, '数组');
  if (searchResult != null) {
    print('找到节点: ${searchResult.value.name}，位于第 ${myTree.getNodeLevel(searchResult)} 层');
  } else {
    print('未找到指定节点');
  }

  print('\n--- 测试删除功能（保留子节点） ---');
  myTree.deleteNode_withson(childNode!);
  print('\n--- 删除后再次DFS打印 ---');
  myTree.dfsPrint(myTree.root);
}