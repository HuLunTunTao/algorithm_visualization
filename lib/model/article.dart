// 这个文件声明了文章类
import 'dart:math';

import 'package:flutter/services.dart';

import '../algo/afterknowledge.dart';
import '../algo/sort.dart';
import '../struct/my_graph.dart';
import 'KnowledgePoint.dart';
import '../algo/afterknowledge.dart';

class Article{


  static late List<KnowledgePoint> _knowledgeList = [];

  static final Map<String,List<String>> _keyWordsMap={};
  static final Map<String,String> _articleMap={};

  static Map<String,List<String>> get keyWordsMap=>_keyWordsMap;
  static Map<String,String> get articleMap=>_articleMap;

  static Future<void> initArticleClass(List<KnowledgePoint> list) async {
    _knowledgeList=list;

    for(final n in _knowledgeList){
      final kw = getArticleKeyWordsByName(n.name);
      final article = getArticleStringByName(n.name);

      _keyWordsMap[n.name] = await kw;
      _articleMap[n.name] = await article;

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

  static void calculateJaccardByInvertedMap(){
    // 建立关键词到知识点名字的倒排Map
    final invertedMap=<String,List<String>>{};

    for(final e in keyWordsMap.entries) {
      for (final keyWord in e.value) {
        invertedMap[keyWord] ??= <String>[];
        invertedMap[keyWord]!.add(e.key);
      }
    }

    final Map<String,Map<String,int>> a={}; //a[i][j]表示i和j的交集数

    for(final lst in invertedMap.values){
      for(int i=0;i<lst.length;i++){
        for(int j=i+1;j<lst.length;j++){
          a[lst[i]]??={};
          a[lst[j]]??={};
          a[lst[i]]![lst[j]]??=0;
          a[lst[j]]![lst[i]]??=0;
          a[lst[i]]![lst[j]] = a[lst[i]]![lst[j]]! + 1;
          a[lst[j]]![lst[i]] = a[lst[j]]![lst[i]]! + 1;
        }
      }
    }

    for(final e in a.entries.toList()){
      for(final ea in e.value.entries.toList()){
        final k0=e.key;
        final k1=ea.key;

        double jaccardSimilarity=ea.value/
            (keyWordsMap[k0]!.length+keyWordsMap[k1]!.length-ea.value).toDouble();

        jaccardMap[k0] ??= {};
        jaccardMap[k1] ??= {};
        jaccardMap[k0]![k1]=jaccardSimilarity;
        jaccardMap[k1]![k0]=jaccardSimilarity;
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

  static List<MapEntry<String,double>> getRecommendedWithScores(String articleName){ //根据雅卡尔指数推荐
    if(jaccardMap[articleName]==null) Exception("不存在知识点为\"$articleName\"的文章");
    List<MapEntry<String,double>> list=[];
    for(final e in jaccardMap[articleName]!.entries.toList()){
      if(e.value>0){
        list.add(e);
      }
    }
    SortAlgo.bubble_sort(list,(a,b)=>b.value.compareTo(a.value));
    return list;
  }

  static List<String> getAfterRecommended(String articleName){ //推荐后继知识点
    final q = findDescendants(articleName);
    return q.toList().map((kp) => kp.name).toList();
  }


  //对树的节点的随机访问
  // 已知图知识点图和已学知识点，随机采样一个未学知识点
  static String? getRandomRecommended(MyGraph<KnowledgePoint> tree,Iterable<String> allLearned,
      {int choose = 0}){ //choose是选择的方法
    final int numOfWay=2;
    if(choose%numOfWay==0){//对全集随机访问

      Set<String> set=allLearned.toSet();

      final q=findDescendants(tree.root.value.name);

      if(set.length+1<=q.length){ //如果树的总节点数 小于（说明有bug）等于（全学完了） 就返回空
        return null;
      }
      final random=Random();
      while(true){
        String res=q[random.nextInt(q.length)]!.name;
        if(!set.contains(res)){
          return res;
        }
      }
    }else{
      //todo:添加随机访问方法
    }

  }

  //随机推荐（根据学习时间，学习效果等）
  String? getSuperRecommend(Iterable<String> allLearned){

    Set<KnowledgePoint> set={};
    for(final e in allLearned){

    }
  }



  static Future<List<String>> getArticleKeyWordsByName(String name) async {
    try {
      final contents = await rootBundle.loadString('assets/key_words/$name.txt');
      return contents.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    } catch (e) {
      return [''];
    }
  }

  static Future<String> getArticleStringByName(String name) async {
    try {
      return await rootBundle.loadString('assets/md/$name.md');
    } catch (e) {
      return '暂无文章';
    }
  }



}