# AC自动机

## 1. 概念介绍和定义

AC自动机（Aho-Corasick Automaton）是一种高效的多模式匹配算法，用于在文本中同时查找多个关键词。它结合了字典树（Trie）和KMP算法的思想，能够快速扫描并识别所有预定义的模式串。

### 适用场景
AC自动机特别适合以下场景：
- 敏感词过滤：在聊天系统或内容平台中检测多个敏感词
- 病毒扫描：在安全软件中匹配多个病毒特征码
- 基因序列分析：在生物信息学中查找多个DNA片段
- 代码分析：在编程语言中识别多个关键字或模式

### 核心目标
AC自动机的主要目标是：
1. 一次性扫描文本就能找到所有模式串的出现位置
2. 避免重复扫描文本，提高匹配效率
3. 通过预处理模式串构建有限状态机，实现线性时间复杂度的匹配

### 基本结构
AC自动机基于三个核心组件：
- 字典树：存储所有模式串
- 失败指针（fail指针）：类似于KMP中的next数组，用于在匹配失败时跳转
- 输出函数：记录每个节点对应的完整模式串

```cpp
// AC自动机节点结构示例
struct ACNode {
    ACNode* children[26];    // 子节点指针数组
    ACNode* fail;            // 失败指针
    bool isEnd;              // 是否为单词结尾
    vector<string> outputs;  // 输出模式串列表
};
```

通过这种设计，AC自动机能够在O(n+m)的时间复杂度内完成匹配，其中n是文本长度，m是所有模式串的总长度。

## 2. 核心原理解释

AC自动机的核心思想是在Trie树的基础上，通过添加失败指针（fail pointer）来实现高效的多模式匹配。其原理可分为三个关键部分：Trie树构建、失败指针计算和文本匹配过程。

### 构建Trie树
首先将所有模式串插入到一棵Trie树中，每个节点代表一个字符，从根节点到某一节点的路径构成一个前缀。每个节点需要包含以下信息：
- 子节点指针数组
- 失败指针
- 是否为单词结尾的标记

```cpp
struct TrieNode {
    TrieNode* children[26];  // 假设只处理小写字母
    TrieNode* fail;
    bool isEnd;
    
    TrieNode() {
        for (int i = 0; i < 26; i++) children[i] = nullptr;
        fail = nullptr;
        isEnd = false;
    }
};
```

### 计算失败指针
失败指针指向当前节点代表的前缀的最长真后缀对应的节点。构建过程采用BFS遍历Trie树：

1. 根节点的失败指针指向自己
2. 对于每个节点u及其子节点v（对应字符c）：
   - 如果u是根节点，v的失败指针指向根节点
   - 否则，令temp指向u的失败指针
   - 检查temp的子节点中是否有对应字符c的节点
     - 如果有，v的失败指针指向该节点
     - 如果没有，temp继续跳转到自己的失败指针，直到找到匹配或回到根节点

```cpp
void buildFailurePointers(TrieNode* root) {
    queue<TrieNode*> q;
    for (int i = 0; i < 26; i++) {
        if (root->children[i]) {
            root->children[i]->fail = root;
            q.push(root->children[i]);
        }
    }
    
    while (!q.empty()) {
        TrieNode* current = q.front();
        q.pop();
        
        for (int i = 0; i < 26; i++) {
            if (current->children[i]) {
                TrieNode* temp = current->fail;
                while (temp != root && !temp->children[i]) {
                    temp = temp->fail;
                }
                if (temp->children[i]) {
                    current->children[i]->fail = temp->children[i];
                } else {
                    current->children[i]->fail = root;
                }
                q.push(current->children[i]);
            }
        }
    }
}
```

### 文本匹配过程
匹配时从文本开头逐个字符处理：
1. 从根节点和文本起始位置开始
2. 对于每个字符，尝试从当前节点匹配：
   - 如果匹配成功，移动到对应子节点
   - 如果匹配失败，通过失败指针跳转，直到匹配成功或回到根节点
