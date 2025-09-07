import '../algo/tree_kmp.dart';
import '../model/KnowledgePoint.dart';
import 'dart:math';

// 搜索结果类
class SearchResult {
  final KnowledgePoint knowledgePoint;
  final double relevanceScore;
  final String matchType;

  SearchResult(this.knowledgePoint, this.relevanceScore, this.matchType);
}

// 简单的性能统计类
class SimplePerformanceStats {
  int searchCount = 0;
  int totalMatches = 0;
  int quickMatches = 0;
  int fuzzyMatches = 0;
  int skippedItems = 0;

  void reset() {
    searchCount = 0;
    totalMatches = 0;
    quickMatches = 0;
    fuzzyMatches = 0;
    skippedItems = 0;
  }

  void printStats() {
    print('\n=== 性能统计 ===');
    print('搜索次数: $searchCount');
    print('总匹配结果: $totalMatches');
    print('快速匹配: $quickMatches, 模糊匹配: $fuzzyMatches');
    print('跳过项目: $skippedItems');
  }
}

// 最终优化版本的模糊匹配器
class FinalFuzzyMatcher {
  static final SimplePerformanceStats _stats = SimplePerformanceStats();

  // 配置参数
  static const int maxResults = 20;
  static const double minScore = 10.0;
  static const double maxLengthRatio = 2.0;

  /// 主搜索方法 - 简化优化版本
  static List<SearchResult> search(List<KnowledgePoint> items, String keyword) {
    _stats.searchCount++;

    final List<SearchResult> results = [];
    final keywordLength = keyword.length;

    for (final item in items) {
      // 优化1：长度预筛选
      if (_shouldSkipByLength(item.name, keywordLength)) {
        _stats.skippedItems++;
        continue;
      }

      // 优化2：按计算成本递增的顺序进行匹配
      final result = _performOptimizedMatch(item, keyword);
      if (result != null) {
        results.add(result);

        // 优化3：早期终止
        if (results.length >= maxResults && result.relevanceScore >= 80.0) {
          break;
        }
      }
    }

    // 排序并限制结果数量
    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    final finalResults = results.take(maxResults).toList();

    _stats.totalMatches += finalResults.length;
    return finalResults;
  }

  /// 长度预筛选
  static bool _shouldSkipByLength(String itemName, int keywordLength) {
    final itemLength = itemName.length;
    return itemLength > keywordLength * maxLengthRatio ||
        keywordLength > itemLength * maxLengthRatio;
  }

  /// 执行优化的匹配过程
  static SearchResult? _performOptimizedMatch(KnowledgePoint kp, String keyword) {
    final name = kp.name;

    // 第一步：精确匹配
    if (name == keyword) {
      _stats.quickMatches++;
      return SearchResult(kp, 100.0 * _getSimpleWeight(kp), "精确匹配");
    }

    // 第二步：前缀匹配
    if (name.startsWith(keyword)) {
      _stats.quickMatches++;
      return SearchResult(kp, 85.0 * _getSimpleWeight(kp), "前缀匹配");
    }

    // 第三步：包含匹配
    final kmpPos = kmp(name, keyword);
    if (kmpPos != -1) {
      _stats.quickMatches++;
      final weight = _getSimpleWeight(kp);
      final positionBonus = (8.0 - kmpPos.toDouble()).clamp(0.0, 8.0);
      return SearchResult(kp, (65.0 + positionBonus) * weight, "包含匹配");
    }

    // 第四步：简化的模糊匹配
    final fuzzyResult = _simpleFuzzyMatch(kp, keyword);
    if (fuzzyResult != null) {
      _stats.fuzzyMatches++;
    }
    return fuzzyResult;
  }

  /// 简化的模糊匹配
  static SearchResult? _simpleFuzzyMatch(KnowledgePoint kp, String keyword) {
    final name = kp.name;
    final similarity = _calculateSimpleSimilarity(name, keyword);

    if (similarity > 0.3) {
      final weight = _getSimpleWeight(kp);
      final score = similarity * 50.0 * weight;

      if (score >= minScore) {
        return SearchResult(kp, score, "模糊匹配");
      }
    }

    return null;
  }

  /// 简化的相似度计算
  static double _calculateSimpleSimilarity(String s1, String s2) {
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    // 字符匹配统计
    final chars1 = s1.split('');
    final chars2 = s2.split('').toList(); // 转换为可修改的列表
    int commonChars = 0;

    for (final char in chars1) {
      if (chars2.contains(char)) {
        commonChars++;
        chars2.remove(char);
      }
    }

    // 长度相似度
    final maxLen = max(s1.length, s2.length);
    final minLen = min(s1.length, s2.length);
    final lengthSimilarity = minLen / maxLen;

    // 综合相似度
    final charSimilarity = commonChars / max(s1.length, s2.length);
    return (charSimilarity * 0.7 + lengthSimilarity * 0.3);
  }

  /// 简化的权重计算
  static double _getSimpleWeight(KnowledgePoint kp) {
    double weight = 1.0;

    if (kp.prerequisites.isEmpty) weight += 0.1;
    if (kp.difficulty <= 3) weight += 0.05;
    if (kp.studyTime <= 30) weight += 0.03;
    if (kp.learnedCount > 0) weight += 0.02;

    return weight;
  }

  /// 兼容原接口
  static List<KnowledgePoint> searchSimple(List<KnowledgePoint> items, String keyword) {
    final results = search(items, keyword);
    return results.map((r) => r.knowledgePoint).toList();
  }

  /// 获取统计信息
  static SimplePerformanceStats getStats() => _stats;

  /// 重置统计信息
  static void resetStats() => _stats.reset();
}
