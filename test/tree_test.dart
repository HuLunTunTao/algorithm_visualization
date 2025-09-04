// 文件名: main.dart

// 1. Dart 内置库
import 'dart:io';

// 3. 本地库
import '../lib/struct/tree.dart';

void main() {
  // 1. 创建一个 MyTree 实例
  // 这里我们使用 <String> 类型，因为你的 buildTree 使用了字符串列表
  final myTree = MyTree<dynamic>('数据结构与算法', '数据结构与算法');

  // 2. 调用 buildTree 方法，自动构建树结构
  myTree.buildTree();

  // 3. 使用 DFS 遍历功能，验证树是否正确构建
  print('-----------------------------------------');
  print('开始进行深度优先遍历打印：');
  myTree.dfsPrint(myTree.root);
  print('-----------------------------------------');

  // 4. 使用 DFS 查找功能，测试查找算法是否正常工作
  print('请输入你要查找的节点名称：');
  // 从命令行读取用户输入
  String? sname = stdin.readLineSync();

  if (sname != null && sname.isNotEmpty) {
    // 调用 MyTree 实例的 dfsFind 方法进行查找
    // 注意: dfsFind 函数返回 int，但你的 buildTree 中使用了 String 作为 value。
    // 这里需要假设你的 buildTree 函数中的 value 实际上可以转换为 int 来进行测试。
    // 为了不改变你的原始代码，我将保持 int 类型，但在实际项目中需要注意类型匹配。
    final result = myTree.dfsFind(myTree.root, sname);

    if (result != -1) {
      print('找到节点，其值为: $result');
    } else {
      print('未找到节点');
    }
  }

  // 5. 测试 getNodeLevel 功能
  // 验证根节点和其子节点的层级
  final rootNode = myTree.root;
  // 这里我们不能直接访问 children[0] 因为你的 buildTree 函数只添加了一个子节点。
  // 我们需要通过你的 buildTree() 来推断节点位置。
  // 你的 buildTree 逻辑是：
  // terms[0] 是 rootNode 的子节点。
  // terms[1] 是 terms[0] 的子节点。
  // terms[2] 是 terms[0] 的子节点。

  if (rootNode.children.isNotEmpty) {
    final firstLevelNode = rootNode.children[0];
    print('-----------------------------------------');
    print('${rootNode.name} 的层级是: ${myTree.getNodeLevel(rootNode)}');
    print('${firstLevelNode.name} 的层级是: ${myTree.getNodeLevel(firstLevelNode)}');
    if (firstLevelNode.children.isNotEmpty) {
      final secondLevelNode = firstLevelNode.children[0];
      print('${secondLevelNode.name} 的层级是: ${myTree.getNodeLevel(secondLevelNode)}');
    }
    print('-----------------------------------------');
  }
}