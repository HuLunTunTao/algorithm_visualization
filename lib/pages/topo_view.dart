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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.indigo.shade100),
              columns: const [
                DataColumn(label: Text("序号")),
                DataColumn(label: Text("知识点")),
              ],
              rows: List.generate(order.length, (index) {
                final node = order[index];
                return DataRow(
                  color: MaterialStateProperty.all(
                    index.isEven ? Colors.white : Colors.indigo.shade50,
                  ),
                  cells: [
                    DataCell(Text("${index + 1}")),
                    DataCell(Text(node.value.name)),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
