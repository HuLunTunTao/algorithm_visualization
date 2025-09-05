import 'dart:io';
import '../algo/tree_kmp.dart';

//9.5大改进：保证封装性和解耦性，私有_Node类再定义了一个公开的对外接口Node，要不算法模块都无法调用！！
//所有函数中接收外部传入的node时都得来一个强制转换 final typeNode=node as _Node<T>  L：重构一遍所有的变量和名称很痛苦~

//子类公共暴露接口
class Knowledge {
  late String name;
  late int time;
  late double difficulty;
  Knowledge(this.name, this.time, this.difficulty);
}

//测试拟一个知识类，到时候直接调用你们的
class _KnowledgePoint extends Knowledge
{
  _KnowledgePoint(super.name,super.time,super.difficulty);
}

// Node的对外接口
abstract class Node<T extends Knowledge> 
{
  T get value;
  Node<T>? get parent;
}

//核心私有Node
class _Node<T extends Knowledge> implements Node<T> 
{
  @override
  T value;
  @override
  _Node<T>? parent;
  List<_Node<T>> children;

  _Node(this.value, this.parent)
      : this.children = [];
}

// 外部类MyTree，提供公共接口
class MyTree<T extends Knowledge> 
{
  final _Node<T> _root;

  //创建树的构造函数
  MyTree(T rootValue)
      : _root = _Node<T>(rootValue, null);

  //提供对根节点的访问
  Node<T> get root => _root;

  //添加节点函数
  Node<T> addNode(T value, Node<T> parent) 
  {
    // 将公共接口类型转换为私有实现类型
    final typedParent = parent as _Node<T>;
    final newNode = _Node<T>(value, typedParent);
    // 使用转换后的类型来操作 children
    typedParent.children.add(newNode);
    return newNode;
  }

  //获取层数的实现
  int getNodeLevel(Node<T> node) 
  {
    int ceng = 0;
    Node<T>? currentNode = node;
    while (currentNode?.parent != null) 
    {
      ceng++;
      currentNode = currentNode!.parent;
    }
    return ceng;
  }

  //DFS打印函数
  void dfsPrint(Node<T>? node) 
  {
    if (node==null) 
    {
      return;
    }
    print("当前访问的结点是${node.value.name}");
    // 把接口类型强制转换为私有类型，为了访问children
    final typedNode=node as _Node<T>;

    for (int i=0;i<typedNode.children.length;i++) 
    {
      _Node<T> child = typedNode.children[i];
      dfsPrint(child);
    }
  }

  // 连带子节点的删除
  void deleteNode_withoutson(Node<T> node) 
  {
    final typedNode = node as _Node<T>;
    if (typedNode.parent==null) 
    {
      print("目标节点为空或无法删除根节点。");
      return;
    }
    typedNode.parent!.children.remove(typedNode);
    print("节点 ${typedNode.value.name} 已删除。");
  }

  //保留子节点的删除
  void deleteNode_withson(Node<T> node) 
  {
    final typedNode = node as _Node<T>;
    if (typedNode.parent==null) 
    {
      print("目标节点为空或无法删除根节点。");
      return;
    }
    for (final elem in typedNode.children) 
    {
      elem.parent=typedNode.parent;
      typedNode.parent!.children.add(elem);
    }
    typedNode.parent!.children.remove(typedNode);
    print("保留子节点的删除已完成");
  }

  // 修改节点下的知识点名称和value
  void updateName(Node<T>? node, String newName, int newTime) 
  {
    if (node==null) {
      print("目标节点为空，无法修改");
      return;
    }
    node.value.name=newName;
    node.value.time=newTime;
    print("节点 ${node.value.name} 的name已更新为 ${newName}。");
    print("节点 ${node.value.name} 的value已更新为 ${newTime}。");
  }

  //DFS搜索
  Node<T>? dfsFind(Node<T>? node, String sname) 
  {
    final typedNode = node as _Node<T>?;
    if (typedNode==null) return null;
    if (kmp(typedNode.value.name, sname)!=-1) 
    {
      return typedNode;
    }
    for (int i=0;i<typedNode.children.length;i++) 
    {
      _Node<T> child = typedNode.children[i];
      Node<T>? result = dfsFind(child, sname);
      if (result!=null) return result;
    }
    return null;
  }
}