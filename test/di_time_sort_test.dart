import '../lib/algo/sort.dart';
import '../lib/model/KnowledgePoint.dart';
import '../lib/struct/my_queue.dart';

void main() {
  // 获取一个可修改的知识点列表副本
  final knowledgePoints = List<KnowledgePoint>.from(KnowledgePointRepository.getAllKnowledgePoints());

  // 示例：调用按难度排序的方法
  SortAlgo.sortByDifficulty(knowledgePoints);
  print("按难度排序后的列表:");
  knowledgePoints.forEach((kp) {
    print("  - ${kp.name}, 难度: ${kp.difficulty}");
  });

  // 示例：获取新列表，并调用按学习时间排序的方法
  final knowledgePoints2 = List<KnowledgePoint>.from(KnowledgePointRepository.getAllKnowledgePoints());
  SortAlgo.sortByStudyTime(knowledgePoints2);
  print("\n按学习时间排序后的列表:");
  knowledgePoints2.forEach((kp) {
    print("  - ${kp.name}, 学习时间: ${kp.studyTime}");
  });

  // 示例：获取新列表，并调用按难度和学习时间排序的方法
  final knowledgePoints3 = List<KnowledgePoint>.from(KnowledgePointRepository.getAllKnowledgePoints());
  SortAlgo.sortByDifficultyAndTime(knowledgePoints3);
  print("\n先按难度再按学习时间排序后的列表:");
  knowledgePoints3.forEach((kp) {
    print("  - ${kp.name}, 难度: ${kp.difficulty}, 学习时间: ${kp.studyTime}");
  });
}