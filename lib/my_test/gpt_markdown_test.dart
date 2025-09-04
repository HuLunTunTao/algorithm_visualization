import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 使用主题可以让整体风格更统一
      theme: ThemeData(
        brightness: Brightness.light, // 亮色模式
        primarySwatch: Colors.blue,   // 主题色
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark, // 暗色/夜间模式
      ),
      themeMode: ThemeMode.system, // 跟随系统设置
      debugShowCheckedModeBanner: false, // 隐藏右上角的 Debug 标签
      home: const MarkdownPage(), // 将 home 指向我们新创建的页面
    );
  }
}

// 创建一个新的 Widget 来作为我们的页面
class MarkdownPage extends StatelessWidget {
  const MarkdownPage({super.key});

  // 将 Markdown 文本提取出来，方便管理
  final String markdownText = '''
## ChatGPT Response

Welcome to ChatGPT! Below is an example of a response with Markdown and LaTeX code:

### Markdown Example

You can use Markdown to format text easily. Here are some examples:

- **Bold Text**: **This text is bold**
- *Italic Text*: *This text is italicized*
- [Link](https://www.example.com): [This is a link](https://www.example.com)
- Lists:
  1. Item 1
  2. Item 2
  3. Item 3

### LaTeX Example

You can also use LaTeX for mathematical expressions. Here's an example:

- **Equation**: \\( f(x) = x^2 + 2x + 1 \\)
- **Integral**: \\( \int_{0}^{1} x^2 \, dx \\)
- **Matrix**:

\[
\begin{bmatrix}
1 & 2 & 3 \\
4 & 5 & 6 \\
7 & 8 & 9
\end{bmatrix}
\]

### More Content to Enable Scrolling

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

### Conclusion

Markdown and LaTeX can be powerful tools for formatting text and mathematical expressions in your Flutter app. If you have any questions or need further assistance, feel free to ask!
''';

  @override
  Widget build(BuildContext context) {
    // 1. 使用 Scaffold 作为页面的根
    return Scaffold(
      // 添加一个顶部的应用栏
      appBar: AppBar(
        title: const Text('Markdown & LaTeX 示例'),
        elevation: 1, // AppBar 的阴影
      ),
      // 页面主体内容
      body:
      // 2. 使用 SingleChildScrollView 来实现滚动
      SingleChildScrollView(
        // 3. 使用 Padding 在内容周围添加间距
        child: Padding(
          padding: const EdgeInsets.all(16.0), // 四周各留 16 像素的间距
          child: GptMarkdown(
            markdownText,
            // 你可以保留之前的 TextStyle，但通常让它跟随主题会更好看
            // style: const TextStyle(
            //   color: Colors.red,
            // ),
          ),
        ),
      ),
    );
  }
}