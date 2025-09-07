import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

import '../graph_viz/graph_canvas.dart';
import '../graph_viz/graph_controller.dart';
import '../model/KnowledgePoint.dart';
import '../model/AlgorithmProblem.dart';
import '../model/article.dart';
import '../utils/knowledge_utils.dart';
import '../utils/learning_storage.dart';
import '../algo/guide_learningway.dart';
import '../algo/tree_kmp.dart';
import '../struct/tree.dart';
import 'article_page.dart';
import 'topo_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GraphController ctrl = GraphController();
  late final MyTree<KnowledgePoint> tree;
  String? selected;
  final targetCtrl = TextEditingController();
  final problemCtrl = TextEditingController();
  List<String> pathResult = [];
  List<AlgorithmProblem> problemResult = [];

  @override
  void initState() {
    super.initState();
    tree = buildKnowledgeTree();
    _buildGraph();
    Article.initArticleClass(KnowledgePointRepository.getAllKnowledgePoints())
        .then((_) => Article.calculateJaccard());
  }

  void _buildGraph() {
    final points = KnowledgePointRepository.getAllKnowledgePoints();
    for (final kp in points) {
      ctrl.addNode(kp.name, label: kp.name);
    }
    for (final kp in points) {
      for (final pre in kp.prerequisites) {
        ctrl.addEdge(pre, kp.name, directed: true);
      }
    }
  }

  void _planPath() {
    final name = targetCtrl.text.trim();
    final q = pathPlan<KnowledgePoint>(tree, name);
    if (q == null) return;
    final list = q.toList().cast<Node<KnowledgePoint>>();
    final learned = <String>{};
    for (final key in LearningStorage.box.keys) {
      if (LearningStorage.getCount(key) > 0) {
        learned.add(key);
      }
    }
    int start = 0;
    for (int i = 0; i < list.length; i++) {
      if (learned.contains(list[i].value.name)) {
        start = i;
      }
    }
    setState(() {
      pathResult = list.sublist(start).map((n) => n.value.name).toList();
    });
  }

  void _searchProblem() {
    final q = problemCtrl.text.trim();
    final res = algorithmProblems
        .where((p) => kmp(p.name, q) != -1)
        .toList();
    setState(() => problemResult = res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('算法学习助手')),
      body: Row(
        children: [
          Expanded(
            flex: 4,
            child: GraphCanvas(
              controller: ctrl,
              layoutType: LayoutType.fruchterman,
              orientation: BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT,
              onNodeTap: (id) {
                setState(() {
                  selected = id;
                });
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildSide(),
          ),
        ],
      ),
    );
  }

  Widget _buildSide() {
    final sel = selected;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当前知识点: ${sel ?? '未选择'}'),
            if (sel != null) ...[
              Text('学习次数: ${LearningStorage.getCount(sel)}'),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await LearningStorage.increment(sel);
                      setState(() {});
                    },
                    child: const Text('+1'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await LearningStorage.reset(sel);
                      setState(() {});
                    },
                    child: const Text('清空'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ArticlePage(name: sel),
                    ),
                  );
                },
                child: const Text('查看文档'),
              ),
            ],
            const Divider(),
            TextField(
              controller: targetCtrl,
              decoration: const InputDecoration(labelText: '目标知识点'),
            ),
            ElevatedButton(onPressed: _planPath, child: const Text('规划路径')),
            if (pathResult.isNotEmpty) ...[
              const Text('学习路径:'),
              for (final n in pathResult) Text(n),
            ],
            const Divider(),
            TextField(
              controller: problemCtrl,
              decoration: const InputDecoration(labelText: '问题查询'),
            ),
            ElevatedButton(onPressed: _searchProblem, child: const Text('查询问题')),
            for (final p in problemResult) ListTile(title: Text(p.name)),
            const Divider(),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => TopoPage(tree: tree)),
                );
              },
              child: const Text('拓扑排序'),
            ),
          ],
        ),
      ),
    );
  }
}
