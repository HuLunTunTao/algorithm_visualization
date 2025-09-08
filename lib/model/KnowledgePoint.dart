import '../struct/my_graph.dart';

class KnowledgePoint {
  final String name; // 知识点名称（中文字符串，同时作为唯一标识）
  final List<String> prerequisites; // 前置知识点列表（存储知识点名称）
  final int difficulty; // 知识点难度（1-10之间的整数）
  final int studyTime; // 预计学习时间（分钟）
  int _learnedCount=0; //该知识点已学次数


  int get learnedCount=>_learnedCount;
  void incrementedLearnCount(){
    _learnedCount+=1;
  }
  void resetLearnCount(){
    _learnedCount=0;
  }


  KnowledgePoint({
    required this.name,
    required this.prerequisites,
    required this.difficulty,
    required this.studyTime,
  });

  // 工厂构造函数，用于从Map创建对象
  factory KnowledgePoint.fromMap(Map<String, dynamic> map) {
    return KnowledgePoint(
      name: map['name'] as String,
      prerequisites: List<String>.from(map['prerequisites'] as List),
      difficulty: map['difficulty'] as int,
      studyTime: map['studyTime'] as int,
    );
  }

  // 转换为Map，便于序列化
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'prerequisites': prerequisites,
      'difficulty': difficulty,
      'studyTime': studyTime,
    };
  }

  // 检查是否有前置知识点
  bool hasPrerequisites() {
    return prerequisites.isNotEmpty;
  }

  // 检查指定知识点是否为前置条件
  bool isPrerequisite(String knowledgeName) {
    return prerequisites.contains(knowledgeName);
  }

  // 获取前置知识点数量
  int get prerequisiteCount => prerequisites.length;

  @override
  String toString() {
    return 'KnowledgePoint(name: $name, prerequisites: $prerequisites, difficulty: $difficulty, studyTime: $studyTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KnowledgePoint && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}

// 知识点数据管理类
class KnowledgePointRepository {
  static final List<KnowledgePoint> _allKnowledgePoints = [
    // 绝对基础（必须首先掌握）
    KnowledgePoint(
      name: '时间复杂度',
      prerequisites: [],
      difficulty: 1,
      studyTime: 30,
    ),

    KnowledgePoint(
      name: '空间复杂度',
      prerequisites: ['时间复杂度'],
      difficulty: 1,
      studyTime: 20,
    ),

    KnowledgePoint(
      name: '数组',
      prerequisites: ['空间复杂度'],
      difficulty: 2,
      studyTime: 20,
    ),

    // 基础数据结构（有一定顺序，但可部分并行）
    KnowledgePoint(
      name: '链表',
      prerequisites: ['数组'],
      difficulty: 2,
      studyTime: 45,
    ),

    KnowledgePoint(
      name: '栈',
      prerequisites: ['链表'],
      difficulty: 2,
      studyTime: 30,
    ),

    KnowledgePoint(
      name: '队列',
      prerequisites: ['链表'],
      difficulty: 2,
      studyTime: 30,
    ),

    KnowledgePoint(
      name: '递归',
      prerequisites: ['栈'],
      difficulty: 3,
      studyTime: 45,
    ),

    // 基础搜索算法
    KnowledgePoint(
      name: '线性搜索',
      prerequisites: ['数组'],
      difficulty: 2,
      studyTime: 15,
    ),

    KnowledgePoint(
      name: '二分搜索',
      prerequisites: ['线性搜索'],
      difficulty: 3,
      studyTime: 25,
    ),

    // 基础排序算法（可并行学习）
    KnowledgePoint(
      name: '冒泡排序',
      prerequisites: ['数组'],
      difficulty: 2,
      studyTime: 20,
    ),

    KnowledgePoint(
      name: '插入排序',
      prerequisites: ['数组'],
      difficulty: 3,
      studyTime: 25,
    ),

    KnowledgePoint(
      name: '选择排序',
      prerequisites: ['数组'],
      difficulty: 3,
      studyTime: 25,
    ),

    // 哈希表（重要基础结构）
    KnowledgePoint(
      name: '哈希表',
      prerequisites: ['链表'],
      difficulty: 4,
      studyTime: 50,
    ),

    // 树基础（需要递归基础）
    KnowledgePoint(
      name: '二叉树',
      prerequisites: ['递归'],
      difficulty: 4,
      studyTime: 40,
    ),

    KnowledgePoint(
      name: '二叉搜索树',
      prerequisites: ['二叉树'],
      difficulty: 5,
      studyTime: 45,
    ),

    KnowledgePoint(
      name: '堆',
      prerequisites: ['二叉搜索树'],
      difficulty: 5,
      studyTime: 55,
    ),

    // 高级排序（需要相应数据结构）
    KnowledgePoint(
      name: '归并排序',
      prerequisites: ['递归'],
      difficulty: 4,
      studyTime: 45,
    ),

    KnowledgePoint(
      name: '快速排序',
      prerequisites: ['递归'],
      difficulty: 5,
      studyTime: 55,
    ),

    KnowledgePoint(
      name: '堆排序',
      prerequisites: ['堆'],
      difficulty: 6,
      studyTime: 60,
    ),

    // 队列应用
    KnowledgePoint(
      name: '优先队列',
      prerequisites: ['堆'],
      difficulty: 5,
      studyTime: 40,
    ),

    // 算法策略（需要足够基础）
    KnowledgePoint(
      name: '分治算法',
      prerequisites: ['递归', '归并排序', '快速排序'],
      difficulty: 5,
      studyTime: 55,
    ),

    KnowledgePoint(
      name: '贪心算法',
      prerequisites: ['哈希表', '冒泡排序', '插入排序', '选择排序'],
      difficulty: 5,
      studyTime: 50,
    ),

    KnowledgePoint(
      name: '动态规划',
      prerequisites: ['二叉搜索树', '归并排序', '快速排序', '贪心算法'],
      difficulty: 7,
      studyTime: 80,
    ),

    KnowledgePoint(
      name: '回溯算法',
      prerequisites: ['栈', '队列', '递归'],
      difficulty: 6,
      studyTime: 60,
    ),

    // 图数据结构
    KnowledgePoint(
      name: '图',
      prerequisites: ['队列', '哈希表'],
      difficulty: 6,
      studyTime: 60,
    ),

    KnowledgePoint(
      name: '图的表示',
      prerequisites: ['图'],
      difficulty: 5,
      studyTime: 35,
    ),

    // 图算法
    KnowledgePoint(
      name: 'BFS',
      prerequisites: ['图的表示'],
      difficulty: 6,
      studyTime: 40,
    ),

    KnowledgePoint(
      name: 'DFS',
      prerequisites: ['图的表示'],
      difficulty: 6,
      studyTime: 40,
    ),

    KnowledgePoint(
      name: '最短路径',
      prerequisites: ['BFS', 'DFS'],
      difficulty: 7,
      studyTime: 70,
    ),

    KnowledgePoint(
      name: '最小生成树',
      prerequisites: ['BFS', 'DFS'],
      difficulty: 7,
      studyTime: 60,
    ),

    KnowledgePoint(
      name: '拓扑排序',
      prerequisites: ['BFS'],
      difficulty: 6,
      studyTime: 45,
    ),

    // 高级树结构
    KnowledgePoint(
      name: 'AVL树',
      prerequisites: ['二叉搜索树'],
      difficulty: 8,
      studyTime: 80,
    ),

    KnowledgePoint(
      name: '红黑树',
      prerequisites: ['二叉搜索树'],
      difficulty: 9,
      studyTime: 100,
    ),

    KnowledgePoint(
      name: 'B树',
      prerequisites: ['AVL树'],
      difficulty: 8,
      studyTime: 80,
    ),

    KnowledgePoint(
      name: 'Trie树',
      prerequisites: ['二叉树'],
      difficulty: 6,
      studyTime: 45,
    ),

    // 字符串算法
    KnowledgePoint(
      name: 'KMP算法',
      prerequisites: ['Trie树', '二分搜索'],
      difficulty: 8,
      studyTime: 70,
    ),

    KnowledgePoint(
      name: 'Boyer-Moore',
      prerequisites: ['二分搜索'],
      difficulty: 7,
      studyTime: 60,
    ),

    KnowledgePoint(
      name: 'Rabin-Karp',
      prerequisites: ['哈希表'],
      difficulty: 7,
      studyTime: 55,
    ),

    // 高级算法
    KnowledgePoint(
      name: '强连通分量',
      prerequisites: ['DFS'],
      difficulty: 8,
      studyTime: 55,
    ),

    KnowledgePoint(
      name: '网络流',
      prerequisites: ['图的表示', '最短路径'],
      difficulty: 9,
      studyTime: 80,
    ),

    KnowledgePoint(
      name: 'AC自动机',
      prerequisites: ['Trie树'],
      difficulty: 9,
      studyTime: 80,
    ),
  ];

  // 获取所有知识点
  static List<KnowledgePoint> getAllKnowledgePoints() {
    return List.unmodifiable(_allKnowledgePoints);
  }

  // 根据名称获取知识点
  static KnowledgePoint? getKnowledgePointByName(String name) {
    try {
      return _allKnowledgePoints.firstWhere((kp) => kp.name == name);
    } catch (e) {
      return null;
    }
  }

  // 获取入门级知识点（无前置条件）
  static List<KnowledgePoint> getEntryLevelKnowledgePoints() {
    return _allKnowledgePoints.where((kp) => kp.prerequisites.isEmpty).toList();
  }

  // 获取指定知识点的所有前置条件
  static List<KnowledgePoint> getPrerequisites(String knowledgePointName) {
    final kp = getKnowledgePointByName(knowledgePointName);
    if (kp == null) return [];

    return kp.prerequisites
        .map((name) => getKnowledgePointByName(name))
        .where((prerequisite) => prerequisite != null)
        .cast<KnowledgePoint>()
        .toList();
  }

  // 获取依赖于指定知识点的所有知识点
  static List<KnowledgePoint> getDependentKnowledgePoints(String knowledgePointName) {
    return _allKnowledgePoints
        .where((kp) => kp.prerequisites.contains(knowledgePointName))
        .toList();
  }

  // 验证知识图的完整性（检查依赖关系是否都存在）
  static bool validateDependencies() {
    for (final kp in _allKnowledgePoints) {
      for (final prereq in kp.prerequisites) {
        if (getKnowledgePointByName(prereq) == null) {
          print('错误：知识点 "${kp.name}" 的前置条件 "$prereq" 不存在');
          return false;
        }
      }
    }
    return true;
  }

  // 获取学习路径（拓扑排序）
  static List<KnowledgePoint> getOptimalLearningPath() {
    final result = <KnowledgePoint>[];
    final completed = <String>{};
    final remaining = Map<String, KnowledgePoint>.fromEntries(
        _allKnowledgePoints.map((kp) => MapEntry(kp.name, kp))
    );

    while (remaining.isNotEmpty) {
      // 找到所有可学习的知识点（前置条件都已完成）
      final available = remaining.values
          .where((kp) => kp.prerequisites.every((prereq) => completed.contains(prereq)))
          .toList();

      if (available.isEmpty) {
        print('警告：检测到循环依赖，剩余知识点无法学习');
        break;
      }

      // 按难度和学习时间排序，优先选择简单的
      available.sort((a, b) {
        final diffCompare = a.difficulty.compareTo(b.difficulty);
        if (diffCompare != 0) return diffCompare;
        return a.studyTime.compareTo(b.studyTime);
      });

      final next = available.first;
      result.add(next);
      completed.add(next.name);
      remaining.remove(next.name);
    }

    return result;
  }

  // 计算总学习时间
  static int getTotalStudyTime() {
    return _allKnowledgePoints
        .map((kp) => kp.studyTime)
        .reduce((a, b) => a + b);
  }

  // 按难度分组获取知识点
  static Map<int, List<KnowledgePoint>> getKnowledgePointsByDifficulty() {
    final result = <int, List<KnowledgePoint>>{};
    for (final kp in _allKnowledgePoints) {
      result.putIfAbsent(kp.difficulty, () => []).add(kp);
    }
    return result;
  }
}
