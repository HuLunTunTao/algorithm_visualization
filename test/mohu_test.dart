import '../lib/model/KnowledgePoint.dart'; 
import '../lib/algo/mohu.dart';

void main() {
  // 获取所有知识点，作为待搜索的列表
  final allKnowledgePoints = KnowledgePointRepository.getAllKnowledgePoints();

  // 示例一：搜索 '树'
  final keyword1 = '树';
  print('--- 正在搜索包含关键词 "$keyword1" 的知识点 ---');
  // 直接调用，不再需要显式泛型类型
  final result1 = FuzzyMatcher.search(allKnowledgePoints, keyword1);
  if (result1.isNotEmpty) {
    print('找到以下匹配的知识点:');
    for (final kp in result1) {
      print('  - ${kp.name}');
    }
  } else {
    print('没有找到匹配的知识点。');
  }

  print('\n');

  // 示例二：搜索 '排序'
  final keyword2 = '排序';
  print('--- 正在搜索包含关键词 "$keyword2" 的知识点 ---');
  // 直接调用
  final result2 = FuzzyMatcher.search(allKnowledgePoints, keyword2);
  if (result2.isNotEmpty) {
    print('找到以下匹配的知识点:');
    for (final kp in result2) {
      print('  - ${kp.name}');
    }
  } else {
    print('没有找到匹配的知识点。');
  }
}