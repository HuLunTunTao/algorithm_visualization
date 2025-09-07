import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart' hide Node;

import '../graph_viz/graph_canvas.dart';
import '../graph_viz/graph_controller.dart';
import '../model/KnowledgePoint.dart';
import '../model/AlgorithmProblem.dart';
import '../model/article.dart';
import '../utils/knowledge_utils.dart';
import '../utils/learning_storage.dart';
import '../utils/constants.dart';
import '../algo/guide_learningway.dart';
import '../algo/tree_kmp.dart';
import '../struct/my_queue.dart';
import '../struct/tree.dart';
import 'article_view.dart';
import 'topo_view.dart';
import 'package:toastification/toastification.dart';

enum MainView { graph, article, topo }

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
  late MyQueue<String> queue;
  MainView view = MainView.graph;
  String? articleName;

  @override
  void initState() {
    super.initState();
    tree = buildKnowledgeTree();
    _buildGraph();
    queue = LearningStorage.getPathQueue();
    Article.initArticleClass(KnowledgePointRepository.getAllKnowledgePoints())
        .then((_) => Article.calculateJaccard());
  }

  void _buildGraph() {
    final points = KnowledgePointRepository.getAllKnowledgePoints();
    for (final kp in points) {
      final learned = LearningStorage.getCount(kp.name) > 0;
      ctrl.addNode(
        kp.name,
        label: kp.name,
        color: learned ? Colors.green : Colors.blue,
      );
    }
    for (final kp in points) {
      for (final pre in kp.prerequisites) {
        ctrl.addEdge(pre, kp.name, directed: true);
      }
    }
  }

  void _onNodeTap(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('选择知识点'),
        content: Text('是否将"$id"设为当前知识点?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              setState(() {
                selected = id;
              });
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _planPath() {
    final name = targetCtrl.text.trim();
    final exists = KnowledgePointRepository.getAllKnowledgePoints().any((kp) => kp.name == name);
    if (!exists) {
      _toast('请选择有效的知识点', type: ToastificationType.error);
      return;
    }
    final q = pathPlan<KnowledgePoint>(tree, name);
    if (q == null) return;
    final List<Node<KnowledgePoint>> list = q.toList();
    final List<String> res = [];
    for (final n in list) {
      if (LearningStorage.getCount(n.value.name) == 0) {
        res.add(n.value.name);
      }
    }
    setState(() {
      pathResult = res;
    });
    _toast('规划完成');
  }

  void _updateQueue() async {
    await LearningStorage.savePath(pathResult);
    setState(() {
      queue = LearningStorage.getPathQueue();
    });
    _toast('学习路径已更新', type: ToastificationType.success);
  }

  void _clearQueue() async {
    await LearningStorage.clearPath();
    setState(() {
      queue = LearningStorage.getPathQueue();
    });
    _toast('学习路径已清空');
  }

  void _markLearned(String name) async {
    await LearningStorage.increment(name);
    await LearningStorage.remove(name);
    setState(() {
      queue = LearningStorage.getPathQueue();
    });
    _refreshNodeColors();
    _toast('已学习 $name');
  }

  void _selectFromPath(String name) {
    setState(() {
      selected = name;
    });
    _toast('已选择 $name');
  }

  void _searchProblem() {
    final q = problemCtrl.text.trim();
    final res = algorithmProblems.where((p) => kmp(p.name, q) != -1).toList();
    setState(() => problemResult = res);
  }

  void _toast(String msg, {ToastificationType type = ToastificationType.info}) {
    toastification.show(
      context: context,
      type: type,
      title: Text(msg),
      autoCloseDuration: kToastDuration,
    );
  }

  /// Update node colors based on learned data.
  void _refreshNodeColors() {
    final points = KnowledgePointRepository.getAllKnowledgePoints();
    for (final kp in points) {
      final learned = LearningStorage.getCount(kp.name) > 0;
      ctrl.setNodeColor(kp.name, learned ? Colors.green : Colors.blue);
    }
  }

  Future<void> _clearAllData() async {
    await LearningStorage.clearAll();
    setState(() {
      queue = LearningStorage.getPathQueue();
    });
    _refreshNodeColors();
    _toast('数据已清空', type: ToastificationType.success);
  }

  List<String> _learnedNames() {
    final names = KnowledgePointRepository.getAllKnowledgePoints().map((e) => e.name);
    return LearningStorage.getLearnedNames(names);
  }

  Widget _buildMain() {
    switch (view) {
      case MainView.graph:
        return GraphCanvas(
          controller: ctrl,
          layoutType: LayoutType.fruchterman,
          orientation: BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT,
          canvasMinSize: const Size(2000, 2000),
          defaultNodeSize: const Size(160, 80),
          onNodeTap: _onNodeTap,
        );
      case MainView.article:
        return ArticleView(
          name: articleName ?? '',
          onSelect: (n) {
            setState(() {
              articleName = n;
              selected = n;
              view = MainView.article;
            });
          },
        );
      case MainView.topo:
        return TopoView(tree: tree);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('算法学习助手')),
      body: Row(
        children: [
          Expanded(flex: 4, child: _buildMain()),
          Expanded(flex: 1, child: _buildSide()),
        ],
      ),
    );
  }

  Widget _buildSide() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: '学习'),
              Tab(text: '路径'),
              Tab(text: '工具'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildLearningTab(),
                _buildPathTab(),
                _buildToolsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningTab() {
    final sel = selected;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
                        _toast('已增加学习次数');
                      },
                      child: const Text('+1'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await LearningStorage.reset(sel);
                        setState(() {});
                        _toast('已清空学习次数');
                      },
                      child: const Text('清空'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (view == MainView.article) {
                          setState(() => view = MainView.graph);
                        } else {
                          setState(() {
                            articleName = sel;
                            view = MainView.article;
                          });
                        }
                      },
                      child: Text(view == MainView.article ? '返回图谱' : '查看文档'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _markLearned(sel),
                      child: const Text('已学习'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPathTab() {
    final queueList = queue.toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('学习路径规划'),
                  Autocomplete<String>(
                    optionsBuilder: (value) {
                      if (value.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return KnowledgePointRepository
                          .getAllKnowledgePoints()
                          .map((e) => e.name)
                          .where((name) => kmp(name, value.text) != -1);
                    },
                    onSelected: (selection) => targetCtrl.text = selection,
                    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                      controller.text = targetCtrl.text;
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onEditingComplete: onEditingComplete,
                        decoration: const InputDecoration(labelText: '目标知识点'),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: _planPath, child: const Text('规划路径')),
                  if (pathResult.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: pathResult.map((e) => Chip(label: Text(e))).toList(),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: _updateQueue, child: const Text('更新学习路径')),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('当前学习路径'),
                      TextButton(onPressed: _clearQueue, child: const Text('清空')),
                    ],
                  ),
                  if (queueList.isEmpty)
                    const Text('暂无规划'),
                  for (int i = 0; i < queueList.length; i++)
                    ListTile(
                      title: Text(queueList[i]),
                      leading: i == 0 ? const Icon(Icons.flag) : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: () => _selectFromPath(queueList[i]),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () => _markLearned(queueList[i]),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('问题查询'),
                  TextField(
                    controller: problemCtrl,
                    decoration: const InputDecoration(labelText: '问题'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: _searchProblem, child: const Text('查询')),
                  for (final p in problemResult) ListTile(title: Text(p.name)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: const Text('拓扑排序'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => setState(() => view = MainView.topo),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('已学习知识点'),
                      TextButton(onPressed: _clearAllData, child: const Text('清空数据')),
                    ],
                  ),
                  Wrap(
                    spacing: 4,
                    children: _learnedNames().map((e) => Chip(label: Text(e))).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
