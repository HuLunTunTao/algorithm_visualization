import 'dart:math';

import '../my_queue.dart';

void main() {
  print("=== 队列测试开始 ===");
  var random = Random();
  final maxRandomInt = 100;

  MyQueue<int> queue = MyQueue<int>();

  print("测试入队");
  for (int i = 0; i < 5; i++) {
    int numToEnqueue = random.nextInt(maxRandomInt);
    print("入队数字：$numToEnqueue");
    queue.enqueue(numToEnqueue);
    queue.printAll();
    print("队列长度：${queue.length}");
    print("队首元素：${queue.getFront()}");
    print("队尾元素：${queue.getRear()}");
    print("---");
  }

  print("测试peek操作");
  print("peek结果：${queue.peek()}");
  print("队列未改变：");
  queue.printAll();
  print("队列长度：${queue.length}");

  print("测试出队");
  while (!queue.isEmpty()) {
    print("出队元素：${queue.dequeue()}");
    queue.printAll();
    print("队列长度：${queue.length}");
    if (!queue.isEmpty()) {
      print("队首元素：${queue.getFront()}");
      print("队尾元素：${queue.getRear()}");
    }
    print("---");
  }

  print("测试空队列操作");
  print("空队列出队：${queue.dequeue()}");
  print("空队列peek：${queue.peek()}");
  print("空队列队首：${queue.getFront()}");
  print("空队列队尾：${queue.getRear()}");

  print("重新入队测试");
  for (int i = 1; i <= 3; i++) {
    queue.enqueue(i * 10);
  }
  queue.printAll();
  print("队列长度：${queue.length}");

  print("转换为列表测试");
  List<int> queueList = queue.toList();
  print("队列转换为列表：$queueList");

  print("部分出队测试");
  queue.dequeue();
  queue.printAll();
  print("队列长度：${queue.length}");

  queue.enqueue(99);
  queue.printAll();
  print("队列长度：${queue.length}");

  print("清空队列测试");
  queue.clear();
  queue.printAll();
  print("队列长度：${queue.length}");

  print("清空后再次操作测试");
  queue.enqueue(1);
  queue.enqueue(2);
  queue.printAll();
  print("队列长度：${queue.length}");
  
  print("=== 队列测试结束 ===");
}
