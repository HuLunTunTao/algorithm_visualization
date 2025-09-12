import '../KnowledgePoint.dart';
import '../article.dart';

int myTest(int testTimes,void Function() callback)
{
  final sw = Stopwatch();
  sw.start();
  for(int i=0;i<testTimes;i++){
    callback();
  }
  sw.stop();
  return sw.elapsedMilliseconds;
}

void main(){

  Article.initArticleClass(KnowledgePointRepository.getAllKnowledgePoints());
  Article.calculateJaccard();

  final int testTimes=100000;
  
  print("方法一用时:${myTest(testTimes, Article.calculateJaccard)}");
  print("方法二用时:${myTest(testTimes, Article.calculateJaccardByInvertedMap)}");


}