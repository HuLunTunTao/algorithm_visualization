class _Node //节点类
{
  final String name;
  final int value;
  _Node(String name1, int value1) //构造函数
      : this.name = name1,
        this.value = value1;

}

class Graph<T>{
  late final int _n; //节点数
  late final List<List<int>> _g; //邻接表
  late final List<_Node>_nodes; //节点信息

  int get count=>_n;

  Graph(int n1) //构造函数
  {
    _n=n1;
    _g = List.generate(_n, (_) => List.filled(_n, 0)); 
    _nodes=[];
  }

  void addNode(_Node node)
  {
    _nodes.add(node);
  }

  void addEdge(int i, int j,int wei)
  {
    _g[i][j]=wei;
  }

  void bulidgra()
  {
    final _gra=Graph(4);

    _gra.addNode(_Node('数据结构',10));   //方便点，直接调用构造函数来创建节点，之后马上丢到节点列表
    _gra.addNode(_Node('冒泡排序',20));
    _gra.addNode(_Node('树结构',30));
    _gra.addNode(_Node('图结构',40));


    _gra.addEdge(0, 1, 1);
    _gra.addEdge(0, 2, 1);
    _gra.addEdge(1, 3, 1);
    _gra.addEdge(2, 1, 1);
    _gra.addEdge(3, 2, 1);
  }
}