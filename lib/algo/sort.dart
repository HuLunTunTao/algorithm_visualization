class SortAlgo{
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
}

