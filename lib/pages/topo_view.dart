import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart' hide Node;

import '../model/KnowledgePoint.dart';
import '../struct/my_stack.dart';
import '../struct/my_graph.dart';
import '../algo/guide_learningway.dart';
import '../graph_viz/graph_canvas.dart';
import '../graph_viz/graph_controller.dart';
import '../utils/knowledge_utils.dart';

class TopoView extends StatelessWidget {
  const TopoView({super.key, required this.tree});

  final MyGraph<KnowledgePoint> tree;

  @override
  Widget build(BuildContext context) {
    final nodes = collectAllNodes(tree.root);
    final visited = <MyGraphNode<KnowledgePoint>>{};
    final stack = MyStack<MyGraphNode<KnowledgePoint>>();
    final roots = findRoots(nodes);
    for (final r in roots) {
      tuopu_DFS<KnowledgePoint>(r, visited, nodes, stack);
    }
    final order = <MyGraphNode<KnowledgePoint>>[];
    while (!stack.isEmpty()) {
      final n = stack.top();
      stack.pop();
      if (n != null) order.add(n);
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text("拓扑排序结果"),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.blue.shade50),
          columns: const [
            DataColumn(label: Text("序号")),
            DataColumn(label: Text("知识点")),
          ],
          rows: List.generate(order.length, (index) {
            final node = order[index];
            return DataRow(cells: [
              DataCell(Text("${index + 1}")),
              DataCell(Text(node.value.name)),
            ]);
          }),
        ),
      ),
    );
  }
}
