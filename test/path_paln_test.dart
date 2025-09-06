// main.dart
import 'dart:io';
import '../lib/model/KnowledgePoint.dart';
import '../lib/struct/tree.dart';
import '../lib/algo/guide_learningway.dart'; // 引入你的路径规划文件

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

  // 手动创建 Knowledge 实例作为树根
  final rootKnowledge = Knowledge(
    name: entryKnowledge.first.name,
    prerequisites: entryKnowledge.first.prerequisites,
    difficulty: entryKnowledge.first.difficulty,
    studyTime: entryKnowledge.first.studyTime,
  );

  // 创建一个 MyTree 实例
  final myTree = MyTree<Knowledge>(rootKnowledge);
  final rootNode = myTree.root;

  // 向树中添加子节点（这里添加一个假设的“数组”节点）
  final arrayKnowledge = KnowledgePointRepository.getKnowledgePointByName('数组');
  if (arrayKnowledge != null) {
    // 手动创建 Knowledge 实例
    final newArrayKnowledge = Knowledge(
      name: arrayKnowledge.name,
      prerequisites: arrayKnowledge.prerequisites,
      difficulty: arrayKnowledge.difficulty,
      studyTime: arrayKnowledge.studyTime,
    );
    myTree.addNode(newArrayKnowledge, rootNode);
  }

  print('\n--- 树创建完成 ---');
  myTree.dfsPrint(myTree.root);

  // 调用 pathPlan 函数来规划学习路径
  final targetName = '数组';
  final pathStack = pathPlan(myTree, targetName);

  if (pathStack != null) {
    print('\n--- 找到学习路径 ---');
    while (!pathStack.isEmpty()) {
      final node = pathStack.top(); // 先获取栈顶元素
      if (node != null) {
        print('-> ${node.value.name}');
      }
      pathStack.pop(); // 然后再弹出该元素
      }
    }
  }
