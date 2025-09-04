import 'dart:io';

// 导入外部的 KMP 算法，假设存在
import '../algo/tree_kmp.dart'; 

// 定义红黑树节点的颜色
enum _NodeColor { red, black }



class _RBNode<T> {
  String name;
  T? value; // 将 value 改为可空类型
  _RBNode<T>? parent;
  _RBNode<T>? _left;
  _RBNode<T>? _right;
  _NodeColor color;

  _RBNode(String name, this.value, _RBNode<T>? parent, _NodeColor color)
      : this.name = name,
        this.parent = parent,
        this._left = null,
        this._right = null,
        this.color = color;
}



// 外部类，提供一个公共接口，隐藏内部实现
class MyRedBlackTree<T> {
  _RBNode<T>? _root;
  // _nil 节点的 value 传入 null，符合空安全
  final _RBNode<T> _nil = _RBNode<T>("nil", null, null, _NodeColor.black);

  MyRedBlackTree() {
    _root = _nil;
  }

  _RBNode<T>? get root => _root;

  // 插入节点
  void insert(String name, T value) {
    final newNode = _RBNode<T>(name, value, null, _NodeColor.red);
    _RBNode<T>? y = null;
    _RBNode<T>? x = _root;

    while (x != _nil) {
      y = x;
      if (name.compareTo(x!.name) < 0) {
        x = x._left;
      } else {
        x = x._right;
      }
    }

    newNode.parent = y;
    if (y == null) {
      _root = newNode;
    } else if (name.compareTo(y!.name) < 0) {
      y._left = newNode;
    } else {
      y._right = newNode;
    }
    
    newNode._left = _nil;
    newNode._right = _nil;
    
    _insertFixup(newNode);
  }

  void _insertFixup(_RBNode<T> z) {
    while (z.parent != null && z.parent!.color == _NodeColor.red) {
      _RBNode<T> y;
      if (z.parent == z.parent!.parent!._left) {
        y = z.parent!.parent!._right!;
        if (y.color == _NodeColor.red) {
          z.parent!.color = _NodeColor.black;
          y.color = _NodeColor.black;
          z.parent!.parent!.color = _NodeColor.red;
          z = z.parent!.parent!;
        } else {
          if (z == z.parent!._right) {
            z = z.parent!;
            _leftRotate(z);
          }
          z.parent!.color = _NodeColor.black;
          z.parent!.parent!.color = _NodeColor.red;
          _rightRotate(z.parent!.parent!);
        }
      } else {
        y = z.parent!.parent!._left!;
        if (y.color == _NodeColor.red) {
          z.parent!.color = _NodeColor.black;
          y.color = _NodeColor.black;
          z.parent!.parent!.color = _NodeColor.red;
          z = z.parent!.parent!;
        } else {
          if (z == z.parent!._left) {
            z = z.parent!;
            _rightRotate(z);
          }
          z.parent!.color = _NodeColor.black;
          z.parent!.parent!.color = _NodeColor.red;
          _leftRotate(z.parent!.parent!);
        }
      }
    }
    _root!.color = _NodeColor.black;
  }

  void _leftRotate(_RBNode<T> x) {
    _RBNode<T> y = x._right!;
    x._right = y._left;
    if (y._left != _nil) {
      y._left!.parent = x;
    }
    y.parent = x.parent;
    if (x.parent == null) {
      _root = y;
    } else if (x == x.parent!._left) {
      x.parent!._left = y;
    } else {
      x.parent!._right = y;
    }
    y._left = x;
    x.parent = y;
  }

  void _rightRotate(_RBNode<T> y) {
    _RBNode<T> x = y._left!;
    y._left = x._right;
    if (x._right != _nil) {
      x._right!.parent = y;
    }
    x.parent = y.parent;
    if (y.parent == null) {
      _root = x;
    } else if (y == y.parent!._left) {
      y.parent!._left = x;
    } else {
      y.parent!._right = x;
    }
    x._right = y;
    y.parent = x;
  }

  // 获取节点层数
  int getNodeLevel(_RBNode<T> node) {
    int level = 0;
    _RBNode<T>? currentNode = node;
    while (currentNode?.parent != null) {
      level++;
      currentNode = currentNode!.parent;
    }
    return level;
  }

  // DFS打印函数 (中序遍历，用于二叉树)
  void dfsPrint(_RBNode<T>? node) {
    if (node == _nil) {
      return;
    }
    dfsPrint(node!._left);
    print("当前访问的结点是${node.name}, 颜色: ${node.color}");
    dfsPrint(node._right);
  }

  // DFS搜索
  // 因为 value 可能是 null，所以我们返回 T?
  T? dfsFind(_RBNode<T>? node, String sname) {
    if (node == _nil) {
      return null;
    }

    if (kmp(node!.name, sname) != -1) {
      return node.value;
    }

    // 搜索左子树
    T? result = dfsFind(node._left, sname);
    if (result != null) {
      return result;
    }

    // 搜索右子树
    result = dfsFind(node._right, sname);
    if (result != null) {
      return result;
    }

    return null;
  }
}