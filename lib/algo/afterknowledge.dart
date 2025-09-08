import '../struct/my_graph.dart';
import '../model/KnowledgePoint.dart';
import '../struct/my_queue.dart';

MyQueue<KnowledgePoint> findDescendants(String knowledgePointName) 
{
  // 1. 初始化队列和集合
  final resultQueue = MyQueue<KnowledgePoint>();
  final traversalQueue = MyQueue<KnowledgePoint>();
  final visitedNames = <String>{};

  //调用知识点类的函数搜索目标节点
  final startNode = KnowledgePointRepository.getKnowledgePointByName(knowledgePointName);
  if (startNode == null) 
  {
    print("找不到名为 '$knowledgePointName' 的知识点。");
    return resultQueue;
  }
  
  //找以该点为前置的节点（即子节点）
  final initialChildren = KnowledgePointRepository.getDependentKnowledgePoints(startNode.name);
  for (final child in initialChildren)
   {
    if (visitedNames.add(child.name))   //如果该点没被访问，就被加入已访问
    {
      traversalQueue.enqueue(child);  //加入待遍历队列
    }
  }

  //DBS
  while (!traversalQueue.isEmpty())   //直至队空结束
  {
    final currentNode = traversalQueue.dequeue();
    if (currentNode == null) 
    {
      continue;
    }

    // 将当前节点添加到结果队列
    resultQueue.enqueue(currentNode);

    // 找到当前节点的所有子节点（即以当前节点为前置知识点的所有知识点）
    final children = KnowledgePointRepository.getDependentKnowledgePoints(currentNode.name);

    // 将未访问过的子节点入队
    for (final child in children) 
    {
      if (visitedNames.add(child.name)) 
      {
        traversalQueue.enqueue(child);
      }
    }
  }

  return resultQueue;
}