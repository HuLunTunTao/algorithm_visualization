import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

import 'graph_controller.dart';

enum LayoutType { buchheim, fruchterman, tree }

class GraphCanvas extends StatefulWidget {
  const GraphCanvas({
    super.key,
    required this.controller,
    this.layoutType = LayoutType.fruchterman,
    this.orientation = BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT,
    this.canvasMinSize = Size.zero,
    this.defaultNodeSize = const Size(160, 80),
    this.edgeColor = const Color(0xFF5F6368),
    this.edgeWidth = 1.5,
    this.arrowColor = const Color(0xFF5F6368),
    this.onNodeTap,

  });

  final GraphController controller;
  final LayoutType layoutType;
  final int orientation;
  final Size canvasMinSize;
  final Size defaultNodeSize;

  final Color edgeColor;
  final double edgeWidth;
  final Color arrowColor;
  final void Function(String id)? onNodeTap;

  @override
  State<GraphCanvas> createState() => _GraphCanvasState();
}

class _GraphCanvasState extends State<GraphCanvas> {
  late final BuchheimWalkerConfiguration _buchCfg;
  late FruchtermanReingoldAlgorithm _force;
  late final Paint _edgePaint;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);

    _edgePaint = Paint()
      ..color = widget.edgeColor
      ..strokeWidth = widget.edgeWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    _buchCfg = BuchheimWalkerConfiguration()
      ..siblingSeparation = 40
      ..levelSeparation = 80
      ..subtreeSeparation = 40
      ..orientation = widget.orientation;

    // ★ Force 布局交给自定义边渲染器（中点箭头，和边完全一致）
    _force = FruchtermanReingoldAlgorithm(
      renderer: MidArrowEdgeRenderer(
        controller: widget.controller,
        arrowColor: widget.arrowColor,
        linePaint: _edgePaint,
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    // 避免在布局阶段 setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  Algorithm _pickAlgorithm() {
    switch (widget.layoutType) {
      case LayoutType.fruchterman:
        return _force;
      case LayoutType.buchheim:
      case LayoutType.tree:
      // 树/分层图仍用官方 TreeEdgeRenderer（折线），需要“中段箭头”的话可以再写一个
        return BuchheimWalkerAlgorithm(_buchCfg, TreeEdgeRenderer(_buchCfg));
    }
  }

  @override
  Widget build(BuildContext context) {

    // 当图中没有节点时，不渲染 GraphView，避免其内部崩溃
    if (widget.controller.nodes.isEmpty) {
      return const Center(
        child: Text(
          '图为空，请输入命令添加节点。',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    final algo = _pickAlgorithm();

    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : widget.canvasMinSize.width;
        final canvasH = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : widget.canvasMinSize.height;

        final bigW = max(canvasW, widget.canvasMinSize.width);
        final bigH = max(canvasH, widget.canvasMinSize.height);

        return InteractiveViewer(
          minScale: 0.3,
          maxScale: 4,
          panEnabled: true,
          scaleEnabled: true,
          child: SizedBox(
            width: bigW,
            height: bigH,
            child: ClipRect(
              child: Align(
                alignment: Alignment.topLeft,
                child: GraphView(
                  graph: widget.controller.graph,
                  algorithm: algo,
                  paint: _edgePaint,
                  animated: false,
                  builder: (node) {
                    final id = node.key!.value as String;
                    final v = widget.controller.nodes[id]!;
                    Widget child = v.build();
                    if (widget.onNodeTap != null) {
                      child = GestureDetector(onTap: () => widget.onNodeTap!(id), child: child);
                    }
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: widget.defaultNodeSize.width,
                        minHeight: widget.defaultNodeSize.height,
                      ),
                      child: child,
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


/// 自定义“中段箭头”渲染器：与边严格共线，放在边的中点（可调），并裁剪到两端节点矩形边界
class MidArrowEdgeRenderer extends EdgeRenderer {
  MidArrowEdgeRenderer({
    required this.controller,
    required this.arrowColor,
    required this.linePaint,
    this.centerT = 0.5,          // 箭头落点在边上的比例（0~1），0.5=正中
    this.marginStart = 10,        // 离开源节点的安全距离（像素）
    this.marginEnd = 10,          // 靠近目标节点的安全距离（像素）
    this.arrowLen = 14,           // 箭头长度
    this.arrowWidth = 10,         // 箭头底边宽
    this.hitInflate = 4,          // 命中膨胀，避免紧贴节点边缘
  });

  final GraphController controller;

  final Color arrowColor;
  final Paint linePaint;

  final double centerT;
  final double marginStart;
  final double marginEnd;
  final double arrowLen;
  final double arrowWidth;
  final double hitInflate;

  static const double _eps = 1e-3;


  @override
  void render(Canvas canvas, Graph graph, Paint paint) {
    final fill = Paint()
      ..color = arrowColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    for (final e in graph.edges) {
      final a = e.source, b = e.destination;

      // ▼▼▼ 2. 添加核心判断逻辑 ▼▼▼
      final sourceId = a.key!.value as String;
      final destId = b.key!.value as String;

      // 从 controller 中查找我们自己定义的 VizEdge 对象
      // 这里使用 try-catch 是为了防止在某些过渡状态下找不到边而崩溃
      VizEdge? vizEdge;
      try {
        vizEdge = controller.edges.firstWhere(
              (ve) => ve.u == sourceId && ve.v == destId,
        );
      } catch (e) {
        // 如果找不到，就默认它是有向的，或者直接跳过
        continue;
      }
      // ▲▲▲ 核心判断逻辑结束 ▲▲▲

      // 中心点计算... (这部分不变)
      final c1 = Offset(
        a.position.dx + (a.size.width > 0 ? a.size.width / 2 : 0),
        a.position.dy + (a.size.height > 0 ? a.size.height / 2 : 0),
      );
      final c2 = Offset(
        b.position.dx + (b.size.width > 0 ? b.size.width / 2 : 0),
        b.position.dy + (b.size.height > 0 ? b.size.height / 2 : 0),
      );

      // ... 后续的矩形裁剪、计算 S 和 E、画线等逻辑都不变 ...
      Rect? ra, rb;
      if (a.size.width > 0 && a.size.height > 0) {
        ra = Rect.fromLTWH(a.position.dx, a.position.dy, a.size.width, a.size.height)
            .inflate(hitInflate);
      }
      if (b.size.width > 0 && b.size.height > 0) {
        rb = Rect.fromLTWH(b.position.dx, b.position.dy, b.size.width, b.size.height)
            .inflate(hitInflate);
      }
      final S = _intersectLineWithRect(c2, c1, ra) ?? c1;
      final E = _intersectLineWithRect(c1, c2, rb) ?? c2;
      var dir = E - S;
      final len = dir.distance;
      if (len <= _eps) continue;
      final ux = dir.dx / len, uy = dir.dy / len;
      final usableLen = max(0.0, len - (marginStart + marginEnd));
      if (usableLen <= _eps) continue;
      final start = Offset(S.dx + marginStart * ux, S.dy + marginStart * uy);
      final end = Offset(E.dx - marginEnd * ux, E.dy - marginEnd * uy);

      // 画“边”
      canvas.drawLine(start, end, linePaint);

      // ▼▼▼ 3. 根据 directed 属性决定是否画箭头 ▼▼▼
      if (vizEdge.directed) {
        final t = centerT.clamp(0.0, 1.0);
        final center = Offset(
          start.dx + (end.dx - start.dx) * t,
          start.dy + (end.dy - start.dy) * t,
        );
        _drawCenteredTriangle(canvas, fill, center, ux, uy, arrowLen, arrowWidth);
      }
    }
  }

  // —— 工具方法 —— //

  void _drawCenteredTriangle(
      Canvas canvas,
      Paint fill,
      Offset center,
      double ux,
      double uy,
      double len,
      double width,
      ) {
    // 以“中心”为基准构造三角形：顶点指向 (ux,uy)
    final tip = Offset(center.dx + (len / 2) * ux, center.dy + (len / 2) * uy);
    final baseC = Offset(center.dx - (len / 2) * ux, center.dy - (len / 2) * uy);
    final left = Offset(baseC.dx + (width / 2) * uy, baseC.dy - (width / 2) * ux);
    final right = Offset(baseC.dx - (width / 2) * uy, baseC.dy + (width / 2) * ux);

    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();

    canvas.drawPath(path, fill);
  }

  /// 线段 AB 与矩形 r 的交点：返回**靠近 B** 的那个（用于“离开 A/进入 B”）
  Offset? _intersectLineWithRect(Offset a, Offset b, Rect? r) {
    if (r == null) return null;
    final hits = <Offset?>[
      _segIntersect(a, b, Offset(r.left, r.top),     Offset(r.right, r.top)),
      _segIntersect(a, b, Offset(r.right, r.top),    Offset(r.right, r.bottom)),
      _segIntersect(a, b, Offset(r.right, r.bottom), Offset(r.left, r.bottom)),
      _segIntersect(a, b, Offset(r.left, r.bottom),  Offset(r.left, r.top)),
    ].whereType<Offset>().toList();

    if (hits.isEmpty) return null;
    hits.sort((p, q) => (p - b).distanceSquared.compareTo((q - b).distanceSquared));
    return hits.first;
  }

  Offset? _segIntersect(Offset p1, Offset p2, Offset p3, Offset p4) {
    final x1 = p1.dx, y1 = p1.dy, x2 = p2.dx, y2 = p2.dy;
    final x3 = p3.dx, y3 = p3.dy, x4 = p4.dx, y4 = p4.dy;
    final den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    if (den.abs() < _eps) return null;

    final px =
        ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / den;
    final py =
        ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / den;
    final p = Offset(px, py);

    bool onSeg(Offset a, Offset b, Offset p) =>
        p.dx >= min(a.dx, b.dx) - 1e-3 &&
            p.dx <= max(a.dx, b.dx) + 1e-3 &&
            p.dy >= min(a.dy, b.dy) - 1e-3 &&
            p.dy <= max(a.dy, b.dy) + 1e-3;

    return (onSeg(p1, p2, p) && onSeg(p3, p4, p)) ? p : null;
  }
}
