import '../model/KnowledgePoint.dart';
import '../struct/tree.dart';

MyTree<KnowledgePoint> buildKnowledgeTree() {
  final points = KnowledgePointRepository.getAllKnowledgePoints();
  final rootKP = points.firstWhere((kp) => kp.prerequisites.isEmpty);
  final tree = MyTree<KnowledgePoint>(rootKP);
  final Map<String, Node<KnowledgePoint>> nodeMap = {rootKP.name: tree.root};

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

Set<Node<KnowledgePoint>> collectAllNodes(Node<KnowledgePoint> root) {
  final visited = <Node<KnowledgePoint>>{};
  void dfs(Node<KnowledgePoint> node) {
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

Iterable<Node<KnowledgePoint>> findRoots(Set<Node<KnowledgePoint>> nodes) {
  return nodes.where((n) => n.parents == null || n.parents!.isEmpty);
}
