import 'package:hive_flutter/hive_flutter.dart';

class LearningStorage {
  static late Box<int> box;

  static Future<void> init() async {
    await Hive.initFlutter();
    box = await Hive.openBox<int>('learningCounts');
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
}
