import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:algorithm_visualization/graph_viz/graph_controller.dart';
import 'package:algorithm_visualization/graph_viz/command_router.dart';

void main() {
  test('CommandRouter basic flow', () {
    final ctrl = GraphController();
    final router = CommandRouter(ctrl);

    final ok = router.apply('''
INIT
ADD_NODE id:n1 label:"A" color:#2196F3
ADD_NODE id:n2 label:"B"
ADD_EDGE u:n1 v:n2 directed:false weight:3
HIGHLIGHT id:n1 on:true color:#FF9800
SET_VISIT_ORDER id:n1 order:1
''');

    expect(ok.every((e) => e), isTrue);
    expect(ctrl.nodes.length, 2);
    expect(ctrl.edges.length, 1);

    final n1 = ctrl.nodes['n1']!;
    expect(n1.label, 'A');
    expect(n1.highlighted, true);
    expect(n1.visitedOrder, 1);

    // 颜色大致判断 alpha=FF, R=21, G=96, B=F3
    expect(n1.color.value, equals(const Color(0xFF2196F3).value));

    // 改标签/颜色/高亮
    final ok2 = router.apply('''
SET_LABEL id:n2 label:"B2"
SET_COLOR id:n2 color:#4CAF50
HIGHLIGHT id:n2 on:true
''');
    expect(ok2.every((e) => e), isTrue);

    final n2 = ctrl.nodes['n2']!;
    expect(n2.label, 'B2');
    expect(n2.color.value, equals(const Color(0xFF4CAF50).value));
    expect(n2.highlighted, true);

    // 清除
    final ok3 = router.apply('CLEAR_HIGHLIGHT clearVisited:true');
    expect(ok3.single, isTrue);
    expect(n1.highlighted, false);
    expect(n2.highlighted, false);
    expect(n1.visitedOrder, isNull);
  });
}
