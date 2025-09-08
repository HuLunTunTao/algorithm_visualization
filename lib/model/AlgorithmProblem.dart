import '../struct/my_graph.dart';

class AlgorithmProblem {
  final String name;
  final Map<String, int> applicableKnowledgePoints;
  final String description;
  final List<String> tags;

  AlgorithmProblem({
    required this.name,
    required this.applicableKnowledgePoints,
    required this.description,
    this.tags = const [],
  });
}

List<AlgorithmProblem> algorithmProblems = [
  AlgorithmProblem(
    name: "数组排序",
    applicableKnowledgePoints: {
      "快速排序": 10,
      "归并排序": 10,
      "堆排序": 9,
      "插入排序": 6,
      "选择排序": 5,
    },
    description: "将给定数组按升序排列",
    tags: ["排序"],
  ),

  AlgorithmProblem(
    name: "寻找数组中的第K大元素",
    applicableKnowledgePoints: {
      "堆": 10,
      "快速排序": 8,
      "归并排序": 6,
    },
    description: "在无序数组中找到第K个最大的元素",
    tags: ["搜索", "排序"],
  ),

  AlgorithmProblem(
    name: "搜索旋转排序数组",
    applicableKnowledgePoints: {
      "二分搜索": 10,
      "线性搜索": 4,
    },
    description: "在旋转的有序数组中查找目标值",
    tags: ["搜索"],
  ),

  AlgorithmProblem(
    name: "合并K个有序链表",
    applicableKnowledgePoints: {
      "堆": 10,
      "分治算法": 9,
      "归并排序": 8,
    },
    description: "将K个有序链表合并成一个有序链表",
    tags: ["链表", "排序"],
  ),

  AlgorithmProblem(
    name: "寻找两个有序数组的中位数",
    applicableKnowledgePoints: {
      "二分搜索": 10,
      "归并排序": 6,
    },
    description: "找到两个有序数组合并后的中位数",
    tags: ["搜索", "数组"],
  ),

  AlgorithmProblem(
    name: "数组中的逆序对",
    applicableKnowledgePoints: {
      "归并排序": 10,
      "分治算法": 8,
    },
    description: "统计数组中逆序对的数量",
    tags: ["排序", "统计"],
  ),

  AlgorithmProblem(
    name: "最接近的三数之和",
    applicableKnowledgePoints: {
      "二分搜索": 9,
      "快速排序": 7,
      "哈希表": 5,
    },
    description: "找到三个数的和最接近目标值",
    tags: ["搜索", "数组"],
  ),

  AlgorithmProblem(
    name: "区间合并",
    applicableKnowledgePoints: {
      "贪心算法": 10,
      "快速排序": 8,
      "归并排序": 8,
    },
    description: "合并所有重叠的区间",
    tags: ["排序", "区间"],
  ),

  AlgorithmProblem(
    name: "二叉树的序列化与反序列化",
    applicableKnowledgePoints: {
      "DFS": 10,
      "BFS": 10,
      "二叉树": 8,
    },
    description: "设计算法来序列化和反序列化二叉树",
    tags: ["树", "序列化"],
  ),

  AlgorithmProblem(
    name: "岛屿数量",
    applicableKnowledgePoints: {
      "DFS": 10,
      "BFS": 10,
    },
    description: "计算二维网格中岛屿的数量",
    tags: ["图", "搜索"],
  ),

  AlgorithmProblem(
    name: "二叉树的最近公共祖先",
    applicableKnowledgePoints: {
      "DFS": 10,
      "递归": 9,
      "二叉树": 8,
    },
    description: "找到二叉树中两个节点的最近公共祖先",
    tags: ["树"],
  ),

  AlgorithmProblem(
    name: "单词搜索",
    applicableKnowledgePoints: {
      "DFS": 10,
      "回溯算法": 10,
    },
    description: "在字母矩阵中搜索单词",
    tags: ["搜索", "回溯"],
  ),

  AlgorithmProblem(
    name: "课程表问题",
    applicableKnowledgePoints: {
      "拓扑排序": 10,
      "DFS": 8,
      "BFS": 6,
    },
    description: "判断是否可以完成所有课程",
    tags: ["图", "拓扑"],
  ),

  AlgorithmProblem(
    name: "网络延迟时间",
    applicableKnowledgePoints: {
      "最短路径": 10,
      "BFS": 6,
    },
    description: "计算网络中信号传播的最短时间",
    tags: ["图", "最短路径"],
  ),

  AlgorithmProblem(
    name: "连接所有城市的最小成本",
    applicableKnowledgePoints: {
      "最小生成树": 10,
      "贪心算法": 8,
    },
    description: "计算连接所有城市的最小成本",
    tags: ["图", "贪心"],
  ),

  AlgorithmProblem(
    name: "二叉搜索树中第K小的元素",
    applicableKnowledgePoints: {
      "二叉搜索树": 10,
      "DFS": 9,
    },
    description: "找到BST中第K小的元素",
    tags: ["树", "搜索"],
  ),

  AlgorithmProblem(
    name: "最长公共子序列",
    applicableKnowledgePoints: {
      "动态规划": 10,
      "递归": 5,
    },
    description: "找到两个字符串的最长公共子序列长度",
    tags: ["动态规划", "字符串"],
  ),

  AlgorithmProblem(
    name: "零钱兑换",
    applicableKnowledgePoints: {
      "动态规划": 10,
      "BFS": 7,
      "贪心算法": 4,
    },
    description: "计算凑成总金额所需的最少硬币个数",
    tags: ["动态规划", "优化"],
  ),

  AlgorithmProblem(
    name: "最长递增子序列",
    applicableKnowledgePoints: {
      "动态规划": 10,
      "二分搜索": 9,
      "贪心算法": 6,
    },
    description: "找到数组中最长严格递增子序列的长度",
    tags: ["动态规划", "序列"],
  ),

  AlgorithmProblem(
    name: "编辑距离",
    applicableKnowledgePoints: {
      "动态规划": 10,
      "递归": 5,
    },
    description: "计算两个字符串的最小编辑距离",
    tags: ["动态规划", "字符串"],
  ),

  AlgorithmProblem(
    name: "背包问题",
    applicableKnowledgePoints: {
      "动态规划": 10,
      "回溯算法": 5,
      "贪心算法": 4,
    },
    description: "在限定重量下选择物品获得最大价值",
    tags: ["动态规划", "优化"],
  ),

  AlgorithmProblem(
    name: "最大子数组和",
    applicableKnowledgePoints: {
      "动态规划": 10,
      "分治算法": 8,
      "贪心算法": 7,
    },
    description: "找到连续子数组的最大和",
    tags: ["动态规划", "数组"],
  ),

  AlgorithmProblem(
    name: "买卖股票的最佳时机",
    applicableKnowledgePoints: {
      "动态规划": 10,
      "贪心算法": 7,
    },
    description: "计算买卖股票的最大利润",
    tags: ["动态规划", "优化"],
  ),

  AlgorithmProblem(
    name: "最小路径和",
    applicableKnowledgePoints: {
      "动态规划": 10,
      "BFS": 5,
      "DFS": 4,
    },
    description: "从网格左上角到右下角的最小路径和",
    tags: ["动态规划", "路径"],
  ),

  AlgorithmProblem(
    name: "字符串匹配",
    applicableKnowledgePoints: {
      "KMP算法": 10,
      "Boyer-Moore": 10,
      "Rabin-Karp": 8,
    },
    description: "在文本中查找模式字符串的所有出现位置",
    tags: ["字符串", "匹配"],
  ),

  AlgorithmProblem(
    name: "最长回文子串",
    applicableKnowledgePoints: {
      "动态规划": 10,
    },
    description: "找到字符串中最长的回文子串",
    tags: ["字符串", "回文"],
  ),

  AlgorithmProblem(
    name: "单词拆分",
    applicableKnowledgePoints: {
      "动态规划": 10,
      "Trie树": 8,
      "回溯算法": 6,
    },
    description: "判断字符串是否可以拆分成词典中的单词",
    tags: ["字符串", "动态规划"],
  ),

  AlgorithmProblem(
    name: "字符串的排列",
    applicableKnowledgePoints: {
      "回溯算法": 10,
      "递归": 8,
    },
    description: "生成字符串的所有排列",
    tags: ["字符串", "排列"],
  ),

  AlgorithmProblem(
    name: "最长公共前缀",
    applicableKnowledgePoints: {
      "Trie树": 10,
      "分治算法": 6,
      "二分搜索": 5,
    },
    description: "找到字符串数组的最长公共前缀",
    tags: ["字符串", "前缀"],
  ),

  AlgorithmProblem(
    name: "有效的字母异位词",
    applicableKnowledgePoints: {
      "哈希表": 10,
      "快速排序": 6,
    },
    description: "判断两个字符串是否互为字母异位词",
    tags: ["字符串", "哈希"],
  ),

  AlgorithmProblem(
    name: "字符串解码",
    applicableKnowledgePoints: {
      "栈": 10,
      "递归": 8,
    },
    description: "将编码的字符串解码",
    tags: ["字符串", "栈"],
  ),

  AlgorithmProblem(
    name: "最小窗口子串",
    applicableKnowledgePoints: {
      "哈希表": 10,
    },
    description: "找到包含所有目标字符的最小窗口子串",
    tags: ["字符串", "窗口"],
  ),

  AlgorithmProblem(
    name: "N皇后问题",
    applicableKnowledgePoints: {
      "回溯算法": 10,
      "递归": 8,
    },
    description: "在N×N棋盘上放置N个皇后使其不相互攻击",
    tags: ["回溯", "组合"],
  ),

  AlgorithmProblem(
    name: "数独求解器",
    applicableKnowledgePoints: {
      "回溯算法": 10,
      "递归": 8,
    },
    description: "解决数独谜题",
    tags: ["回溯", "约束"],
  ),

  AlgorithmProblem(
    name: "组合总和",
    applicableKnowledgePoints: {
      "回溯算法": 10,
      "动态规划": 6,
    },
    description: "找到所有和为目标值的数字组合",
    tags: ["回溯", "组合"],
  ),

  AlgorithmProblem(
    name: "全排列",
    applicableKnowledgePoints: {
      "回溯算法": 10,
      "递归": 8,
    },
    description: "生成数组的所有排列",
    tags: ["回溯", "排列"],
  ),

  AlgorithmProblem(
    name: "跳跃游戏",
    applicableKnowledgePoints: {
      "贪心算法": 10,
      "动态规划": 7,
      "BFS": 5,
    },
    description: "判断是否能跳到数组的最后位置",
    tags: ["贪心", "游戏"],
  ),

  AlgorithmProblem(
    name: "活动选择问题",
    applicableKnowledgePoints: {
      "贪心算法": 10,
      "动态规划": 5,
    },
    description: "选择最多的不重叠活动",
    tags: ["贪心", "调度"],
  ),

  AlgorithmProblem(
    name: "会议室问题",
    applicableKnowledgePoints: {
      "贪心算法": 10,
      "堆": 8,
      "快速排序": 6,
    },
    description: "判断一个人是否能参加所有会议",
    tags: ["贪心", "调度"],
  ),

  AlgorithmProblem(
    name: "任务调度器",
    applicableKnowledgePoints: {
      "贪心算法": 10,
      "优先队列": 8,
      "哈希表": 6,
    },
    description: "安排任务执行顺序使总时间最短",
    tags: ["贪心", "调度"],
  ),
];
