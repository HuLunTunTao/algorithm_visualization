import 'package:flutter/material.dart';

import 'package:graphview/GraphView.dart';

import 'graph_viz/graph_canvas.dart';
import 'graph_viz/graph_controller.dart';
import 'graph_viz/command_router.dart';


void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DemoPage(),
    );
  }
}


class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final ctrl = GraphController();
  final TextEditingController textEditingController = TextEditingController();
  late final CommandRouter router;

  @override
  void initState() {
    super.initState();
    router = CommandRouter(ctrl, onLog: (m) => debugPrint(m));
    // 演示命令
    const cmds = '''
INIT
ADD_NODE id:a label:"A" color:#2196F3
ADD_NODE id:b label:"B"
ADD_NODE id:c label:"C" color:#4CAF50
ADD_EDGE u:a v:b directed:true
ADD_EDGE u:a v:c
HIGHLIGHT id:a on:true color:#FF9800
SET_VISIT_ORDER id:a order:1
''';
    router.apply(cmds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('算法可视化 – Graph Demo')),
      body: Column(
        children: [
          Expanded(
            child: GraphCanvas(
              controller: ctrl,
              layoutType: LayoutType.fruchterman,
              orientation: BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Wrap(
                  spacing: 12,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        router.apply('HIGHLIGHT id:b on:true color:#E91E63');
                      },
                      child: const Text('高亮 b'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        router.apply('CLEAR_HIGHLIGHT clearVisited:true');
                      },
                      child: const Text('清除高亮/访问序'),
                    ),
                  ],
                ),
                TextField(
                  controller: textEditingController,
                  decoration: const InputDecoration(
                    hintText: '输入命令',
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value){
                    router.apply(value);
                    textEditingController.clear();
                  },
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}