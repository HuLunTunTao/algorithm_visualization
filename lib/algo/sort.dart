import '../model/KnowledgePoint.dart';

class SortAlgo
{
  static void bubble_sort<T>(List<T> list,Comparator<T> comp)
  {
    for(int i=0;i<list.length-1;i++)
    {
      for(int j=0;j<list.length-i-1;j++)
      {
        if(comp(list[j],list[j+1])>0)
        {
          T tem=list[j];
          list[j]=list[j+1];
          list[j+1]=tem;
        }
      }
    }
  }


// 单纯按难度排序
  static void sortByDifficulty(List<KnowledgePoint> knowledgePoints) 
  {
    bubble_sort<KnowledgePoint>(knowledgePoints, (a, b) 
    {
      return a.difficulty.compareTo(b.difficulty);
    });
  }

// 单纯按学习时间排序
  static void sortByStudyTime(List<KnowledgePoint> knowledgePoints) 
  {
    bubble_sort<KnowledgePoint>(knowledgePoints, (a, b) 
    {
      return a.studyTime.compareTo(b.studyTime);
    });
  }

// 先按难度，再按学习时间排序
  static void sortByDifficultyAndTime(List<KnowledgePoint> knowledgePoints) 
  {
    bubble_sort<KnowledgePoint>(knowledgePoints, (a, b) 
    {
      final difficultyComparison = a.difficulty.compareTo(b.difficulty);
      if (difficultyComparison != 0) {
        return difficultyComparison;
      }
      return a.studyTime.compareTo(b.studyTime);
    });

  }
}