import 'dart:collection';
import '../struct/my_queue.dart';
import '../model/KnowledgePoint.dart';

MyQueue<KnowledgePoint> findDescendants(String knowledgePointName) {
  // 步骤1：数据准备（预处理），构建高效的索引
  // 这个步骤是优化的核心，我们用空间换取时间，只做一次遍历来建立查找表。

  // 获取所有的知识点
  final allPoints = KnowledgePointRepository.getAllKnowledgePoints();
  
  // 建立一个名字到知识点对象的映射表，方便后续快速查找
  // Map<知识点名称, 知识点对象>
  final nameToPointMap = <String, KnowledgePoint>{};
  
  // 建立一个前置知识点到其依赖知识点列表的映射表
  // 这个表让我们可以快速找到一个知识点的所有直接后代
  // Map<前置知识点名称, 依赖于它的知识点列表>
  final dependentMap = <String, List<KnowledgePoint>>{};

  // 遍历所有知识点，填充上面两个 Map
  for (final point in allPoints) 
  {
    // 填充 nameToPointMap
    nameToPointMap[point.name] = point;

    // 填充 dependentMap。
    // 遍历当前知识点的所有前置知识点
    for (final prerequisite in point.prerequisites) {
      // 如果这个前置知识点还没有对应的后代列表，就创建一个新列表
      dependentMap.putIfAbsent(prerequisite, () => []);
      // 将当前知识点添加到其前置知识点的后代列表中
      dependentMap[prerequisite]!.add(point);
    }
  }

  // 步骤2：执行高效的 BFS（广度优先搜索）
  // 这一步和原来的算法逻辑相似，但查找子节点的方式完全不同。

  // 通过我们构建的 Map 快速找到起始节点
  final startNode = nameToPointMap[knowledgePointName];
  // 如果找不到，直接返回一个空的队列
  if (startNode == null) {
    print("找不到名为 '$knowledgePointName' 的知识点。");
    return MyQueue<KnowledgePoint>();
  }

  // 初始化 BFS 需要的两个队列和一个集合
  final resultQueue = MyQueue<KnowledgePoint>(); // 存储最终结果
  final traversalQueue = MyQueue<KnowledgePoint>(); // 用于广度遍历
  final visitedNames = <String>{}; // 记录已访问过的节点，防止重复和循环

  // 将起始节点的所有直接后代（子节点）入队
  // 使用我们预先构建的 dependentMap 快速获取子节点列表
  final initialChildren = dependentMap[startNode.name] ?? [];
  for (final child in initialChildren) {
    // 检查是否已访问，如果未访问则入队并标记为已访问
    if (visitedNames.add(child.name)) {
      traversalQueue.enqueue(child);
    }
  }

  // BFS 主循环：直到遍历队列为空
  while (!traversalQueue.isEmpty()) {
    // 从队列头部取出一个节点
    final currentNode = traversalQueue.dequeue()!;
    
    // 将其添加到结果队列中
    resultQueue.enqueue(currentNode);

    // 获取当前节点的所有子节点（后代）
    // 同样使用高效的 dependentMap 来查找
    final children = dependentMap[currentNode.name] ?? [];
    
    // 遍历这些子节点，将未访问过的入队
    for (final child in children) {
      if (visitedNames.add(child.name)) {
        traversalQueue.enqueue(child);
      }
    }
  }

  return resultQueue;
  
}