import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart' hide Node;

import '../algo/mohu_final.dart';
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
import '../struct/my_graph.dart';
import 'article_view.dart';
import 'topo_view.dart';
import 'package:toastification/toastification.dart';
import '../algo/problem_recommend.dart';

enum MainView { graph, article, topo, problem }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GraphController ctrl = GraphController();
  late final MyGraph<KnowledgePoint> tree;
  String? selected;
  final targetCtrl = TextEditingController();
  final problemCtrl = TextEditingController();
  List<String> pathResult = [];
  late MyQueue<String> queue;
  MainView view = MainView.graph;
  String? articleName;
  String? problemName;
  late final TabController _tabController;

  final ButtonStyle _btnStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.orange,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

  @override
  void initState() {
    super.initState();
    tree = buildKnowledgeTree();
    _buildGraph();
    queue = LearningStorage.getPathQueue();
    _tabController = TabController(length: 4, vsync: this);
    Article.initArticleClass(KnowledgePointRepository.getAllKnowledgePoints())
        .then((_) => Article.calculateJaccard());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('选择知识点',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 260,
          child: Text('是否将"$id"设为当前知识点?'),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
    final List<MyGraphNode<KnowledgePoint>> list = q.toList();
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
      targetCtrl.text = name;
    });
    _tabController.animateTo(0);
    _toast('已选择 $name');
  }

  void _toast(String msg, {ToastificationType type = ToastificationType.info}) {
    toastification.show(
      context: context,
      type: type,
      title: Text(msg),
      autoCloseDuration: kToastDuration,
      animationDuration: kToastDuration,
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

  Widget _buildLearnedChips() {
    final names = _learnedNames();
    if (names.isEmpty) {
      return const Text('暂无数据');
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: names
          .map((e) => Chip(
                label: Text(e),
                backgroundColor: Colors.green.shade100,
              ))
          .toList(),
    );
  }

  /// Unified card with gradient header for side panels.
  Widget _panelCard(String title, List<Color> colors, Widget child) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Text(title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: child,
          ),
        ],
      ),
    );
  }

  void _showProblem(String name) {
    setState(() {
      problemName = name;
      view = MainView.problem;
    });
  }

  void _showAllProblems() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('全部问题'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: algorithmProblems.length,
            itemBuilder: (context, index) {
              final name = algorithmProblems[index].name;
              return ListTile(
                title: Text(name),
                onTap: () {
                  Navigator.pop(context);
                  problemCtrl.text = name;
                  _showProblem(name);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _onProblemNodeTap(String id) {
    if (id == problemName) return;
    setState(() {
      selected = id;
      targetCtrl.text = id;
    });
    _tabController.animateTo(1);
    _toast('已选择 $id');
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blueGrey),
          const SizedBox(width: 4),
          Text('$label: $value'),
        ],
      ),
    );
  }

  Widget _buildProblemView() {
    if (problemName == null) {
      return const Center(child: Text('未选择问题'));
    }
    final prob = algorithmProblems.firstWhere((p) => p.name == problemName);
    final pCtrl = GraphController();
    pCtrl.addNode(prob.name, label: prob.name, color: Colors.orange);
    prob.applicableKnowledgePoints.forEach((kp, _) {
      final learned = LearningStorage.getCount(kp) > 0;
      pCtrl.addNode(kp, label: kp, color: learned ? Colors.green : Colors.blue);
      pCtrl.addEdge(prob.name, kp, directed: true);
    });

    final learned = _learnedNames();
    final recs =
        ProblemPathRecommender.recommendLearningPaths(prob.name, learned);
    recs.sort((a, b) =>
        (b['total_score'] as num).compareTo(a['total_score'] as num));

    final list = recs.isEmpty
        ? const Center(child: Text('暂无推荐路径'))
        : ListView.builder(
            itemCount: recs.length,
            itemBuilder: (context, i) {
              final r = recs[i];
              final kp = r['solution_knowledge'] as KnowledgePoint;
              final path = (r['path'] as List<KnowledgePoint>)
                  .map((e) => e.name)
                  .join(' → ');
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.indigo,
                            child: Text('${i + 1}',
                                style: const TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 8),
                          Text(kp.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _infoRow(Icons.route, '学习路径', path),
                      _infoRow(
                          Icons.looks_one, '步骤', r['steps_count'].toString()),
                      _infoRow(Icons.assessment, '总难度',
                          r['total_difficulty'].toString()),
                      _infoRow(Icons.timer, '学习时间',
                          r['total_study_time'].toString()),
                      _infoRow(Icons.link, '相似度',
                          r['similarity_score'].toString()),
                      _infoRow(Icons.star, '综合评分',
                          r['total_score'].toStringAsFixed(2)),
                    ],
                  ),
                ),
              );
            },
          );

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              GraphCanvas(
                controller: pCtrl,
                layoutType: LayoutType.fruchterman,
                orientation: BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT,
                canvasMinSize: const Size(1000, 1000),
                onNodeTap: _onProblemNodeTap,
              ),
              Positioned(
                top: 16,
                left: 16,
                child: ElevatedButton(
                  style: _btnStyle,
                  onPressed: () => setState(() => view = MainView.graph),
                  child: const Text('返回'),
                ),
              ),
            ],
          ),
        ),
        Card(
          margin: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: SizedBox(
            height: 240,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.indigo,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: const Text('推荐学习路径',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: list,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // /// Update node colors based on learned data.
  // void _refreshNodeColors() {
  //   final points = KnowledgePointRepository.getAllKnowledgePoints();
  //   for (final kp in points) {
  //     final learned = LearningStorage.getCount(kp.name) > 0;
  //     ctrl.setNodeColor(kp.name, learned ? Colors.green : Colors.blue);
  //   }
  // }
  //
  // Future<void> _clearAllData() async {
  //   await LearningStorage.clearAll();
  //   setState(() {
  //     queue = LearningStorage.getPathQueue();
  //   });
  //   _refreshNodeColors();
  //   _toast('数据已清空', type: ToastificationType.success);
  // }
  //
  // List<String> _learnedNames() {
  //   final names = KnowledgePointRepository.getAllKnowledgePoints().map((e) => e.name);
  //   return LearningStorage.getLearnedNames(names);
  // }

  Widget _buildMain() {
    switch (view) {
      case MainView.graph:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.purple.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: GraphCanvas(
            controller: ctrl,
            layoutType: LayoutType.fruchterman,
            orientation: BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT,
            canvasMinSize: const Size(5000, 5000),
            onNodeTap: _onNodeTap,
          ),
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
        return Stack(
          children: [
            TopoView(tree: tree),
            Positioned(
              top: 16,
              left: 16,
              child: ElevatedButton(
                style: _btnStyle,
                onPressed: () => setState(() => view = MainView.graph),
                child: const Text('返回'),
              ),
            ),
          ],
        );
      case MainView.problem:
        return _buildProblemView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('算法可视化学习平台',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.indigo,
      ),
      body: Row(
        children: [
          Expanded(flex: 4, child: _buildMain()),
          Expanded(flex: 2, child: _buildSide()),
        ],
      ),
    );
  }

  Widget _buildSide() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '学习'),
            Tab(text: '路径'),
            Tab(text: '工具'),
            Tab(text: '设置'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildLearningTab(),
              _buildPathTab(),
              _buildToolsTab(),
              _buildSettingsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLearningTab() {
    final sel = selected;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade50, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: _panelCard(
          '学习面板',
          [Colors.orange, Colors.pinkAccent],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('当前知识点: ${sel ?? '未选择'}'),
              if (sel != null) ...[
                const SizedBox(height: 8),
                Text('学习次数: ${LearningStorage.getCount(sel)}'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      style: _btnStyle,
                      onPressed: () async {
                        await LearningStorage.increment(sel);
                        setState(() {});
                        _toast('已增加学习次数');
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('学习次数+1'),
                    ),
                    ElevatedButton.icon(
                      style: _btnStyle,
                      onPressed: () async {
                        await LearningStorage.reset(sel);
                        setState(() {});
                        _toast('已清空学习次数');
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('清空'),
                    ),
                    ElevatedButton.icon(
                      style: _btnStyle,
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
                      icon: Icon(view == MainView.article
                          ? Icons.arrow_back
                          : Icons.menu_book_outlined),
                      label: Text(view == MainView.article ? '返回图谱' : '查看文档'),
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            _panelCard(
              '学习路径规划',
              [Colors.blue, Colors.purpleAccent],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Autocomplete<String>(
                    optionsBuilder: (value) {
                      if (value.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return FinalFuzzyMatcher.search(
                              KnowledgePointRepository.getAllKnowledgePoints(),
                              value.text)
                          .map((e) => e.knowledgePoint.name);
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
                  ElevatedButton(
                    style: _btnStyle,
                    onPressed: _planPath,
                    child: const Text('规划路径'),
                  ),
                  if (pathResult.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: pathResult
                          .map((e) => Chip(
                                label: Text(e),
                                backgroundColor: Colors.lightBlueAccent,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: _btnStyle,
                      onPressed: _updateQueue,
                      child: const Text('更新学习路径'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            _panelCard(
              '当前学习路径',
              [Colors.deepPurple, Colors.indigo],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('列表'),
                      TextButton(onPressed: _clearQueue, child: const Text('清空')),
                    ],
                  ),
                  if (queueList.isEmpty)
                    const Text('暂无规划'),
                  for (int i = 0; i < queueList.length; i++)
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.orange.shade50,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: Text('${i + 1}',
                              style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(queueList[i]),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.play_arrow, color: Colors.blue),
                              onPressed: () => _selectFromPath(queueList[i]),
                            ),
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _markLearned(queueList[i]),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade50, Colors.lightBlue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            _panelCard(
              '问题查询',
              [Colors.teal, Colors.lightBlueAccent],
              Column(
                children: [
                  Autocomplete<String>(
                    optionsBuilder: (value) {
                      if (value.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      final query = value.text;
                      final exactMatches = algorithmProblems
                          .where((p) => kmp(p.name, query) != -1)
                          .map((p) => p.name)
                          .toList();
                      final tagMatches = algorithmProblems
                          .where((p) =>
                              p.tags.any((tag) => kmp(tag, query) != -1))
                          .map((p) => p.name)
                          .where((name) => !exactMatches.contains(name))
                          .toList();
                      return [...exactMatches, ...tagMatches];
                    },
                    onSelected: (selection) {
                      problemCtrl.text = selection;
                      _showProblem(selection);
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onEditingComplete) {
                      controller.text = problemCtrl.text;
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onEditingComplete: onEditingComplete,
                        decoration: const InputDecoration(labelText: '问题'),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    title: const Text('查看全部问题'),
                    trailing: const Icon(Icons.list),
                    onTap: _showAllProblems,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _panelCard(
              '拓扑排序',
              [Colors.teal, Colors.lightBlueAccent],
              ListTile(
                title: const Text('查看拓扑图'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => setState(() => view = MainView.topo),
              ),
            ),
            const SizedBox(height: 8),
            _panelCard(
              '已学习知识点',
              [Colors.green, Colors.teal],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: _clearAllData,
                        child: const Text('清空数据')),
                  ),
                  _buildLearnedChips(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.indigo.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: _panelCard(
          '已学习知识点',
          [Colors.deepPurple, Colors.indigo],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: _clearAllData, child: const Text('清空数据')),
              ),
              _buildLearnedChips(),
            ],
          ),
        ),
      ),
    );
  }
}
