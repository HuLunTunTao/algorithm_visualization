import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

import '../model/article.dart';

class ArticleView extends StatelessWidget {
  const ArticleView({super.key, required this.name, this.onSelect});

  final String name;
  final void Function(String name)? onSelect;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: Article.getArticleStringByName(name),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final content = snapshot.data ?? '暂无文章';
        final rec = Article.getRecommendedWithScores(name);
        final after = Article.getAfterRecommended(name);
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GptMarkdown(
                      content,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    if (rec.isNotEmpty) ...[
                      const Text(
                        '相关推荐：',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        spacing: 8,
                        children: rec.map((e) {
                          return ActionChip(
                            backgroundColor: Colors.blue.shade100,
                            label: Text('${e.key} (${e.value.toStringAsFixed(2)})'),
                            onPressed: () => onSelect?.call(e.key),
                          );
                        }).toList(),
                      ),
                    ],
                    if (after.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        '后继推荐：',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        spacing: 8,
                        children: after.map((e) {
                          return ActionChip(
                            backgroundColor: Colors.purple.shade100,
                            label: Text(e),
                            onPressed: () => onSelect?.call(e),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
