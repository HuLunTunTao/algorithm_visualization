import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import '../my_stack.dart';

void main(){
  final random=Random();

  final maxRandomInt=100;

  MyStack<int> stack=MyStack<int>();

  int numToInsert=random.nextInt(maxRandomInt);

  print("入栈单个元素 $numToInsert");
  stack.push(numToInsert);
  print(stack);

  print("出栈单个元素");
  stack.pop();
  print(stack);

  print("入栈15个元素");
  final List<int> listToPush=[];
  for(int i=0;i<15;i++){
    listToPush.add(random.nextInt(maxRandomInt));
    
  }
  print("插入元素为:$listToPush");
  for(int i=0;i<15;i++){
    stack.push(listToPush[i]);
  }
  print(stack);

  print("获取栈顶元素");
  print(stack);
  print(stack.top());
  stack.pop();

  print(stack);
  print(stack.top());
  stack.pop();

  print(stack);
  print(stack.top());
  stack.pop();

  test("元素测试", (){
    print("当前元素数是否为12");
    print("当前元素数 ${stack.length}");
    expect(stack.length,12);

    print("出栈直到空");
    while(!stack.isEmpty()){
      stack.pop();
    }
    expect(stack.isEmpty(),true);
    expect(stack.length, 0);
  });



}