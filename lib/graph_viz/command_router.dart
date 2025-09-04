import 'dart:ui';

import 'package:flutter/material.dart';

import 'graph_controller.dart';

Color? _parseColor(String s) {
  if (!s.startsWith('#')) return null;
  final hex = s.substring(1);
  int value;
  if (hex.length == 6) {
    value = int.parse('FF$hex', radix: 16); // default opaque
  } else if (hex.length == 8) {
    value = int.parse(hex, radix: 16);
  } else {
    return null;
  }
  return Color(value);
}

bool _parseBool(String s) {
  final ls = s.toLowerCase();
  return ls == 'true' || ls == '1' || ls == 'yes' || ls == 'on';
}

int? _parseInt(String s) {
  return int.tryParse(s);
}

num? _parseNum(String s) {
  return num.tryParse(s);
}

/// 简单的 tokenizer：按空格分，但支持引号字符串
List<String> _splitTokens(String line) {
  final List<String> out = [];
  final sb = StringBuffer();
  bool inQuotes = false;

  for (int i = 0; i < line.length; i++) {
    final c = line[i];
    if (c == '"') {
      inQuotes = !inQuotes;
      continue;
    }
    if (!inQuotes && c.trim().isEmpty) {
      if (sb.isNotEmpty) {
        out.add(sb.toString());
        sb.clear();
      }
    } else {
      sb.write(c);
    }
  }
  if (sb.isNotEmpty) out.add(sb.toString());
  return out;
}

/// 命令路由：把一行行命令执行到 GraphController
class CommandRouter {
  CommandRouter(this.controller, {void Function(String msg)? onLog})
      : log = onLog ?? ((_) {});

  final GraphController controller;
  final void Function(String) log;

  /// 返回每行执行是否成功（true/false），与输入行对齐
  List<bool> apply(String commands) {
    final lines = commands
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && !e.startsWith('#'))
        .toList();

    final results = <bool>[];
    for (final line in lines) {
      results.add(_applyOne(line));
    }
    return results;
  }

  bool _applyOne(String line) {
    try {
      final tokens = _splitTokens(line);
      if (tokens.isEmpty) return false;

      final cmd = tokens.first.toUpperCase();
      final args = <String, String>{};
      for (int i = 1; i < tokens.length; i++) {
        final t = tokens[i];
        final idx = t.indexOf(':');
        if (idx <= 0) continue;
        final k = t.substring(0, idx);
        final v = t.substring(idx + 1);
        args[k.toLowerCase()] = v;
      }

      switch (cmd) {
        case 'INIT':
        case 'RESET':
          controller.reset();
          return true;

        case 'ADD_NODE': {
          final id = args['id'];
          if (id == null) return false;
          final label = args['label'];
          final color = args.containsKey('color') ? _parseColor(args['color']!) : null;
          controller.addNode(id, label: label, color: color);
          return true;
        }

        case 'SET_LABEL': {
          final id = args['id'];
          final label = args['label'];
          if (id == null || label == null) return false;
          controller.setNodeLabel(id, label);
          return true;
        }

        case 'SET_COLOR': {
          final id = args['id'];
          final colorStr = args['color'];
          if (id == null || colorStr == null) return false;
          final color = _parseColor(colorStr);
          if (color == null) return false;
          controller.setNodeColor(id, color);
          return true;
        }

        case 'HIGHLIGHT': {
          final id = args['id'];
          if (id == null) return false;
          final on = args.containsKey('on') ? _parseBool(args['on']!) : true;
          final hcolor = args.containsKey('color') ? _parseColor(args['color']!) : null;
          controller.highlightNode(id, on: on, color: hcolor);
          return true;
        }

        case 'SET_VISIT_ORDER': {
          final id = args['id'];
          final orderStr = args['order'];
          if (id == null) return false;
          final order = orderStr == null ? null : _parseInt(orderStr);
          controller.setVisitedOrder(id, order);
          return true;
        }

        case 'ADD_EDGE': {
          final u = args['u'];
          final v = args['v'];
          if (u == null || v == null) return false;
          final directed = args.containsKey('directed') ? _parseBool(args['directed']!) : false;
          final color = args.containsKey('color') ? _parseColor(args['color']!) : null;
          final weight = args.containsKey('weight') ? _parseNum(args['weight']!) : null;
          controller.addEdge(u, v, directed: directed, color: color, weight: weight);
          return true;
        }

        case 'CLEAR_HIGHLIGHT': {
          final clearVisited = args.containsKey('clearvisited') ? _parseBool(args['clearvisited']!) : false;
          controller.clearHighlights(clearVisitedOrder: clearVisited);
          return true;
        }

        case 'LAYOUT': {
          // 这里仅记录意图；布局实际由 GraphCanvas 的构造参数决定。
          // 你可以在控制器里加个状态，再让 GraphCanvas 监听控制器切换布局。
          // 先吞掉命令，避免报错。
          return true;
        }

        default:
          log('Unknown command: $cmd');
          return false;
      }
    } catch (e) {
      log('Error "$e" on: $line');
      return false;
    }
  }
}
