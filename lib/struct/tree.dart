import 'dart:io';
import '../algo/tree_kmp.dart';
import '../model/KnowledgePoint.dart';

//9.5大改进：保证封装性和解耦性，私有_Node类再定义了一个公开的对外接口Node，要不算法模块都无法调用！！
//所有函数中接收外部传入的node时都得来一个强制转换 final typeNode=node as _Node<T>  L：重构一遍所有的变量和名称很痛苦~
//9.6大改动，由于修改了树结构，现在整体改为图实现功能

//子类,继承知识点KnowledgePoint类的属性，减少代码修改量
class Knowledge extends KnowledgePoint {
  Knowledge({
    required String name,
    required List<String> prerequisites,
    required int difficulty,
    required int studyTime,
  }) : super(
          name: name,
          prerequisites: prerequisites,
          difficulty: difficulty,
          studyTime: studyTime,
        );
}

// Node的对外接口
abstract class Node<T extends Knowledge> 
{
  //为了方便外部功能调用，全打开吧
  T get value;
  List<Node<T>>? get parents;
  List<Node<T>>? get children;
}

//核心私有Node
class _Node<T extends Knowledge> implements Node<T> 
{
  @override
  late T value;
  @override
  List<_Node<T>> children=[];
  List<_Node<T>> parents=[];  //父节点改为可以接收列表的形式，实际上已经为图

  _Node(T value, List<_Node<T>> parents)
  { 
    this.value=value;
    this.parents=parents;
    this.children=[];
  }
    
}

// 外部类MyTree，提供公共接口
class MyTree<T extends Knowledge> 
{
  final _Node<T> _root;

  //创建树的构造函数
  MyTree(T rootValue)
      : _root=_Node<T>(rootValue, []);

  //提供对根节点的访问
  Node<T> get root=>_root;

  //添加节点函数
  Node<T> addNode(T value,List<Node<T>> parents) 
  {
    //这来个Map方式把所有父列表中节点全部转换为_Node,公有转私有
    final typedParents=parents.map((p)=>p as _Node<T>).toList();
    final newNode = _Node<T>(value, typedParents);
    // 将新节点添加到每个父节点的子节点列表中
    for (final parent in typedParents) 
    {
      parent.children.add(newNode);
    }
    return newNode;
  }

  // //获取层数的实现
  // int getNodeLevel(Node<T> node) 
  // {
  //   int ceng = 0;
  //   Node<T>? currentNode = node;
  //   while (currentNode?.parent != null) 
  //   {
  //     ceng++;
  //     currentNode = currentNode!.parent;
  //   }
  //   return ceng;
  // }

  //DFS打印函数,由于是图了，引入一个集合来存储访问过的节点
  void dfsPrint(Node<T>? node,[Set<_Node<T>>? visited]) 
  {
    final typedNode=node as _Node<T>?;
    if (typedNode == null || (visited ??= <_Node<T>>{}).contains(typedNode)) 
    //结点空，终结；？？==貌似是集合为空就初始化为空，若已有值，就用现有值
    {
      return;
    }
    visited.add(typedNode);
    print("当前访问的结点是${typedNode.value.name}");
    for (int i=0; i<typedNode.children.length; i++) 
    {
      _Node<T> child=typedNode.children[i];
      dfsPrint(child, visited);
    }
  }

  // 连带子节点的删除
  void deleteNode_withoutson(Node<T> node) 
  {
    final typedNode = node as _Node<T>;
    if (typedNode.parents.isEmpty) 
    {
      print("目标节点为空或无法删除根节点。");
      return;
    }
    for (final elem in typedNode.parents)
    {
      elem.children.remove(typedNode);
    }
    print("节点 ${typedNode.value.name} 已删除。");
  }

  //保留子节点的删除
  void deleteNode_withson(Node<T> node) 
  {
    final typedNode = node as _Node<T>;
    if (typedNode.parents.isEmpty) 
    {
      print("目标节点为空或无法删除根节点。");
      return;
    }
    // 将子节点的父节点更改为被删除节点的所有父节点
    for (final child in typedNode.children) 
    {
      for (final parent in typedNode.parents) 
      {
        child.parents.add(parent);
        parent.children.add(child);
      }
    }
    // 从所有父节点的子节点列表中移除被删除的节点
    for (final parent in typedNode.parents) 
    {
      parent.children.remove(typedNode);
    }
    print("保留子节点的删除已完成");
  }

  //9.6由于知识点类中的属性都是final的，无法修改，同时硬编码写入了数据，后面有需要这个功能再说
  // // 修改节点下的知识点名称和value
  // void updateName(Node<T>? node, String newName, int newTime) 
  // {
  //   if (node==null) {
  //     print("目标节点为空，无法修改");
  //     return;
  //   }
  //   node.value.name=newName;
  //   node.value.time=newTime;
  //   print("节点 ${node.value.name} 的name已更新为 ${newName}。");
  //   print("节点 ${node.value.name} 的value已更新为 ${newTime}。");
  // }

  //DFS搜索
  Node<T>? dfsFind(Node<T>? node, String sname,[Set<_Node<T>>? visited]) 
  {
    final typedNode = node as _Node<T>?;
    if (typedNode == null || (visited ??= <_Node<T>>{}).contains(typedNode)) 
    {
      return null;
    }
    visited.add(typedNode);
    if (kmp(typedNode.value.name, sname)!=-1) 
    {
      return typedNode;
    }
    for (int i=0;i<typedNode.children.length;i++) 
    {
      _Node<T> child = typedNode.children[i];
      Node<T>? result = dfsFind(child, sname,visited);
      if (result!=null) return result;
    }
    return null;
  }
}