import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'utils/learning_storage.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LearningStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '算法可视化学习平台',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        fontFamily: 'NotoSansSC',
      ),
      home: const HomePage(),
    );
  }
}
