import '../algo/tree_kmp.dart';
import '../model/KnowledgePoint.dart';

// 专用于 KnowledgePoint 的模糊匹配器
class FuzzyMatcher 
{
  /// - [items]: 待搜索的 KnowledgePoint 列表。
  /// - [keyword]: 模糊匹配的关键词。
  static List<KnowledgePoint> search(List<KnowledgePoint> items, String keyword) 
  {
    final List<KnowledgePoint> matchedItems = [];
    for (final item in items) 
    {
      // 直接访问 KnowledgePoint 的 name 属性进行匹配
      if (kmp(item.name, keyword) != -1) 
      {
        matchedItems.add(item);
      }
    }
    return matchedItems;
  }
}