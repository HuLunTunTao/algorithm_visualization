import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart' hide Node;

import '../model/KnowledgePoint.dart';
import '../struct/my_stack.dart';
import '../struct/tree.dart';
import '../algo/guide_learningway.dart';
import '../graph_viz/graph_canvas.dart';
import '../graph_viz/graph_controller.dart';
import '../utils/knowledge_utils.dart';

class TopoView extends StatelessWidget {
  const TopoView({super.key, required this.tree});

  final MyTree<KnowledgePoint> tree;

  @override
  Widget build(BuildContext context) {
    final nodes = collectAllNodes(tree.root);
    final visited = <Node<KnowledgePoint>>{};
    final stack = MyStack<Node<KnowledgePoint>>();
    final roots = findRoots(nodes);
    for (final r in roots) {
      tuopu_DFS<KnowledgePoint>(r, visited, nodes, stack);
    }
    final order = <Node<KnowledgePoint>>[];
    while (!stack.isEmpty()) {
      final n = stack.top();
      stack.pop();
      if (n != null) order.add(n);
    }
    final ctrl = GraphController();
    for (final n in order) {
      ctrl.addNode(n.value.name, label: n.value.name);
    }
    for (int i = 0; i < order.length - 1; i++) {
      ctrl.addEdge(order[i].value.name, order[i + 1].value.name, directed: true);
    }
    return GraphCanvas(
      controller: ctrl,
      layoutType: LayoutType.buchheim,
      orientation: BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT,
    );
  }
}
