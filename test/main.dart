// 导入你的树结构文件
import '../lib/struct/tree.dart';

void main() {
  // 1. 创建一个 MyTree 实例
  final myTree = MyTree<String>('数据结构与算法', '数据结构与算法');

  // 2. 调用 MyTree 中的 buildTree 方法，自动构建树
  myTree.buildTree();

  // 通过 MyTree 的公共接口访问根节点
  final rootNode = myTree.root;

  // 3. 验证根节点的信息
  print('-----------------------------------------');
  print('树的根节点名称: ${rootNode.name}');
  print('根节点的层级: ${myTree.getNodeLevel(rootNode)}');
  print('-----------------------------------------');

  // 4. 验证子节点的层级
  if (rootNode.children.isNotEmpty) {
    // 获取根节点的第一个子节点（"时间复杂度"）
    final firstLevelNode = rootNode.children[0];
    print('第一个子节点名称: ${firstLevelNode.name}');
    print('第一个子节点的层级: ${myTree.getNodeLevel(firstLevelNode)}');
    
    // 访问这个子节点的子节点
    if (firstLevelNode.children.isNotEmpty) {
      // 获取 "时间复杂度" 下的第一个子节点（"空间复杂度"）
      final secondLevelNode1 = firstLevelNode.children[0];
      print('第二个子节点名称: ${secondLevelNode1.name}');
      print('第二个子节点的层级: ${myTree.getNodeLevel(secondLevelNode1)}');

      // 获取 "时间复杂度" 下的第二个子节点（"大 O 表示法"）
      final secondLevelNode2 = firstLevelNode.children[1];
      print('第三个子节点名称: ${secondLevelNode2.name}');
      print('第三个子节点的层级: ${myTree.getNodeLevel(secondLevelNode2)}');
    }
  }

  print('-----------------------------------------');
}