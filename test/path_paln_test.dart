// test/path_plan_test.dart

import '../lib/model/KnowledgePoint.dart';
import '../lib/struct/tree.dart';
import '../lib/struct/my_stack.dart';
import '../lib/algo/guide_learningway.dart';

void main() {
  print("--- 开始测试 pathPlan 函数 ---");
  
  // 1. 获取所有知识点数据
  final allKPs = KnowledgePointRepository.getAllKnowledgePoints();
  final nodeMap = <String, Node<Knowledge>>{};

  // 2. 构建知识图谱
  // 找到所有没有前置条件的根节点
  final rootKPs = allKPs.where((kp) => kp.prerequisites.isEmpty).toList();

  if (rootKPs.isEmpty) {
    print("❌ 测试失败：未找到知识图谱的根节点。");
    return;
  }
  final rootKP = rootKPs.first;
  final tree = MyTree<Knowledge>(Knowledge(
    name: rootKP.name,
    prerequisites: rootKP.prerequisites,
    difficulty: rootKP.difficulty,
    studyTime: rootKP.studyTime,
  ));
  nodeMap[rootKP.name] = tree.root;

  int addedCount = 1;
  while (addedCount < allKPs.length) {
    int newNodesAdded = 0;
    for (final kp in allKPs) {
      if (!nodeMap.containsKey(kp.name)) {
        bool allParentsExist = kp.prerequisites.every((prereqName) => nodeMap.containsKey(prereqName));
        if (allParentsExist) {
          final parents = kp.prerequisites.map((prereqName) => nodeMap[prereqName]!).toList();
          final newNode = tree.addNode(
            Knowledge(
              name: kp.name,
              prerequisites: kp.prerequisites,
              difficulty: kp.difficulty,
              studyTime: kp.studyTime,
            ),
            parents,
          );
          nodeMap[kp.name] = newNode;
          newNodesAdded++;
        }
      }
    }
    if (newNodesAdded == 0 && addedCount < allKPs.length) {
      print("警告：检测到无法添加新节点，可能存在循环依赖或数据问题。");
      break;
    }
    addedCount += newNodesAdded;
  }

  // 3. 调用 pathPlan 函数
  final targetName = "拓扑排序";
  print("\n--- 正在为目标知识点 '$targetName' 规划学习路径 ---");
  
  final pathStack = pathPlan<Knowledge>(tree, targetName);
  
  if (pathStack == null) {
    print("❌ 测试失败：未能生成学习路径，目标节点可能不存在。");
    return;
  }

  // 4. 打印并验证结果
  final resultList = <String>[];
  // 按照你的思路修改，使用 top() 获取元素，然后 pop() 移除
  while (!pathStack.isEmpty()) {
    final poppedValue = pathStack.top(); // 获取栈顶元素
    pathStack.pop(); // 移除栈顶元素
    if (poppedValue != null) {
      resultList.add(poppedValue.value.name);
    }
  }
  
  print("\n--- 生成的学习路径 ---");
  print(resultList.join(' -> '));

  // 验证拓扑排序的正确性
  bool isValidTopologicalSort = true;
  for (final kpName in resultList) {
    final kp = KnowledgePointRepository.getKnowledgePointByName(kpName)!;
    for (final prereq in kp.prerequisites) {
      if (!resultList.sublist(0, resultList.indexOf(kpName)).contains(prereq)) {
        isValidTopologicalSort = false;
        print("❌ 错误：知识点 '$kpName' 的前置 '$prereq' 未提前学习。");
        break;
      }
    }
    if (!isValidTopologicalSort) break;
  }
  
  print("\n--- 测试结果 ---");
  if (isValidTopologicalSort) {
    print("✅ 测试成功：生成的学习路径是一个有效的拓扑排序！");
  } else {
    print("❌ 测试失败：生成的路径不符合拓扑排序规则。");
  }
}