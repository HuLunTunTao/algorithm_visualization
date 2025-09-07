import '../lib/algo/afterknowledge.dart';
import '../lib/struct/my_queue.dart';
import '../lib/model/KnowledgePoint.dart'; // 导入新文件

void main() {
  // 定义你要查询的知识点名称
  const targetKnowledgePointName = '递归';

  // 调用函数获取所有后续知识点
  print("正在为知识点 '$targetKnowledgePointName' 查找所有后续知识点...");
  final descendantsQueue = findDescendants(targetKnowledgePointName);

  if (descendantsQueue.isEmpty()) {
    print("找不到后续知识点或该知识点不存在。");
  } else {
    print("\n找到以下后续知识点，并已放入队列：");
    while (!descendantsQueue.isEmpty()) {
      final kp = descendantsQueue.dequeue();
      print("  - ${kp!.name} (难度: ${kp.difficulty}, 学习时间: ${kp.studyTime}分钟)");
    }
  }
}