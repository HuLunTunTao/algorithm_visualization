//由于数据结构改变，单回溯结点已不适用，改为DFS+拓扑排序
//修复bug：不需要全图遍历，把前置子图抽出即可
import '../struct/tree.dart';
import '../struct/my_stack.dart';
import '../struct/my_queue.dart';
import '../model/KnowledgePoint.dart';


void findpre<T extends KnowledgePoint>(Node<T> node,Set<Node<T>> preset)
{
  //若该节点已经在集合中或者没有父节点了(根)，停止
  if (preset.contains(node)) {
    return;
  }
  //递归至无父节点
  for(final parent in node.parents as List<Node<T>>)
  {
    findpre(parent,preset);
  }
  //该节点加入前置节点集合
  preset.add(node);
}

//基于DFS+栈的拓扑排序实现
void tuopu_DFS<T extends KnowledgePoint>(
    Node<T> node,
    Set<Node<T>> visited,
    Set<Node<T>> subNode,
    MyStack<Node<T>> pathStack)
{
  //确保仅在子图内进行排序
  if (!subNode.contains(node) || visited.contains(node)) {
    return;
  }

  //将当前节点标记为已访问，防止重复访问
  visited.add(node);
  
  //递归访问当前节点的所有子节点
  if(node.children!=null)   //可空属性不能直接放循环，先判断吧
  {
    for (final child in node.children as List<Node<T>>) 
    {
      if (subNode.contains(child)&&!visited.contains(child))   //如果访问节点里面还有孩子节点
      {
        tuopu_DFS(child,visited,subNode,pathStack);
      }
    }
  }

  //当一个节点的所有子节点都被访问完毕后，将该节点推入栈中
  pathStack.push(node);
}

// 规划学习路径，使用DFS拓扑排序来确保正确的学习顺序
MyQueue<Node<T>>? pathPlan<T extends KnowledgePoint>(MyTree<T> tree, String targetName) 
{
  //找到目标知识点
  final Node<T>? target=tree.dfsFind(tree.root,targetName);
  if (target==null) 
  {
    print("没找到该学习目标内容");
    return null;
  }

  final sonNodes=<Node<T>>{};   //初始化一个子图来接收所有必要的前置知识点
  findpre(target,sonNodes);  //从目标节点开始反向遍历
  sonNodes.add(target);   //目标节点也加入，保证完整性
  
  //初始化一个集合来跟踪已访问的节点
  final visited=<Node<T>>{};
  //初始化一个栈来存储最终的学习路径
  final PathStack = MyStack<Node<T>>();

  //由于集合的无序性，这里得用列表把装根节点，确保拓扑从根节点开始
  final roots=sonNodes.where((node)=>node.parents==null||node.parents!.isEmpty).toList();
  
  //只需遍历已建立好的前置子图
  for (final node in roots)
  {
    if(!visited.contains(node)) //如果还没遍历这个点
    {
      tuopu_DFS(node,visited,sonNodes,PathStack);
    }
  }
  print("前置知识点已入栈");

  // 直接把出栈顺序加入队列
  final lq=MyQueue<Node<T>>();
  while (!PathStack.isEmpty()) 
  {
    final node = PathStack.top();
    PathStack.pop();
    if (node != null) 
    {
      lq.enqueue(node);
    }
  }

  if (!lq.isEmpty()) 
  {
    print("已将学习路径从栈直接转移到队列。");
    print("学习路径队列：");
    lq.printAll();
  } else {
    print("学习路径队列为空。");
  }
  
  // 返回最终的队列
  return lq;

  }