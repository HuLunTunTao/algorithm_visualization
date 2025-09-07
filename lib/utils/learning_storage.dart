import 'package:hive_flutter/hive_flutter.dart';

import '../struct/my_queue.dart';

class LearningStorage {
  static late Box<int> box;
  static late Box<List> pathBox;

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

  /// Clear all persisted learning data including counts and planned path.
  static Future<void> clearAll() async {
    await box.clear();
    await pathBox.clear();
  }

  /// Names of knowledge points that have been learned at least once.
  static List<String> getLearnedNames(Iterable<String> allNames) {
    return allNames.where((n) => (box.get(n, defaultValue: 0) ?? 0) > 0).toList();
  }

  // ------- Learning Path Queue -------

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
}
