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

  void _showProblem(String name) {
    setState(() {
      problemName = name;
      view = MainView.problem;
    });
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

    final table = recs.isEmpty
        ? const Center(child: Text('暂无推荐路径'))
        : DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.blueAccent),
            headingTextStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
            dataRowColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return Colors.lightGreenAccent.withOpacity(0.3);
              }
              return Colors.blue.shade50;
            }),
            columns: const [
              DataColumn(label: Text('方案')),
              DataColumn(label: Text('学习路径')),
              DataColumn(label: Text('步骤')),
              DataColumn(label: Text('总难度')),
              DataColumn(label: Text('学习时间')),
              DataColumn(label: Text('相似度')),
              DataColumn(label: Text('综合评分')),
            ],
            rows: List.generate(recs.length, (i) {
              final r = recs[i];
              final kp = r['solution_knowledge'] as KnowledgePoint;
              final path = (r['path'] as List<KnowledgePoint>)
                  .map((e) => e.name)
                  .join(' → ');
              return DataRow(
                selected: i == 0,
                cells: [
                  DataCell(Text(kp.name)),
                  DataCell(Text(path)),
                  DataCell(Text('${r['steps_count']}')),
                  DataCell(Text('${r['total_difficulty']}')),
                  DataCell(Text('${r['total_study_time']}')),
                  DataCell(Text('${r['similarity_score']}')),
                  DataCell(Text(r['total_score'].toStringAsFixed(2))),
                ],
              );
            }),
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
                defaultNodeSize: const Size(160, 80),
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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: table,
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
        return GraphCanvas(
          controller: ctrl,
          layoutType: LayoutType.fruchterman,
          orientation: BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT,
          canvasMinSize: const Size(5000, 5000),
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
        title: const Text('算法可视化学习平台',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blueAccent,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      style: _btnStyle,
                      onPressed: () async {
                        await LearningStorage.increment(sel);
                        setState(() {});
                        _toast('已增加学习次数');
                      },
                      child: const Text('学习次数+1'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: _btnStyle,
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
                      child: Text(view == MainView.article ? '返回图谱' : '查看文档'),
                    ),
                    const SizedBox(width: 8),
                    // ElevatedButton(
                    //   style: _btnStyle,
                    //   onPressed: () => _markLearned(sel),
                    //   child: const Text('已学习'),
                    // ),
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
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('学习路径规划',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Autocomplete<String>(
                      optionsBuilder: (value) {
                        if (value.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        // 优化为模糊搜索
                        return FinalFuzzyMatcher.search(
                                KnowledgePointRepository.getAllKnowledgePoints(),
                                value.text)
                            .map((e) => e.knowledgePoint.name);
                      },
                      onSelected: (selection) => targetCtrl.text = selection,
                      fieldViewBuilder:
                          (context, controller, focusNode, onEditingComplete) {
                        controller.text = targetCtrl.text;
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          onEditingComplete: onEditingComplete,
                          decoration:
                              const InputDecoration(labelText: '目标知识点'),
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
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('当前学习路径',
                            style:
                                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('问题查询'),
                  Autocomplete<String>(
                    optionsBuilder: (value) {
                      if (value.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return algorithmProblems
                          .map((e) => e.name)
                          .where((name) => kmp(name, value.text) != -1);
                    },
                    onSelected: (selection) {
                      problemCtrl.text = selection;
                      _showProblem(selection);
                    },
                    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                      controller.text = problemCtrl.text;
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onEditingComplete: onEditingComplete,
                        decoration: const InputDecoration(labelText: '问题'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                children: _learnedNames()
                    .map((e) => Chip(label: Text(e), backgroundColor: Colors.greenAccent))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