3. 检查当前节点及其失败指针链上的所有节点，记录所有匹配的模式串

这种设计确保了每个字符最多被处理常数次，时间复杂度为O(n + m)，其中n是文本长度，m是所有模式串总长度。

## 3. 详细的实现步骤

AC自动机的实现主要分为三个步骤：构建Trie树、建立失败指针以及进行模式匹配。下面我们分步说明每个环节的具体实现方法。

### 步骤一：构建Trie树
首先我们需要构建一个基础Trie树结构，用于存储所有模式串：

```cpp
struct TrieNode {
    TrieNode* children[26];  // 假设只包含小写字母
    TrieNode* fail;          // 失败指针
    bool isEnd;              // 标记是否为单词结尾
    int length;              // 记录单词长度（可选）
    
    TrieNode() {
        for (int i = 0; i < 26; i++) {
            children[i] = nullptr;
        }
        fail = nullptr;
        isEnd = false;
        length = 0;
    }
};

void insert(TrieNode* root, string pattern) {
    TrieNode* node = root;
    for (char c : pattern) {
        int index = c - 'a';
        if (!node->children[index]) {
            node->children[index] = new TrieNode();
        }
        node = node->children[index];
    }
    node->isEnd = true;
    node->length = pattern.length();
}
```

### 步骤二：建立失败指针
使用BFS遍历方式构建失败指针：

```cpp
void buildFailurePointer(TrieNode* root) {
    queue<TrieNode*> q;
    root->fail = nullptr;
    q.push(root);
    
    while (!q.empty()) {
        TrieNode* current = q.front();
        q.pop();
        
        for (int i = 0; i < 26; i++) {
            if (current->children[i]) {
                TrieNode* child = current->children[i];
                
                if (current == root) {
                    child->fail = root;
                } else {
                    TrieNode* temp = current->fail;
                    while (temp != nullptr) {
                        if (temp->children[i]) {
                            child->fail = temp->children[i];
                            break;
                        }
                        temp = temp->fail;
                    }
                    if (temp == nullptr) {
                        child->fail = root;
                    }
                }
                q.push(child);
            }
        }
    }
}
```

### 步骤三：执行匹配搜索
最后实现文本匹配功能：

```cpp
void search(TrieNode* root, string text) {
    TrieNode* current = root;
    for (int i = 0; i < text.length(); i++) {
        int index = text[i] - 'a';
        
        while (current != root && !current->children[index]) {
            current = current->fail;
        }
        
        if (current->children[index]) {
            current = current->children[index];
        }
        
        TrieNode* temp = current;
        while (temp != root) {
            if (temp->isEnd) {
                cout << "在位置 " << i - temp->length + 1 
                     << " 发现模式，长度为 " << temp->length << endl;
            }
            temp = temp->fail;
        }
    }
}
```

### 实现要点说明
1. **内存管理**：实际使用时需要添加内存释放逻辑
2. **优化技巧**：可以使用路径压缩来优化失败指针的跳转
3. **扩展功能**：可以记录每个节点的输出链表，提高匹配效率
4. **字符集处理**：如需支持更大字符集，可改用map存储子节点

通过这三个步骤，我们就完成了一个完整的AC自动机实现，能够高效地进行多模式串匹配。

## 4. 完整的C++代码示例（包含注释）

以下是一个完整的AC自动机C++实现，包含详细注释和可运行的示例：

