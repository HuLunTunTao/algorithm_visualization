import 'dart:io';
import '../algo/tree_kmp.dart';

class Knowledge   //测试拟一个知识类，到时候直接调用你们的
{
  late String name;
  late int time;
  late double difficulty;
  Knowledge(this.name, this.time, this.difficulty);
}

class _Node<T> 
{
  //String name;
  T value;
  _Node<T>? parent;
  List<_Node<T>> children;

  _Node(T value, _Node<T>? parent)   //构造函数
      :
        this.value = value,
        this.parent = parent,   //回指操作
        this.children = [];
}


// 外部类，提供一个公共接口，隐藏内部实现
class MyTree<T extends Knowledge> 
{
  final _Node<T> _root;

  //创建树的构造函数
  MyTree(T rootValue)
      : _root = _Node<T>(rootValue, null);
  
   _Node<T> get root => _root;  //提供对根节点的访问

  //添加节点函数
  _Node<T> addNode(T value, _Node<T> parent)   //节点名字、值、父节点
  {
    final newNode=_Node<T>(value, parent);
    parent.children.add(newNode);
    return newNode;
  }


  // 这个函数现在可以用来构建一个预定义的树结构
  void buildTree() {
    final rootNode = _root;

    // 创建 KnowledgePoint 实例
    final knowledgePoint1 = Knowledge("ababa", 5, 0.5);
    final knowledgePoint2 = Knowledge("cc223d", 10, 0.7);
    final knowledgePoint3 = Knowledge("kksj", 20, 0.9);

    addNode(knowledgePoint1 as T, rootNode);
    addNode(knowledgePoint2 as T, rootNode.children[0]);
    addNode(knowledgePoint3 as T, rootNode.children[0]);
  }

  //获取层数的实现
  int getNodeLevel(_Node<T> node) 
  {
    int level = 0;
    _Node<T>? currentNode = node;
    while (currentNode?.parent != null) {
      level++;
      currentNode = currentNode!.parent;
    }
    return level;
  }

  //DFS打印函数
  void dfsPrint(_Node<T>? node) 
  {
    if (node == null) {
      return;
    }
    print("当前访问的结点是${node.value.name}");
    for (int i = 0; i < node.children.length; i++) {
      _Node<T> child = node.children[i];
      dfsPrint(child);
    }
  }

  // 连带子节点的删除
  void deleteNode_withoutson(_Node<T> node)
  {
    if (node==null||node.parent==null)
    {
      print("目标节点为空或未知错误，无法删除");
      return;
    }
    node.parent!.children.remove(node);   //直接删除它父亲的这个孩子，dart会自动释放删除节点的所有子节点（删一个根后面子节点全删）
    print("节点 ${node.value.name} 已删除。");
  }

  //保留子节点的删除
  void deleteNode_withson(_Node<T> node)
  {
    if(node==null||node.parent==null)
    {
      print("目标节点为空或未知错误，无法删除");
      return;
    }

    for (final elem in node.children)   //把删除节点的子节点都接上父亲
    {
      elem.parent=node.parent;
      node.parent!.children.add(elem);  
    }
    node.parent!.children.remove(node);
    print("保留子节点的删除已完成");
  }

  // 修改节点下的知识点名称和value
  void updateName(_Node<T>? node, String newName, int newTime) 
  {
      if(node==null) 
      {
        print("目标节点为空，无法修改");
        return;
      }
      node.value.name=newName;
      node.value.time=newTime;
      print("节点 ${node.value.name} 的name已更新为 ${newName}。");
      print("节点 ${node.value.name} 的value已更新为 ${newTime}。");
  }

  //DFS搜索
  _Node<T>? dfsFind(_Node<T>? node, String sname)   //引入
  {
    if (node == null) {
      return null;
    }

    if (kmp(node.value.name, sname) != -1)  //调用写好的KMP算法
    {
      return node;
    }
    
    for (int i = 0; i < node.children.length; i++) 
    {
      _Node<T> child = node.children[i];
      _Node<T>? result=dfsFind(child, sname);
      if (result !=null) 
      {
        return result;
      }
    }
    return null;
  }
}