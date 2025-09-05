// 这个文件声明了文章类
import 'dart:io';


import '../algo/sort.dart';
import 'KnowledgePoint.dart';

class Article{


  static final String _filePathPrefix="/Users/hltt/projects/llm_generate/";
  static late List<KnowledgePoint> _knowledgeList=[];

  static final Map<String,List<String>> _keyWordsMap={};
  static final Map<String,String> _articleMap={};

  static Map<String,List<String>> get keyWordsMap=>_keyWordsMap;
  static Map<String,String> get articleMap=>_articleMap;

  static Future<void> initArticleClass(List<KnowledgePoint> list) async {
    _knowledgeList=list;

    for(final n in _knowledgeList){
      final kw=getArticleKeyWordsByName(n.name);
      final article=getArticleStringByName(n.name);

      _keyWordsMap[n.name]=await kw;
      _articleMap[n.name]=await article;

      // print(await kw);
    }
  }

  static Map<String,Map<String,double>> jaccardMap={};

  static void calculateJaccard(){
    final entries = keyWordsMap.entries.toList();
    for(int i=0;i<entries.length;i++){
      for(int j=i+1;j<entries.length;j++){
        int a=0;
        for(final s in entries[i].value){
          if(entries[j].value.contains(s))
            {
              a++;
            }
        }

        double jaccardSimilarity=a.toDouble()/(entries[i].value.length+entries[j].value.length-a).toDouble();

        jaccardMap[entries[i].key] ??= {};
        jaccardMap[entries[j].key] ??= {};
        jaccardMap[entries[i].key]![entries[j].key]=jaccardSimilarity;
        jaccardMap[entries[j].key]![entries[i].key]=jaccardSimilarity;
      }
    }
  }

  static List<String> getRecommendedArticleNames(String articleName){
    if(jaccardMap[articleName]==null) Exception("不存在知识点为\"$articleName\"的文章");
    List<String> res=[];
    List<MapEntry<String,double>> list=[];
    for(final e in jaccardMap[articleName]!.entries.toList()){
      if(e.value>0){
        list.add(e);
      }
    }
    SortAlgo.bubble_sort(list,(a,b)=>b.value.compareTo(a.value));
    for(final e in list){
      res.add(e.key);
    }
    return res;
  }



  static Future<List<String>> getArticleKeyWordsByName(String name) async{
    final file=File("${_filePathPrefix}key_words/$name.txt");
    try{
      String contents=await file.readAsString();
      return contents.split(" ");
    }on FileSystemException catch (e) {
      print("找不到 ${file.path}");
      return [""];
    }
  }

  static Future<String> getArticleStringByName(String name) async {
    final file=File("${_filePathPrefix}md/$name.md");
    try{
      String contents=await file.readAsString();
      return contents;
    }on FileSystemException catch (e) {
      print("找不到 ${file.path}");
      return "暂无文章";
    }
  }



}