// main.dart
import 'dart:math';
import '../lib/algo/problem_recommend.dart';
import '../lib/model/KnowledgePoint.dart';

void main() {
  // 1. 准备测试数据
  final learned = ["时间复杂度", "空间复杂度"];
  final problemName = "合并K个有序链表";

  try {
    // 2. 调用核心功能函数
    final recommendations = ProblemPathRecommender.recommendLearningPaths(problemName, learned);

    // 3. 处理并打印结果
    if (recommendations.isEmpty) {
      print("没有找到可行的学习路径。");
      return;
    }

    print("为解决【$problemName】问题，以下是推荐的学习路径：\n");
    for (int i = 0; i < min(3, recommendations.length); i++) {
      final rec = recommendations[i];
      final solutionKp = rec["solution_knowledge"] as KnowledgePoint;
      final path = rec["path"] as List<KnowledgePoint>;

      print("--- 推荐 ${i + 1} ---");
      print("解决方案：${solutionKp.name}");
      if (path.isEmpty) {
        print("学习路径：该知识点已掌握，无需学习。");
      } else {
        final pathNames = path.map((kp) => kp.name).join(' -> ');
        print("学习路径：$pathNames");
      }
      print("总需学习知识点数：${rec["steps_count"]} 个");
      print("总难度：${rec["total_difficulty"]}");
      print("总学习时间：${rec["total_study_time"]} 分钟");
      print("---------------------\n");
    }
  } catch (e) {
    print("发生错误：$e");
  }
}