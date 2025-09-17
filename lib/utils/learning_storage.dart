import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../struct/my_queue.dart';

class LearningStorage {
  static late Box<int> box;//学习次数计数
  static late Box<List> pathBox;//学习路径

  static Future<void> init() async {
    await Hive.initFlutter();
    box = await Hive.openBox<int>('learningCounts');
    pathBox = await Hive.openBox<List>('learningPath');
  }

  static int getCount(String name) {
    return box.get(name, defaultValue: 0) ?? 0;
  }

  static Future<void> increment(String name) async {
    final c = getCount(name) + 1;
    await box.put(name, c);
  }

  static Future<void> reset(String name) async {
    await box.put(name, 0);
  }

  //清空已学习记录和路径规划
  static Future<void> clearAll() async {
    await box.clear();
    await pathBox.clear();
  }

  // 获取至少学了一次的知识点的名字的列表
  static List<String> getLearnedNames(Iterable<String> allNames) {
    return allNames.where((n) => (box.get(n, defaultValue: 0) ?? 0) > 0).toList();
  }

  //学习路径 队列

  static MyQueue<String> getPathQueue() {
    final list = List<String>.from(pathBox.get('path', defaultValue: const []) ?? const []);
    final q = MyQueue<String>();
    for (final n in list) {
      q.enqueue(n);
    }
    return q;
  }

  static Future<void> savePath(List<String> path) async {
    await pathBox.put('path', path);
  }

  static Future<void> clearPath() async {
    await pathBox.delete('path');
  }

  static Future<void> popFront() async {
    final list = List<String>.from(pathBox.get('path', defaultValue: const []) ?? const []);
    if (list.isEmpty) return;
    list.removeAt(0);
    await savePath(list);
  }

  static Future<void> remove(String name) async {
    final list = List<String>.from(pathBox.get('path', defaultValue: const []) ?? const []);
    list.removeWhere((e) => e == name);
    await savePath(list);
  }

  static ValueListenable<Box<int>> watchCounts() {
    return box.listenable();
  }
}
