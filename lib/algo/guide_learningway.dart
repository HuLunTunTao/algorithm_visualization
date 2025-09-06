//由于数据结构改变，单回溯结点已不适用，改为DFS+拓扑排除
import '../struct/tree.dart';
import '../struct/my_stack.dart';

//基于DFS+栈的拓扑排序实现
void tuopu_DFS<T extends Knowledge>(
    Node<T> node,
    Set<Node<T>> visited,
    MyStack<Node<T>> pathStack)
{
  //将当前节点标记为已访问，防止重复访问
  visited.add(node);
  
  //递归访问当前节点的所有子节点
  if(node.children!=null)   //可空属性不能直接放循环，先判断吧
  {
    for (final child in node.children as List<Node<T>>) 
    {
      if (!visited.contains(child))   //如果访问节点里面还有孩子节点
      {
        tuopu_DFS(child,visited,pathStack);
      }
    }
  }

  //当一个节点的所有子节点都被访问完毕后，将该节点推入栈中
  pathStack.push(node);
}

// 规划学习路径，使用DFS拓扑排序来确保正确的学习顺序
MyStack<Node<T>>? pathPlan<T extends Knowledge>(MyTree<T> tree, String targetName) 
{
  //找到目标知识点
  final Node<T>? target=tree.dfsFind(tree.root,targetName);
  if (target==null) 
  {
    print("没找到该学习目标内容");
    return null;
  }
  
  //初始化一个集合来跟踪已访问的节点
  final visited=<Node<T>>{};
  //初始化一个栈来存储最终的学习路径
  final PathStack = MyStack<Node<T>>();
  
  //从根节点开始进行DFS拓扑排序
  //全图遍历来找目标知识点
  tuopu_DFS(tree.root as Node<T>, visited, PathStack);

  print("已找到学习目标点，并存入栈");
  return PathStack;
}