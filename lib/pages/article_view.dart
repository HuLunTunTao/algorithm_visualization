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
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GptMarkdown(content),
              const SizedBox(height: 24),
              if (rec.isNotEmpty) ...[
                const Text('相关推荐：', style: TextStyle(fontSize: 16)),
                Wrap(
                  spacing: 8,
                  children: rec.map((e) {
                    return ActionChip(
                      label: Text('${e.key} (${e.value.toStringAsFixed(2)})'),
                      onPressed: () => onSelect?.call(e.key),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
