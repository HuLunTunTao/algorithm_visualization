import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

import '../model/article.dart';
import '../utils/learning_storage.dart';

class ArticlePage extends StatelessWidget {
  const ArticlePage({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final count = LearningStorage.getCount(name);
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: FutureBuilder<String>(
        future: Article.getArticleStringByName(name),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final content = snapshot.data ?? '暂无文章';
          final rec = Article.getRecommendedArticleNames(name);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('学习次数: $count'),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await LearningStorage.increment(name);
                      },
                      child: const Text('+1'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await LearningStorage.reset(name);
                      },
                      child: const Text('清空'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GptMarkdown(data: content),
                const SizedBox(height: 24),
                if (rec.isNotEmpty) ...[
                  const Text('相关推荐：', style: TextStyle(fontSize: 16)),
                  Wrap(
                    spacing: 8,
                    children: rec.map((e) {
                      return ActionChip(
                        label: Text(e),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ArticlePage(name: e),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
