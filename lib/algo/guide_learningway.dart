//这是规划学习路径代码
import '../struct/tree.dart';
import '../struct/my_stack.dart';

MyStack<Node<T>>? pathPlan<T extends Knowledge>(MyTree<T> tree,String targetName)  //传入学习目标名字
{
  //先调用树类中的DFS来搜索这个点吧
  final Node<T>? target=tree.dfsFind(tree.root,targetName);

  if(target==null)
  {
    print("没找到该学习目标内容");
    return null;
  }

  //接着创建一个栈来接收路径上的点
  final MyStack<Node<T>> pathStack=MyStack<Node<T>>();
  //创中间点，用来当游标
  Node<T>? node=target;
  while(node!=null)
  {
    pathStack.push(node);
    node=node.parent; //上移
  }
  print("已找到学习目标点，并存入栈");
  return pathStack; //依据对接人员要求返回栈

 }