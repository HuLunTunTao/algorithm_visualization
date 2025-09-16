import 'package:flutter/material.dart';

import 'package:graphview/GraphView.dart';

/// 基础节点数据（可扩展）
class VizNode {
  VizNode({
    required this.id,
    required this.key,
    this.label = '',
    this.color = Colors.lightBlue,
    this.highlighted = false,
    this.highlightColor = Colors.orange,
    this.visitedOrder,
  }) : gvNode = Node.Id(key);

  /// 对外暴露的节点标识（业务层使用的 ID）
  final String id;

  /// 传递给 graphview 的唯一 key（避免多个控制器之间的冲突）
  final String key;
  String label;
  Color color;

  /// 高亮
  bool highlighted;
  Color highlightColor;

  /// 访问次序（本科图论/遍历常用）
  int? visitedOrder;

  /// graphview 节点
  final Node gvNode;

  /// Widget builder 给 GraphView 用
  Widget build() {
    final base = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: highlighted
            ? [BoxShadow(color: highlightColor.withOpacity(.6), blurRadius: 12)]
            : [BoxShadow(color: Colors.black12.withOpacity(.08), blurRadius: 4)],
        border: highlighted
            ? Border.all(color: highlightColor, width: 2)
            : Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (visitedOrder != null)
            Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${visitedOrder!}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Text(
            label.isEmpty ? id : label,
            style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
    return base;
  }
}

class VizEdge {
  VizEdge({
    required this.u,
    required this.v,
    required this.sourceKey,
    required this.targetKey,
    this.directed = false,
    this.color = Colors.black87,
    this.weight,
  });

  final String u;
  final String v;
  final String sourceKey;
  final String targetKey;
  bool directed;
  Color color;
  num? weight;
}

/// 控制器：持有 Graph、节点/边表，提供外部接口操作并通知刷新
class GraphController extends ChangeNotifier {
  GraphController({String? namespace})
      : _namespace = namespace ?? 'g${_nextNamespace++}' {
    _graph = Graph();
  }

  static int _nextNamespace = 0;

  late Graph _graph;
  final Map<String, VizNode> _nodes = {};
  final List<VizEdge> _edges = [];
  final Map<String, String> _keyToId = {};

  final String _namespace;

  String _gvKey(String id) => '$_namespace::$id';

  Graph get graph => _graph;
  Map<String, VizNode> get nodes => _nodes;
  List<VizEdge> get edges => _edges;

  void reset() {
    _graph = Graph();
    _nodes.clear();
    _edges.clear();
    _keyToId.clear();
    notifyListeners();
  }

  /// 初始化：批量添加
  void initGraph({
    List<VizNode>? nodes,
    List<VizEdge>? edges,
  }) {
    reset();
    if (nodes != null) {
      for (final n in nodes) {
        addNode(n.id, label: n.label, color: n.color);
      }
    }
    if (edges != null) {
      for (final e in edges) {
        addEdge(e.u, e.v, directed: e.directed, color: e.color, weight: e.weight);
      }
    }
    notifyListeners();
  }

  bool hasNode(String id) => _nodes.containsKey(id);

  /// 添加节点（不存在时）
  void addNode(
      String id, {
        String? label,
        Color? color,
      }) {
    if (_nodes.containsKey(id)) return;
    final key = _gvKey(id);
    final node = VizNode(
      id: id,
      key: key,
      label: label ?? '',
      color: color ?? Colors.blue,
    );
    _nodes[id] = node;
    _keyToId[key] = id;
    _graph.addNode(node.gvNode);
    notifyListeners();
  }

  /// 添加边（节点不存在则补齐）
  void addEdge(
      String u,
      String v, {
        bool directed = false,
        Color? color,
        num? weight,
      }) {
    if (!hasNode(u)) addNode(u);
    if (!hasNode(v)) addNode(v);

    final source = _nodes[u]!;
    final target = _nodes[v]!;

    _edges.add(VizEdge(
      u: u,
      v: v,
      sourceKey: source.key,
      targetKey: target.key,
      directed: directed,
      color: color ?? Colors.black87,
      weight: weight,
    ));
    final edge = Edge(source.gvNode, target.gvNode);
    _graph.addEdgeS(edge);
    notifyListeners();
  }

  /// 高亮/取消高亮
  void highlightNode(String id, {bool on = true, Color? color}) {
    final n = _nodes[id];
    if (n == null) return;
    n.highlighted = on;
    if (color != null) n.highlightColor = color;
    notifyListeners();
  }

  /// 设置标签
  void setNodeLabel(String id, String label) {
    final n = _nodes[id];
    if (n == null) return;
    n.label = label;
    notifyListeners();
  }

  /// 设置颜色
  void setNodeColor(String id, Color color) {
    final n = _nodes[id];
    if (n == null) return;
    n.color = color;
    notifyListeners();
  }

  /// 设置访问序（遍历次序）
  void setVisitedOrder(String id, int? order) {
    final n = _nodes[id];
    if (n == null) return;
    n.visitedOrder = order;
    notifyListeners();
  }

  /// 清除所有高亮/访问序
  void clearHighlights({bool clearVisitedOrder = false}) {
    for (final n in _nodes.values) {
      n.highlighted = false;
      if (clearVisitedOrder) n.visitedOrder = null;
    }
    notifyListeners();
  }

  /// 根据 graphview 的节点 key 反查业务层节点
  VizNode? nodeFromKey(String key) {
    final id = _keyToId[key];
    if (id == null) return null;
    return _nodes[id];
  }
}
