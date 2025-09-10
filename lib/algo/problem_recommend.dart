// problem_recommender.dart
import 'dart:math';
import 'dart:collection';

import '../model/AlgorithmProblem.dart';
import '../model/KnowledgePoint.dart';
import '../struct/my_graph.dart';
import '../struct/my_queue.dart';
import '../struct/my_stack.dart';

// 由于my_graph.dart中的MyGraph无法完整构建图，我们在这里实现一个本地的图节点。
// 这个节点包含了父节点和子节点的引用，可以构建完整的图结构。
class _LocalGraphNode<T extends KnowledgePoint> implements MyGraphNode<T> {
  @override
  final T value;
  @override
  final List<MyGraphNode<T>> parents = [];
  @override
  final List<MyGraphNode<T>> children = [];

  _LocalGraphNode(this.value);
}

class ProblemPathRecommender {
  // 仅构建一次完整的图的节点映射表
  static final Map<String, _LocalGraphNode<KnowledgePoint>> _fullGraphMap = _buildFullKnowledgeGraphMap();

  static Map<String, _LocalGraphNode<KnowledgePoint>> _buildFullKnowledgeGraphMap() {
    final allKnowledgePoints = KnowledgePointRepository.getAllKnowledgePoints();
    final nodeMap = <String, _LocalGraphNode<KnowledgePoint>>{};

    // 第一步：为每个知识点创建本地节点实例
    for (final kp in allKnowledgePoints) {
      nodeMap[kp.name] = _LocalGraphNode(kp);
    }

    // 第二步：连接本地节点，建立完整的图
    for (final kp in allKnowledgePoints) {
      final currentNode = nodeMap[kp.name]!;
      for (final prereqName in kp.prerequisites) {
        if (nodeMap.containsKey(prereqName)) {
          final parentNode = nodeMap[prereqName]!;
          currentNode.parents.add(parentNode);
          parentNode.children.add(currentNode);
        }
      }
    }
    return nodeMap;
  }

  // 基于DFS和栈的拓扑排序，返回有序的学习路径
  static Queue<KnowledgePoint>? _tuopuSort(String targetName) {
    final targetNode = _fullGraphMap[targetName];
    if (targetNode == null) {
      return null;
    }

    final sonNodes = <_LocalGraphNode<KnowledgePoint>>{};
    final visitedPre = <_LocalGraphNode<KnowledgePoint>>{};

    // 使用DFS从目标节点反向追溯所有前置节点
    void findPre(_LocalGraphNode<KnowledgePoint> node) {
      if (visitedPre.contains(node)) {
        return;
      }
      visitedPre.add(node);
      for (final parent in node.parents) {
        findPre(parent as _LocalGraphNode<KnowledgePoint>);
      }
      sonNodes.add(node);
    }

    findPre(targetNode);
    
    // 使用 Dart 内置的栈和队列来完成拓扑排序，完全绕开有缺陷的自定义类
    final visited = <_LocalGraphNode<KnowledgePoint>>{};
    final pathStack = <_LocalGraphNode<KnowledgePoint>>[];
    final roots = sonNodes.where((node) => node.parents.isEmpty).toList();

    if (roots.isEmpty && sonNodes.isNotEmpty) {
      return null;
    }

    void tuopuDFS(_LocalGraphNode<KnowledgePoint> node) {
      if (!sonNodes.contains(node) || visited.contains(node)) {
        return;
      }

      visited.add(node);
      for (final child in node.children) {
        tuopuDFS(child as _LocalGraphNode<KnowledgePoint>);
      }
      pathStack.add(node);
    }

    for (final root in roots) {
      tuopuDFS(root);
    }

    final pathQueue = Queue<KnowledgePoint>();
    while(pathStack.isNotEmpty) {
      pathQueue.add(pathStack.removeLast().value);
    }
    return pathQueue;
  }

  // 推荐学习路径的核心函数
  static List<Map<String, dynamic>> recommendLearningPaths(
      String problemName, List<String> learnedKnowledge) {
    
    final problem = algorithmProblems.firstWhere(
        (p) => p.name == problemName,
        orElse: () => throw Exception("Problem not found."));

    final recommendations = <Map<String, dynamic>>[];

    for (final applicableKpName in problem.applicableKnowledgePoints.keys) {
      final applicableKp = KnowledgePointRepository.getKnowledgePointByName(applicableKpName)!;

      if (learnedKnowledge.contains(applicableKpName)) {
        recommendations.add({
          "solution_knowledge": applicableKp,
          "path": <KnowledgePoint>[],
          "steps_count": 0,
          "total_difficulty": 0,
          "total_study_time": 0,
          "similarity_score": 0.0,
          "total_score": -1000.0,
        });
        continue;
      }
      
      final pathQueue = _tuopuSort(applicableKpName);
      if (pathQueue == null || pathQueue.isEmpty) {
        continue;
      }

      final path = pathQueue.toList();
      final unlearnedPath = path.where((kp) => !learnedKnowledge.contains(kp.name)).toList();

      // 计算多维度得分
      final totalDifficulty = unlearnedPath.map((kp) => kp.difficulty).fold<int>(0, (a, b) => a + b);
      final totalStudyTime = unlearnedPath.map((kp) => kp.studyTime).fold<int>(0, (a, b) => a + b);
      double similarityScore = 0.0;
      for (final pathKp in unlearnedPath) {
        final prereqs = pathKp.prerequisites;
        final intersectionCount = prereqs.where((prereq) => learnedKnowledge.contains(prereq)).length;
        similarityScore += intersectionCount;
      }

      // 综合评分公式（权重可调）
      const weightCount = 1.0;
      const weightDifficulty = 1.0;
      const weightTime = 1.0;
      const weightSimilarity = 2.0;

      final totalScore = weightCount * unlearnedPath.length +
          weightDifficulty * totalDifficulty +
          weightTime * totalStudyTime -
          weightSimilarity * similarityScore;

      recommendations.add({
        "solution_knowledge": applicableKp,
        "path": unlearnedPath,
        "steps_count": unlearnedPath.length,
        "total_difficulty": totalDifficulty,
        "total_study_time": totalStudyTime,
        "similarity_score": similarityScore,
        "total_score": totalScore,
      });
    }

    recommendations.sort((a, b) => a["total_score"].compareTo(b["total_score"]));

    return recommendations;
  }
}