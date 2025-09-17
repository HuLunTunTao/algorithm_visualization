
import '../lib/model/KnowledgePoint.dart'; 
import '../lib/algo/sort.dart'; 


void main() {
  // 准备测试数据
  final List<KnowledgePoint> knowledgePoints = [
    KnowledgePoint(name: '算法基础', prerequisites: [], difficulty: 5, studyTime: 30),
    KnowledgePoint(name: '数据结构', prerequisites: [], difficulty: 3, studyTime: 45),
    KnowledgePoint(name: '操作系统', prerequisites: [], difficulty: 5, studyTime: 20),
    KnowledgePoint(name: '计算机网络', prerequisites: [], difficulty: 2, studyTime: 60),
    KnowledgePoint(name: '数据库原理', prerequisites: [], difficulty: 4, studyTime: 30),
  ];

  print('--- 原始数据 ---');
  knowledgePoints.forEach(print);
  print('-----------------');

  // 测试单纯按难度排序
  print('\n--- 按难度排序 ---');
  SortAlgo.sortByDifficulty(knowledgePoints);
  knowledgePoints.forEach(print);
  print('-----------------');

  // 恢复原始数据，进行下一个测试
  knowledgePoints.setAll(0, [
    KnowledgePoint(name: '算法基础', prerequisites: [], difficulty: 5, studyTime: 30),
    KnowledgePoint(name: '数据结构', prerequisites: [], difficulty: 3, studyTime: 45),
    KnowledgePoint(name: '操作系统', prerequisites: [], difficulty: 5, studyTime: 20),
    KnowledgePoint(name: '计算机网络', prerequisites: [], difficulty: 2, studyTime: 60),
    KnowledgePoint(name: '数据库原理', prerequisites: [], difficulty: 4, studyTime: 30),
  ]);

  // 测试单纯按学习时间排序
  print('\n--- 按学习时间排序 ---');
  SortAlgo.sortByStudyTime(knowledgePoints);
  knowledgePoints.forEach(print);
  print('-----------------');

  // 恢复原始数据，进行最后一个测试
  knowledgePoints.setAll(0, [
    KnowledgePoint(name: '算法基础', prerequisites: [], difficulty: 5, studyTime: 30),
    KnowledgePoint(name: '数据结构', prerequisites: [], difficulty: 3, studyTime: 45),
    KnowledgePoint(name: '操作系统', prerequisites: [], difficulty: 5, studyTime: 20),
    KnowledgePoint(name: '计算机网络', prerequisites: [], difficulty: 2, studyTime: 60),
    KnowledgePoint(name: '数据库原理', prerequisites: [], difficulty: 4, studyTime: 30),
  ]);

  // 测试先按难度，再按学习时间排序
  print('\n--- 先按难度，再按学习时间排序 ---');
  SortAlgo.sortByDifficultyAndTime(knowledgePoints);
  knowledgePoints.forEach(print);
  print('-----------------');
}