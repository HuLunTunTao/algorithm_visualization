class SortAlgo{
  static void bubble_sort(List<num> list,Comparator<num> comp)
  {
    for(int i=0;i<list.length-1;i++)
    {
      for(int j=0;j<list.length-i-1;j++)
      {
        if(comp(list[j],list[j+1])>0)
        {
          num temp=list[j];
          list[j]=list[j+1];
          list[j+1]=temp;
        }
      }
    }
  }
}


