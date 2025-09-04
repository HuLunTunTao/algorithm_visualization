import 'dart:io';


class _Node<T> {
  String name;
  T value; 
  _Node<T>? parent;
  List<_Node<T>> children;

  _Node(String name, T value, _Node<T>? parent)   //构造函数
      : this.name = name,
        this.value = value,
        this.parent = parent,   //回指操作
        this.children = [];
}


// 外部类，提供一个公共接口，隐藏内部实现
class MyTree<T> {
  final _Node<T> _root;

  //创建树的构造函数
  MyTree(String rootName, T rootValue)
      : _root = _Node<T>(rootName, rootValue, null);
  
   _Node<T> get root => _root;  //提供对根节点的访问

  //添加节点函数
  _Node<T> addNode(String name, T value, _Node<T> parent)   //节点名字、值、父节点
  {
    final newNode=_Node<T>(name, value, parent);
    parent.children.add(newNode);
    return newNode;
  }


  // 这个函数现在可以用来构建一个预定义的树结构
  void buildTree() {
    final List<String> terms = [
      "时间复杂度", "空间复杂度", "大 O 表示法", "最好情况", "最坏情况", "平均情况", "递归",
      "分治思想", "动态规划", "贪心算法", "回溯", "暴力搜索", "数组", "链表", "单链表",
      "双向链表", "循环链表", "栈", "队列", "双端队列", "优先队列", "循环队列", "二叉树",
      "二叉搜索树", "平衡二叉树", "红黑树", "B 树", "B+ 树", "堆", "最小堆", "最大堆",
    ];

    final rootNode = _root;
    addNode(terms[0], terms[0] as T, rootNode);
    addNode(terms[1], terms[1] as T, rootNode.children[0]);
    addNode(terms[2], terms[2] as T, rootNode.children[0]);

    //后续可以添加更多节点
  }

  //获取层数的实现
  int getNodeLevel(_Node<T> node) {
    int level = 0;
    _Node<T>? currentNode = node;
    while (currentNode?.parent != null) {
      level++;
      currentNode = currentNode!.parent;
    }
    return level;
  }
}