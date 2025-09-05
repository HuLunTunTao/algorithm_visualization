import 'dart:io';
import '../lib/struct/tree.dart';

// main 函数现在被设计为异步，以便使用 await 暂停程序等待用户输入
void main() async {
  // 1. 创建一个 MyTree 实例
  // 这里的 <dynamic> 类型让你可以存储不同类型的值
  final myTree = MyTree<dynamic>('数据结构与算法', '编程基础知识');

  // 2. 调用 buildTree 方法，自动构建树结构
  myTree.buildTree();
  final rootNode = myTree.root;

  // -------------------------------------------------------------
  // 3. 基础功能测试：DFS 遍历和层级获取
  // -------------------------------------------------------------
  print('--- 步骤三：基础功能测试 ---');
  print('开始进行深度优先遍历打印：');
  myTree.dfsPrint(rootNode);

  final firstLevelNode = rootNode.children[0];
  final secondLevelNode = firstLevelNode.children[0];

  print('\n节点层级测试：');
  print('${rootNode.name} 的层级是: ${myTree.getNodeLevel(rootNode)}');
  print('${firstLevelNode.name} 的层级是: ${myTree.getNodeLevel(firstLevelNode)}');
  print('${secondLevelNode.name} 的层级是: ${myTree.getNodeLevel(secondLevelNode)}');
  print('-------------------------------------------------------------');
  
  // -------------------------------------------------------------
  // 4. DFS 查找测试：查找用户输入的节点
  // -------------------------------------------------------------
  print('--- 步骤四：DFS 查找测试 ---');
  print('请输入你要查找的节点名称（例如：cc223d）：');
  String? sname = stdin.readLineSync();

  if (sname != null && sname.isNotEmpty) {
    // 你的 dfsFind 方法返回 int，这会导致类型转换错误，但为了保持你的代码不变，
    // 我们在此处直接调用，并捕捉可能的错误。
    // 在实际项目中，应修改 dfsFind 的返回值类型为 T?。
    try {
      final result = myTree.dfsFind(rootNode, sname);
      if (result != -1) {
        print('找到节点，其值为: $result');
      } else {
        print('未找到节点');
      }
    } catch (e) {
      print('查找出错：${e.toString()}');
      print('提示：这是因为 dfsFind 期望节点值为 int，但你的 buildTree 设置为 String。');
    }
  }
  print('-------------------------------------------------------------');

  // -------------------------------------------------------------
  // 5. 修改节点名称和值的功能测试
  // -------------------------------------------------------------
  print('--- 步骤五：修改名称和值测试 ---');
  final nodeToUpdate = rootNode.children[0]; // 选择 'ababa' 节点

  print('修改前，节点信息:');
  print('名称: ${nodeToUpdate.name}, 值: ${nodeToUpdate.value}');

  myTree.updateName(nodeToUpdate, "修改后的ababa", 9999);

  print('\n修改后，节点信息:');
  print('名称: ${nodeToUpdate.name}, 值: ${nodeToUpdate.value}');
  print('-------------------------------------------------------------');
  
  // -------------------------------------------------------------
  // 6. 删除功能测试
  // -------------------------------------------------------------
  print('--- 步骤六：删除功能测试 ---');

  // 6a. 测试保留子节点的删除 (deleteNode_withson)
  print('\n-- 测试保留子节点的删除 --');
  // 创建一个新树实例以进行测试，避免影响之前的测试结果
  final myTree_withson = MyTree<dynamic>('根节点', '初始值');
  myTree_withson.addNode('A', 1, myTree_withson.root);
  myTree_withson.addNode('B', 2, myTree_withson.root.children[0]);
  myTree_withson.addNode('C', 3, myTree_withson.root.children[0]);
  
  print('删除前，树结构：');
  myTree_withson.dfsPrint(myTree_withson.root);
  
  final nodeToDelete_withson = myTree_withson.root.children[0]; // 节点A
  myTree_withson.deleteNode_withson(nodeToDelete_withson);

  print('\n删除节点 "${nodeToDelete_withson.name}" 后，树结构：');
  myTree_withson.dfsPrint(myTree_withson.root);
  print('-------------------------------------------------------------');

  // 6b. 测试连带子节点的删除 (deleteNode_withoutson)
  print('\n-- 测试连带子节点的删除 --');
  // 创建一个新树实例以进行测试
  final myTree_withoutson = MyTree<dynamic>('根节点', '初始值');
  myTree_withoutson.addNode('D', 4, myTree_withoutson.root);
  myTree_withoutson.addNode('E', 5, myTree_withoutson.root.children[0]);
  myTree_withoutson.addNode('F', 6, myTree_withoutson.root.children[0]);
  
  print('删除前，树结构：');
  myTree_withoutson.dfsPrint(myTree_withoutson.root);

  final nodeToDelete_withoutson = myTree_withoutson.root.children[0]; // 节点D
  myTree_withoutson.deleteNode_withoutson(nodeToDelete_withoutson);

  print('\n删除节点 "${nodeToDelete_withoutson.name}" 后，树结构：');
  myTree_withoutson.dfsPrint(myTree_withoutson.root);
  print('-------------------------------------------------------------');
}