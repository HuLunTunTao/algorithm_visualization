import '../lib/model/KnowledgePoint.dart';
import '../lib/algo/mohu_final.dart';

void main() {
  print('=== 模糊搜索功能测试 ===\n');

  final allKnowledgePoints = KnowledgePointRepository.getAllKnowledgePoints();

  // 基础功能测试
  _testBasicFunctionality(allKnowledgePoints);

  // 不同匹配类型测试
  _testMatchTypes(allKnowledgePoints);

  // 边界情况测试
  _testEdgeCases(allKnowledgePoints);

  // 显示统计信息
  FinalFuzzyMatcher.getStats().printStats();
}

void _testBasicFunctionality(List<KnowledgePoint> allKnowledgePoints) {
  print('--- 基础功能测试 ---');

  final testCases = ['树', '排序', '算法', 'DFS', '图'];

  for (final keyword in testCases) {
    print('\n搜索关键词: "$keyword"');
    final results = FinalFuzzyMatcher.search(allKnowledgePoints, keyword);

    print('找到 ${results.length} 个结果:');
    for (int i = 0; i < results.length.clamp(0, 5); i++) {
      final result = results[i];
      print('  ${i+1}. ${result.knowledgePoint.name} '
          '(评分: ${result.relevanceScore.toStringAsFixed(1)}, '
          '类型: ${result.matchType})');
    }
  }
}

void _testMatchTypes(List<KnowledgePoint> allKnowledgePoints) {
  print('\n\n--- 匹配类型测试 ---');

  print('\n测试精确匹配:');
  var results = FinalFuzzyMatcher.search(allKnowledgePoints, 'DFS');
  _printTopResults(results, 3);

  print('\n测试前缀匹配:');
  results = FinalFuzzyMatcher.search(allKnowledgePoints, '二叉');
  _printTopResults(results, 3);

  print('\n测试包含匹配:');
  results = FinalFuzzyMatcher.search(allKnowledgePoints, '排序');
  _printTopResults(results, 5);

  print('\n测试模糊匹配:');
  results = FinalFuzzyMatcher.search(allKnowledgePoints, '搜寻');
  _printTopResults(results, 3);
}

void _testEdgeCases(List<KnowledgePoint> allKnowledgePoints) {
  print('\n\n--- 边界情况测试 ---');

  final edgeCases = [
    '',           // 空字符串
    'x',          // 单字符
    '不存在的算法',  // 不存在内容
    '二叉搜索树',   // 完全匹配
  ];

  for (final keyword in edgeCases) {
    print('\n测试: "$keyword"');
    try {
      final results = FinalFuzzyMatcher.search(allKnowledgePoints, keyword);
      print('  结果数量: ${results.length}');
      if (results.isNotEmpty) {
        print('  最佳匹配: ${results.first.knowledgePoint.name} '
            '(${results.first.relevanceScore.toStringAsFixed(1)})');
      }
    } catch (e) {
      print('  发生错误: $e');
    }
  }
}

void _printTopResults(List<SearchResult> results, int count) {
  for (int i = 0; i < results.length.clamp(0, count); i++) {
    final result = results[i];
    print('  - ${result.knowledgePoint.name} '
        '(${result.relevanceScore.toStringAsFixed(1)}, ${result.matchType})');
  }
}