```cpp
#include <iostream>
#include <vector>
#include <string>
#include <queue>
#include <unordered_map>
#include <memory>

using namespace std;

/**
 * AC自动机节点类
 * 每个节点包含：
 * - 子节点映射表
 * - 失败指针
 * - 输出链表（存储匹配的模式串）
 */
class ACNode {
public:
    unordered_map<char, shared_ptr<ACNode>> children; // 子节点映射
    shared_ptr<ACNode> fail;                          // 失败指针
    vector<string> outputs;                           // 输出链表（匹配的模式串）
    bool isEndOfWord;                                 // 是否为一个单词的结尾

    ACNode() : fail(nullptr), isEndOfWord(false) {}
};

/**
 * AC自动机类
 * 提供模式串插入、失败指针构建和文本搜索功能
 */
class ACAutomaton {
private:
    shared_ptr<ACNode> root; // 根节点

public:
    ACAutomaton() : root(make_shared<ACNode>()) {}

    /**
     * 插入模式串到Trie树中
     * @param pattern 要插入的模式串
     */
    void insert(const string& pattern) {
        auto current = root;
        for (char c : pattern) {
            if (current->children.find(c) == current->children.end()) {
                current->children[c] = make_shared<ACNode>();
            }
            current = current->children[c];
        }
        current->isEndOfWord = true;
        current->outputs.push_back(pattern); // 存储完整的模式串
    }

    /**
     * 构建失败指针（BFS遍历）
     * 使用广度优先搜索为所有节点构建失败指针
     */
    void buildFailurePointers() {
        queue<shared_ptr<ACNode>> q;
        
        // 初始化：根节点的所有子节点失败指针指向根节点
        for (auto& pair : root->children) {
            auto child = pair.second;
            child->fail = root;
            q.push(child);
        }

        // BFS遍历构建失败指针
        while (!q.empty()) {
            auto current = q.front();
            q.pop();

            // 遍历当前节点的所有子节点
            for (auto& pair : current->children) {
                char c = pair.first;
                auto child = pair.second;
                
                // 从当前节点的失败指针开始寻找匹配
                auto temp = current->fail;
                while (temp != nullptr && temp->children.find(c) == temp->children.end()) {
                    temp = temp->fail;
                }
                
                if (temp == nullptr) {
                    child->fail = root;
                } else {
                    child->fail = temp->children[c];
                    // 将失败指针指向节点的输出合并到当前节点
                    child->outputs.insert(child->outputs.end(), 
                                         child->fail->outputs.begin(), 
                                         child->fail->outputs.end());
                }
                
                q.push(child);
            }
        }
    }

    /**
     * 在文本中搜索所有模式串的出现位置
     * @param text 待搜索的文本
     * @return 匹配结果列表，每个元素为（模式串，起始位置）
     */
    vector<pair<string, int>> search(const string& text) {
        vector<pair<string, int>> results;
        auto current = root;

        for (int i = 0; i < text.size(); i++) {
            char c = text[i];
            
            // 如果当前字符不匹配，沿着失败指针回溯
            while (current != root && current->children.find(c) == current->children.end()) {
                current = current->fail;
            }
            
            if (current->children.find(c) != current->children.end()) {
                current = current->children[c];
            } else {
                current = root;
            }
            
            // 输出所有匹配的模式串
            for (const auto& pattern : current->outputs) {
                results.emplace_back(pattern, i - pattern.length() + 1);
            }
        }
        
        return results;
    }
};

/**
 * 示例使用函数
 * 演示AC自动机的完整工作流程
 */
int main() {
    ACAutomaton ac;
    
    // 插入模式串
    vector<string> patterns = {"he", "she", "his", "hers"};
    for (const auto& pattern : patterns) {
        ac.insert(pattern);
    }
    
    // 构建失败指针
    ac.buildFailurePointers();
    
    // 搜索文本
    string text = "ushers";
    cout << "搜索文本: \"" << text << "\"" << endl;
    cout << "模式串: ";
    for (const auto& pattern : patterns) {
        cout << pattern << " ";
    }
    cout << endl << endl;
    
    auto results = ac.search(text);
    
    // 输出结果
    cout << "匹配结果:" << endl;
    for (const auto& result : results) {
        cout << "模式串 \"" << result.first << "\" 出现在位置 " << result.second << endl;
    }
    
    return 0;
}
```

### 代码说明

1. **数据结构**：
   - `ACNode` 类表示AC自动机的节点
   - `ACAutomaton` 类封装了AC自动机的核心功能

2. **主要功能**：
   - `insert()`: 向Trie树中插入模式串
   - `buildFailurePointers()`: 使用BFS构建失败指针
   - `search()`: 在文本中搜索所有模式串

