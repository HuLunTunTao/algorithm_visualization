int kmp(String a1, String a2){
  List<int> next=findnext(a2);
  int i=0;
  int j=0;
  while(i<a1.length&&j<a2.length){
    if (a1[i]==a2[j]){
      i++;
      j++;
    }
    else if (j>0){
      j=next[j-1];
    }
    else{   //字串第一个字符就失配
      i++;
    }
    if(j==a2.length){
      return i-j+1;
    }
  }
  return -1;
}

List<int> findnext(String a2)
{
  var p=List<int>.filled(a2.length,0);
  for(int i=1,j=0;i<a2.length;i++)
  {
    while(j>0&&a2[i]!=a2[j])
    {
    	j=p[j-1]; //回退到最长可用长度
	  }
    if(a2[i]==a2[j])
    {
      j++;  //匹配成功，j向后移动
    }
	p[i]=j;
  }
  return p;
}

