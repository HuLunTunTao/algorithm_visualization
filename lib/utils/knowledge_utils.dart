import '../model/KnowledgePoint.dart';
import '../struct/my_graph.dart';

MyGraph<KnowledgePoint> buildKnowledgeTree() {
  final points = KnowledgePointRepository.getAllKnowledgePoints();
  final rootKP = points.firstWhere((kp) => kp.prerequisites.isEmpty);
  final tree = MyGraph<KnowledgePoint>(rootKP);
  final Map<String, MyGraphNode<KnowledgePoint>> nodeMap = {rootKP.name: tree.root};

  bool added = true;
  while (added) {
    added = false;
    for (final kp in points) {
      if (nodeMap.containsKey(kp.name)) continue;
      if (kp.prerequisites.every((p) => nodeMap.containsKey(p))) {
        final parents = kp.prerequisites.map((p) => nodeMap[p]!).toList();
        nodeMap[kp.name] = tree.addNode(kp, parents);
        added = true;
      }
    }
  }
  return tree;
}

Set<MyGraphNode<KnowledgePoint>> collectAllNodes(MyGraphNode<KnowledgePoint> root) {
  final visited = <MyGraphNode<KnowledgePoint>>{};
  void dfs(MyGraphNode<KnowledgePoint> node) {
    if (visited.contains(node)) return;
    visited.add(node);
    final children = node.children ?? [];
    for (final c in children) {
      dfs(c);
    }
  }
  dfs(root);
  return visited;
}

Iterable<MyGraphNode<KnowledgePoint>> findRoots(Set<MyGraphNode<KnowledgePoint>> nodes) {
  return nodes.where((n) => n.parents == null || n.parents!.isEmpty);
}