3. **示例输出**：
   当运行此程序时，输出将显示：
   ```
   搜索文本: "ushers"
   模式串: he she his hers 
   
   匹配结果:
   模式串 "he" 出现在位置 2
   模式串 "she" 出现在位置 1
   模式串 "hers" 出现在位置 2
   ```

这个实现完整展示了AC自动机的核心功能，包括Trie树构建、失败指针计算和多模式匹配搜索。

## 5. 代码解析和说明

以下为AC自动机核心代码实现，包含建树、构建失败指针和匹配查询三个主要部分：

```cpp
struct Node {
    int next[26];
    int fail;
    int count;
    Node() {
        memset(next, -1, sizeof(next));
        fail = -1;
        count = 0;
    }
};

vector<Node> trie;

void insert(string s) {
    int cur = 0;
    for (char ch : s) {
        int idx = ch - 'a';
        if (trie[cur].next[idx] == -1) {
            trie[cur].next[idx] = trie.size();
            trie.emplace_back();
        }
        cur = trie[cur].next[idx];
    }
    trie[cur].count++;
}
```

插入操作时间复杂度为O(L)，其中L为模式串长度。边界情况包括空字符串和重复插入相同模式串的处理。

```cpp
void build() {
    queue<int> q;
    trie[0].fail = 0;
    for (int i = 0; i < 26; i++) {
        if (trie[0].next[i] != -1) {
            trie[trie[0].next[i]].fail = 0;
            q.push(trie[0].next[i]);
        }
    }
    while (!q.empty()) {
        int cur = q.front(); q.pop();
        for (int i = 0; i < 26; i++) {
            int next = trie[cur].next[i];
            if (next != -1) {
                int fail = trie[cur].fail;
                while (fail != 0 && trie[fail].next[i] == -1) {
                    fail = trie[fail].fail;
                }
                if (trie[fail].next[i] != -1) {
                    fail = trie[fail].next[i];
                }
                trie[next].fail = fail;
                q.push(next);
            }
        }
    }
}
```

构建失败指针采用BFS遍历，时间复杂度为O(N×Σ)，其中N为节点总数，Σ为字符集大小。需要注意根节点的失败指针指向自身，避免空指针异常。

```cpp
int query(string s) {
    int cur = 0, res = 0;
    for (char ch : s) {
        int idx = ch - 'a';
        while (cur != 0 && trie[cur].next[idx] == -1) {
            cur = trie[cur].fail;
        }
        if (trie[cur].next[idx] != -1) {
            cur = trie[cur].next[idx];
        }
        int temp = cur;
        while (temp != 0) {
            res += trie[temp].count;
            temp = trie[temp].fail;
        }
    }
    return res;
}
```

查询操作时间复杂度为O(M+L)，其中M为文本串长度，L为所有模式串总长度。边界情况包括文本串为空或包含非小写字母字符时的处理。

## 6. 使用场景和应用

AC自动机在字符串多模式匹配场景中表现优异，特别适合以下应用：

- **敏感词过滤系统**：检测用户输入是否包含预设的敏感词汇
- **病毒特征码扫描**：在反病毒软件中快速匹配已知病毒的特征字符串
- **基因序列分析**：在生物信息学中查找特定的DNA/RNA序列模式
- **网络入侵检测**：识别网络数据包中的恶意代码或攻击特征

### 优势与局限

**优势**：
- 高效的多模式匹配，时间复杂度为O(n + m + z)，其中n是文本长度，m是所有模式串总长度，z是匹配次数
- 预处理后可以快速处理大量文本
- 支持动态添加模式串（需要重新构建失败指针）

**局限**：
- 内存消耗较大，每个节点需要存储多个指针
- 构建失败指针的过程相对复杂
- 不适合模式串频繁变动的场景

### 替代方案比较

与其他字符串匹配算法相比：

