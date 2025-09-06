import 'dart:math';
import '../my_map.dart';

void main() {
  print("=== MyMap测试开始 ===\n");
  var random = Random();
  final maxRandomInt = 100;

  print("测试基本添加操作");
  MyMap<String, int> map = MyMap<String, int>();
  List<String> keys = ['apple', 'banana', 'cherry', 'date', 'elderberry'];

  for (int i = 0; i < keys.length; i++) {
    int value = random.nextInt(maxRandomInt);
    print("添加键值对: ${keys[i]} -> $value");
    map[keys[i]] = value;
  }
  map.printAll();
  print("映射长度：${map.length}");
  print("映射是否为空：${map.isEmpty}");

  print("测试键值获取");
  for (String key in keys) {
    int? value = map[key];
    print("键 '$key' 对应的值: $value");
  }
  print("获取不存在的键 'grape': ${map['grape']}");

  print("测试键值更新");
  String keyToUpdate = keys[0];
  int oldValue = map[keyToUpdate]!;
  int newValue = random.nextInt(maxRandomInt);
  print("更新键 '$keyToUpdate': $oldValue -> $newValue");
  map[keyToUpdate] = newValue;
  map.printAll();

  print("测试from构造函数");
  Map<String, int> originalMap = {'x': 1, 'y': 2, 'z': 3};
  print("从原始映射创建: $originalMap");
  MyMap<String, int> mapFromOther = MyMap<String, int>.from(originalMap);
  mapFromOther.printAll();
  print("新映射长度：${mapFromOther.length}");

  print("测试containsKey和containsValue");
  for (String key in ['apple', 'grape', 'banana']) {
    bool hasKey = map.containsKey(key);
    print("包含键 '$key': $hasKey");
  }

  List<int> valuesToCheck = [1, 50, map.values.first];
  for (int value in valuesToCheck) {
    bool hasValue = map.containsValue(value);
    print("包含值 $value: $hasValue");
  }

  print("测试删除操作");
  String keyToRemove = keys[1];
  print("删除键: $keyToRemove");
  int? removedValue = map.remove(keyToRemove);
  print("删除的值: $removedValue");
  map.printAll();
  print("映射长度：${map.length}");

  print("再次尝试删除相同键: $keyToRemove");
  int? removedAgain = map.remove(keyToRemove);
  print("删除的值: $removedAgain");

  print("测试keys、values、entries");
  print("所有键: ${map.keys}");
  print("所有值: ${map.values}");
  print("所有条目:");
  for (var entry in map.entries) {
    print("  ${entry.key} -> ${entry.value}");
  }

  print("测试forEach");
  print("使用forEach遍历:");
  map.forEach((key, value) {
    print("  $key: $value");
  });

  print("测试addAll");
  Map<String, int> additionalData = {'fig': 10, 'grape': 20, 'kiwi': 30};
  print("添加额外数据: $additionalData");
  map.addAll(additionalData);
  map.printAll();
  print("映射长度：${map.length}");

  print("测试putIfAbsent");
  String newKey = 'lemon';
  int putResult1 = map.putIfAbsent(newKey, () => 99);
  print("putIfAbsent新键 '$newKey': $putResult1");
  map.printAll();

  int putResult2 = map.putIfAbsent(newKey, () => 88);
  print("putIfAbsent已存在键 '$newKey': $putResult2");
  map.printAll();

  print("测试update");
  String updateKey = map.keys.first;
  int? oldVal = map[updateKey];
  print("更新键 '$updateKey' (原值: $oldVal)");
  int? newVal = map.update(updateKey, (value) => value * 2);
  print("新值: $newVal");
  map.printAll();

  print("更新不存在的键 'mango':");
  int? updateResult = map.update('mango', (value) => value * 2, ifAbsent: () => 100);
  print("结果: $updateResult");
  map.printAll();

  print("测试removeWhere");
  print("删除值大于50的条目:");
  map.removeWhere((key, value) => value > 50);
  map.printAll();
  print("映射长度：${map.length}");

  print("测试整数映射");
  MyMap<int, String> intMap = MyMap<int, String>();
  for (int i = 1; i <= 5; i++) {
    intMap[i] = "数字$i";
  }
  print("整数键映射:");
  intMap.printAll();

  print("访问键2: ${intMap[2]}");
  print("访问键10: ${intMap[10]}");

  print("测试大容量（扩容测试）");
  MyMap<int, int> largeMap = MyMap<int, int>();
  print("添加1000个键值对...");
  for (int i = 0; i < 1000; i++) {
    largeMap[i] = i * i;
  }
  print("大映射长度: ${largeMap.length}");
  print("键100对应的值: ${largeMap[100]}");
  print("键999对应的值: ${largeMap[999]}");
  print("包含键500: ${largeMap.containsKey(500)}");

  print("测试map转换");
  MyMap<String, int> smallMap = MyMap<String, int>.from({'a': 1, 'b': 2, 'c': 3});
  print("原始映射:");
  smallMap.printAll();

  Map<String, String> transformed = smallMap.map((key, value) {
    return MapEntry('${key.toUpperCase()}', 'v$value');
  });
  print("转换后的映射: $transformed");

  print("测试updateAll");
  print("将所有值乘以10:");
  smallMap.updateAll((key, value) => value * 10);
  smallMap.printAll();

  print("测试清空操作");
  smallMap.clear();
  print("清空后映射:");
  smallMap.printAll();
  print("映射长度：${smallMap.length}");
  print("映射是否为空：${smallMap.isEmpty}");

  print("测试边界情况");
  MyMap<String, int> emptyMap = MyMap<String, int>();
  print("空映射访问: ${emptyMap['nonexistent']}");
  print("空映射删除: ${emptyMap.remove('nonexistent')}");

  MyMap<String, int> singleMap = MyMap<String, int>();
  singleMap['only'] = 42;
  print("单元素映射:");
  singleMap.printAll();
  print("删除唯一元素: ${singleMap.remove('only')}");
  singleMap.printAll();

  print("=== MyMap测试完成 ===");
}
