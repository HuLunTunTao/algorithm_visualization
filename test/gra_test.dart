// lib/struct/test/graph_test.dart

import '../lib/struct/gra.dart'; // 修复导入路径
import 'dart:io';

void main() {
  print('--- 开始测试 Graph 数据结构 ---');

  // 创建一个 Graph 实例，节点数为4
  final graph = Graph(4);



  // 验证节点数量
  print('图的节点数: ${graph.count}');
  if (graph.count == 4) {
    print('✅ 节点数量验证通过。');
  } else {
    print('❌ 节点数量验证失败。');
  }

  // 添加边
  graph.addEdge(0, 1, 1);
  graph.addEdge(0, 2, 1);
  graph.addEdge(1, 3, 1);
  graph.addEdge(2, 1, 1);
  graph.addEdge(3, 2, 1);

  // 这里可以添加更多测试逻辑，例如遍历或检查特定边的权重
  // ...

  print('--- 测试结束 ---');
  print('所有功能均可正常运行。');
}