1. **KMP算法**：适合单模式匹配，多模式时需要多次调用，效率较低
2. **Rabin-Karp算法**：通过哈希值比较，可能产生哈希冲突，需要额外验证
3. **字典树(Trie)**：只能进行前缀匹配，缺乏失败转移机制

```cpp
// AC自动机基本使用示例
void searchPatterns(ACAutomaton& ac, const string& text) {
    Node* current = ac.root;
    for (char c : text) {
        current = ac.getNextState(current, c);
        if (current->output.size() > 0) {
            // 处理匹配到的模式串
            for (const string& pattern : current->output) {
                cout << "找到模式串: " << pattern << endl;
            }
        }
    }
}
```

在实际应用中，AC自动机特别适合模式串相对固定、需要高效批量匹配的场景，是许多文本处理系统的核心算法。

## 7. 注意事项和最佳实践

### 常见坑点
- **内存管理**：AC自动机节点较多时容易忘记释放内存，建议使用智能指针或封装内存管理
- **重复插入模式串**：相同的模式串多次插入会导致统计次数翻倍，需要根据实际需求判断是否去重
- **fail指针构建顺序**：必须按BFS顺序构建，否则会导致指针指向错误
- **多模式匹配时的状态回溯**：匹配失败后需要沿fail链回溯，不要直接回到根节点

### 优化建议
- **使用数组代替指针**：可以用静态数组存储节点，提高访问效率
- **路径压缩**：在构建fail指针时可以进行路径压缩，减少跳转次数
- **空间优化**：对于字符集较大的情况，可以使用map代替数组存储子节点
- **增量更新**：如果需要动态添加模式串，可以实现增量更新算法避免重建整个自动机

### 测试要点
```cpp
// 测试代码示例
void testACAutomation() {
    ACAutomation ac;
    ac.insert("hello");
    ac.insert("world");
    ac.build();
    
    // 测试基本匹配
    assert(ac.query("hello world") == 2);
    
    // 测试重叠匹配
    assert(ac.query("helloworld") == 2);
    
    // 测试无匹配情况
    assert(ac.query("test") == 0);
    
    // 测试内存泄漏
    // 可使用valgrind等工具检测
}
```

测试时特别注意：
- 边界情况：空字符串、超长文本、特殊字符
- 性能测试：大规模模式串下的构建和匹配效率
- 内存测试：确保无内存泄漏，特别是节点删除操作
- 并发安全：如果在多线程环境中使用，需要测试线程安全性

## 8. 相关知识点与延伸阅读

AC自动机是字符串匹配领域的重要算法，以下是与它相关的知识点、进阶方向以及推荐的学习资料。

#### 相关概念
- **Trie树**：AC自动机的基础数据结构，用于存储模式串集合
- **KMP算法**：AC自动机中失败指针的构建借鉴了KMP的next数组思想
- **有限状态机(FSM)**：AC自动机可视为一种确定有限状态自动机(DFA)
- **多模式匹配**：AC自动机解决的是多模式串匹配问题

#### 进阶方向
1. **AC自动机的优化**
   - 使用双数组Trie减少内存占用
   - 添加输出指针优化匹配效率
   - 支持动态模式串的增量更新

2. **扩展应用**
   - 结合正则表达式实现更复杂的模式匹配
   - 在生物信息学中用于基因序列分析
   - 网络入侵检测系统中的多特征匹配

#### 参考资料
- **书籍**：《算法导论》字符串匹配章节
- **论文**：Aho-Corasick原始论文《Efficient string matching: an aid to bibliographic search》
- **在线资源**：
  - GeeksforGeeks的AC自动机专题教程
  - CP-Algorithms网站的详细解析和代码实现
  - LeetCode相关题目练习（如#1032）

```cpp
// AC自动机基础结构示例
struct ACNode {
    ACNode* children[26];
    ACNode* fail;
    bool isEnd;
    ACNode() {
        for (int i = 0; i < 26; i++) children[i] = nullptr;
        fail = nullptr;
        isEnd = false;
    }
};
```

建议通过实现一个完整的AC自动机来加深理解，并尝试解决一些实际应用问题。
