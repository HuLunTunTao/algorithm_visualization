import 'package:algorithm_visualization/model/KnowledgePoint.dart';
import 'package:algorithm_visualization/struct/my_graph.dart';

// 假设的KMP函数，为了让测试文件可以运行
int kmp(String text, String pattern) {
  // 简化实现，仅用于测试，实际应使用真正的KMP算法
  return text.indexOf(pattern);
}

// 假设的KnowledgePointRepository，为了让测试文件可以运行
class KnowledgePointRepository {
  static final List<KnowledgePoint> _allKnowledgePoints = [
    KnowledgePoint(name: '入门知识点', prerequisites: [], difficulty: 1, studyTime: 30),
    KnowledgePoint(name: '数组', prerequisites: ['入门知识点'], difficulty: 2, studyTime: 60),
    KnowledgePoint(name: '链表', prerequisites: ['入门知识点'], difficulty: 3, studyTime: 90),
    KnowledgePoint(name: '图论', prerequisites: ['数组', '链表'], difficulty: 4, studyTime: 120),
    KnowledgePoint(name: '哈希表', prerequisites: ['数组'], difficulty: 4, studyTime: 90),
  ];

  static KnowledgePoint? getKnowledgePointByName(String name) {
    return _allKnowledgePoints.firstWhere((kp) => kp.name == name);
  }

  static List<KnowledgePoint> getEntryLevelKnowledgePoints() {
    return _allKnowledgePoints.where((kp) => kp.prerequisites.isEmpty).toList();
  }
}

void main() {
  print('--- 开始测试 MyTree/图结构 ---');

  // 1. 创建图的根节点
  final rootPoint = KnowledgePointRepository.getEntryLevelKnowledgePoints().first;
  final rootNode = KnowledgePoint(
    name: rootPoint.name,
    prerequisites: rootPoint.prerequisites,
    difficulty: rootPoint.difficulty,
    studyTime: rootPoint.studyTime,
  );
  final myGraph = MyGraph<KnowledgePoint>(rootNode);
  print('\n--- 根节点已创建 ---');

  // 2. 添加一个有单个父节点的节点（模拟树的行为）
  final arrayPoint = KnowledgePointRepository.getKnowledgePointByName('数组')!;
  final arrayNode = myGraph.addNode(
    KnowledgePoint(
      name: arrayPoint.name,
      prerequisites: arrayPoint.prerequisites,
      difficulty: arrayPoint.difficulty,
      studyTime: arrayPoint.studyTime,
    ),
    [myGraph.root], // 传入父节点列表
  );
  print('\n--- 已添加单个父节点：数组 ---');
  myGraph.dfsPrint(myGraph.root);

  // 3. 添加一个有多个父节点的节点（验证图的功能）
  final graphTheoryPoint = KnowledgePointRepository.getKnowledgePointByName('图论')!;
  final graphTheoryNode = myGraph.addNode(
    KnowledgePoint(
      name: graphTheoryPoint.name,
      prerequisites: graphTheoryPoint.prerequisites,
      difficulty: graphTheoryPoint.difficulty,
      studyTime: graphTheoryPoint.studyTime,
    ),
    [arrayNode, myGraph.root], // 传入多个父节点
  );
  print('\n--- 已添加多个父节点：图论 ---');
  print('注意：由于DFS遍历方式，图论节点可能被多次访问，已添加visited集合解决');
  myGraph.dfsPrint(myGraph.root);

  // 4. 测试查找功能
  print('\n--- 测试DFS查找功能 ---');
  final foundNode = myGraph.dfsFind(myGraph.root, '图论');
  if (foundNode != null) {
    print('成功找到节点: ${foundNode.value.name}');
  } else {
    print('未找到节点');
  }

  // 5. 测试“带子节点”的删除功能
  print('\n--- 测试删除功能（保留子节点） ---');
  final linkListPoint = KnowledgePointRepository.getKnowledgePointByName('链表')!;
  final linkListNode = myGraph.addNode(
    KnowledgePoint(
      name: linkListPoint.name,
      prerequisites: linkListPoint.prerequisites,
      difficulty: linkListPoint.difficulty,
      studyTime: linkListPoint.studyTime,
    ),
    [myGraph.root],
  );
  // 添加一个子节点到链表
  final childNode = myGraph.addNode(
    KnowledgePoint(name: '双向链表', prerequisites: ['链表'], difficulty: 4, studyTime: 60),
    [linkListNode],
  );

  print('\n--- 删除前 ---');
  myGraph.dfsPrint(myGraph.root);

  myGraph.deleteNode_withson(linkListNode);
  print('\n--- 删除后 ---');
  myGraph.dfsPrint(myGraph.root);

  // 6. 测试“不带子节点”的删除功能
  print('\n--- 测试删除功能（不保留子节点） ---');
  final hashTablePoint = KnowledgePointRepository.getKnowledgePointByName('哈希表')!;
  final hashTableNode = myGraph.addNode(
    KnowledgePoint(
      name: hashTablePoint.name,
      prerequisites: hashTablePoint.prerequisites,
      difficulty: hashTablePoint.difficulty,
      studyTime: hashTablePoint.studyTime,
    ),
    [arrayNode],
  );

  print('\n--- 删除前 ---');
  myGraph.dfsPrint(myGraph.root);

  myGraph.deleteNode_withoutson(hashTableNode);
  print('\n--- 删除后 ---');
  myGraph.dfsPrint(myGraph.root);

  print('\n--- 测试结束 ---');
}