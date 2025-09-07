# Boyer-Moore

## 1. 概念介绍和定义

Boyer-Moore算法是一种高效的字符串搜索算法，用于在一个主文本字符串中查找一个模式字符串的出现位置。与传统的逐字符比较方法不同，Boyer-Moore采用了从右向左比较的策略，并利用两种启发式规则（坏字符规则和好后缀规则）来跳过不必要的比较，从而显著提高搜索效率。

该算法适用于以下场景：
- 需要在大文本中快速查找模式的情况，例如文本编辑器中的查找功能或数据处理中的模式匹配。
- 当模式串较长时，Boyer-Moore的优势更加明显，因为它可以跳过大量字符。

Boyer-Moore算法的目标是：
- 减少字符比较次数，从而降低时间复杂度。
- 在实际应用中达到比朴素算法更快的搜索速度。

以下是Boyer-Moore算法的核心步骤的简化代码示例（C++实现）：

```cpp
#include <vector>
#include <string>
using namespace std;

void preprocessBadChar(const string &pattern, vector<int> &badChar) {
    int size = pattern.size();
    for (int i = 0; i < 256; i++) {
        badChar[i] = -1;
    }
    for (int i = 0; i < size; i++) {
        badChar[(int)pattern[i]] = i;
    }
}

vector<int> searchBoyerMoore(const string &text, const string &pattern) {
    vector<int> result;
    int n = text.size();
    int m = pattern.size();
    vector<int> badChar(256, -1);
    preprocessBadChar(pattern, badChar);

    int shift = 0;
    while (shift <= n - m) {
        int j = m - 1;
        while (j >= 0 && pattern[j] == text[shift + j]) {
            j--;
        }
        if (j < 0) {
            result.push_back(shift);
            shift += (shift + m < n) ? m - badChar[text[shift + m]] : 1;
        } else {
            shift += max(1, j - badChar[text[shift + j]]);
        }
    }
    return result;
}
```

通过以上介绍，你可以初步了解Boyer-Moore算法的基本概念、适用场景及其目标。

## 2. 核心原理解释

Boyer-Moore算法的核心思想在于利用模式串与文本串匹配失败时的信息，通过两个启发式规则——坏字符规则和好后缀规则——来跳过尽可能多的无效比较，从而提升匹配效率。下面我们详细解释这两个规则及其工作原理。

### 坏字符规则（Bad Character Rule）

当模式串与文本串的某个字符不匹配时，我们将文本串中这个不匹配的字符称为“坏字符”。坏字符规则的处理逻辑如下：

- 如果坏字符在模式串中不存在，则直接将模式串移动到坏字符之后的位置。
- 如果坏字符在模式串中存在，则将模式串向右移动，使得模式串中最后一次出现的该字符与文本串中的坏字符对齐。

例如，假设文本串为 "EXAMPLE TEXT"，模式串为 "TEXT"：
- 初始对齐位置：文本串 "E X A M P L E   T E X T"，模式串 "T E X T"
- 比较第一个字符：'E'（文本）与 'T'（模式）不匹配
- 'E' 在模式串中存在（位于第2位），因此将模式串右移，使模式串的 'E' 对齐文本串的 'E'

### 好后缀规则（Good Suffix Rule）

当已经匹配成功一部分字符后出现不匹配时，我们将已匹配的后缀称为“好后缀”。好后缀规则的处理方式如下：

- 在模式串中查找与好后缀匹配的另一个子串，如果存在，则将模式串移动到该位置。
- 如果不存在完全匹配的子串，则查找好后缀的最长后缀，该后缀同时也是模式串的前缀，并移动模式串使其对齐。

例如，文本串为 "ABABABACABA"，模式串为 "ABABAC"：
- 匹配到第5个字符时：文本 "ABABA" 与模式 "ABABA" 匹配，但第6个字符 'C'（文本）与 'A'（模式）不匹配
- 好后缀为 "BABA"
- 在模式串中查找 "BABA" 的出现，发现位置0处有部分匹配（"ABAB"），移动模式串使前缀与好后缀对齐

### 代码实现关键步骤

实际应用中，Boyer-Moore算法会预处理模式串，生成坏字符表和好后缀表，用于快速确定移动距离。以下是预处理坏字符表的C++代码示例：

```cpp
void preprocessBadChar(const string& pattern, int badChar[256]) {
    int len = pattern.length();
    for (int i = 0; i < 256; i++) {
        badChar[i] = -1;
    }
    for (int i = 0; i < len; i++) {
        badChar[(int)pattern[i]] = i;
    }
}
```

通过这两个规则的结合使用，Boyer-Moore算法能够在大多数情况下跳过大量不必要的比较，其时间复杂度在最坏情况下为O(n/m)，在平均情况下表现优异，特别适用于较长模式串的匹配场景。

## 3. 详细的实现步骤

Boyer-Moore算法的实现主要分为预处理和匹配两个阶段。以下是具体的实现步骤：

1. **预处理阶段**：
   - 构建坏字符表（Bad Character Table）：记录每个字符在模式串中最后一次出现的位置。如果字符不在模式串中，则值为-1。
   - 构建好后缀表（Good Suffix Table）：处理模式串的后缀信息，用于在匹配失败时确定移动距离。

2. **匹配阶段**：
   - 将模式串与文本串对齐，从右向左比较字符。
   - 当出现不匹配时，根据坏字符规则和好后缀规则计算移动距离，取两者中的最大值进行滑动。
   - 重复以上过程直到找到所有匹配或遍历完整个文本串。

以下是C++实现的核心代码示例：

```cpp
#include <vector>
#include <string>
#include <algorithm>
using namespace std;

void buildBadCharTable(const string& pattern, vector<int>& badCharTable) {
    int size = pattern.size();
    badCharTable.resize(256, -1);
    for (int i = 0; i < size; i++) {
        badCharTable[pattern[i]] = i;
    }
}

void buildGoodSuffixTable(const string& pattern, vector<int>& goodSuffixTable) {
    int m = pattern.size();
    vector<int> suffix(m, 0);
    goodSuffixTable.resize(m, 0);

    for (int i = m - 2; i >= 0; i--) {
        int j = i;
        while (j >= 0 && pattern[j] == pattern[m - 1 - i + j]) {
            j--;
        }
        suffix[i] = i - j;
    }

    for (int i = 0; i < m; i++) {
        goodSuffixTable[i] = m;
    }
    
    for (int i = m - 1; i >= 0; i--) {
        if (suffix[i] == i + 1) {
            for (int j = 0; j < m - 1 - i; j++) {
                if (goodSuffixTable[j] == m) {
                    goodSuffixTable[j] = m - 1 - i;
                }
            }
        }
    }
    
    for (int i = 0; i <= m - 2; i++) {
        goodSuffixTable[m - 1 - suffix[i]] = m - 1 - i;
    }
}

vector<int> boyerMooreSearch(const string& text, const string& pattern) {
    vector<int> matches;
    int n = text.size();
    int m = pattern.size();
    
    vector<int> badCharTable;
    buildBadCharTable(pattern, badCharTable);
    
    vector<int> goodSuffixTable;
    buildGoodSuffixTable(pattern, goodSuffixTable);
    
    int i = 0;
    while (i <= n - m) {
        int j = m - 1;
        while (j >= 0 && pattern[j] == text[i + j]) {
            j--;
        }
        if (j < 0) {
            matches.push_back(i);
            i += goodSuffixTable[0];
        } else {
            int badCharShift = j - badCharTable[text[i + j]];
            int goodSuffixShift = goodSuffixTable[j];
            i += max(1, max(badCharShift, goodSuffixShift));
        }
    }
    return matches;
}
```

实现要点：
- 坏字符表的构建使用256大小的数组（覆盖所有ASCII字符）
- 好后缀表的构建需要处理后缀数组和前缀信息
- 匹配时优先使用好后缀规则，两者取最大值移动
- 注意边界条件的处理，特别是模式串出现在文本串末尾的情况

## 4. 完整的C++代码示例（包含注释）

以下是一个完整的Boyer-Moore字符串搜索算法的C++17实现，包含详细注释和可运行的示例：

```cpp
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <unordered_map>

/**
 * Boyer-Moore字符串搜索算法实现
 */
class BoyerMoore {
private:
    std::string pattern;
    std::unordered_map<char, int> badCharTable;
    std::vector<int> goodSuffixTable;

    /**
     * 构建坏字符规则表
     * 记录每个字符在模式串中最后出现的位置
     */
    void buildBadCharTable() {
        for (int i = 0; i < pattern.length(); i++) {
            // 记录每个字符最后出现的位置（从右往左数）
            badCharTable[pattern[i]] = i;
        }
    }

    /**
     * 构建好后缀规则表
     * 计算每个位置匹配失败时，模式串可以安全移动的距离
     */
    void buildGoodSuffixTable() {
        int m = pattern.length();
        goodSuffixTable.resize(m, 0);
        
        // 后缀数组，用于记录最长公共后缀
        std::vector<int> suffix(m, 0);
        suffix[m - 1] = m;
        
        int g = m - 1;
        int f = 0;
        
        // 预处理后缀数组
        for (int i = m - 2; i >= 0; i--) {
            if (i > g && suffix[i + m - 1 - f] < i - g) {
                suffix[i] = suffix[i + m - 1 - f];
            } else {
                g = std::min(g, i);
                f = i;
                while (g >= 0 && pattern[g] == pattern[g + m - 1 - f]) {
                    g--;
                }
                suffix[i] = f - g;
            }
        }
        
        // 构建好后缀表
        for (int i = 0; i < m; i++) {
            goodSuffixTable[i] = m;
        }
        
        int j = 0;
        for (int i = m - 1; i >= 0; i--) {
            if (suffix[i] == i + 1) {
                for (; j < m - 1 - i; j++) {
                    if (goodSuffixTable[j] == m) {
                        goodSuffixTable[j] = m - 1 - i;
                    }
                }
            }
        }
        
        for (int i = 0; i <= m - 2; i++) {
            goodSuffixTable[m - 1 - suffix[i]] = m - 1 - i;
        }
    }

public:
    /**
     * 构造函数，初始化模式串并构建规则表
     * @param pat 要搜索的模式字符串
     */
    BoyerMoore(const std::string& pat) : pattern(pat) {
        buildBadCharTable();
        buildGoodSuffixTable();
    }

    /**
     * 在文本中搜索模式串
     * @param text 要搜索的文本
     * @return 所有匹配位置的索引列表
     */
    std::vector<int> search(const std::string& text) {
        std::vector<int> matches;
        int n = text.length();
        int m = pattern.length();
        
        if (m == 0 || n == 0 || m > n) {
            return matches;
        }

        int i = 0;  // 文本中的当前比较位置
        while (i <= n - m) {
            int j = m - 1;  // 从模式串末尾开始比较
            
            // 从右向左比较字符
            while (j >= 0 && pattern[j] == text[i + j]) {
                j--;
            }
            
            if (j < 0) {
                // 找到完全匹配
                matches.push_back(i);
                
                // 使用好后缀规则移动
                i += (i + m < n) ? goodSuffixTable[0] : 1;
            } else {
                // 计算坏字符规则的移动距离
                int badCharShift = j - (badCharTable.count(text[i + j]) ? 
                                      badCharTable[text[i + j]] : -1);
                
                // 计算好后缀规则的移动距离
                int goodSuffixShift = goodSuffixTable[j];
                
                // 取两个规则中的较大值作为移动距离
                i += std::max(1, std::max(badCharShift, goodSuffixShift));
            }
        }
        
        return matches;
    }
};

int main() {
    // 示例1：基本搜索
    std::cout << "示例1：基本字符串搜索" << std::endl;
    std::string text1 = "ABAAABCDBBABCDDEBCABC";
    std::string pattern1 = "ABC";
    
    BoyerMoore bm1(pattern1);
    std::vector<int> result1 = bm1.search(text1);
    
    std::cout << "文本: " << text1 << std::endl;
    std::cout << "模式: " << pattern1 << std::endl;
    std::cout << "找到 " << result1.size() << " 个匹配位置: ";
    for (int pos : result1) {
        std::cout << pos << " ";
    }
    std::cout << "\n\n";

    // 示例2：空模式串处理
    std::cout << "示例2：空模式串测试" << std::endl;
    std::string text2 = "Hello World";
    std::string pattern2 = "";
    
    BoyerMoore bm2(pattern2);
    std::vector<int> result2 = bm2.search(text2);
    
    std::cout << "空模式串搜索结果数量: " << result2.size() << "\n\n";

    // 示例3：用户输入测试
    std::cout << "示例3：用户输入测试" << std::endl;
    std::string userText, userPattern;
    
    std::cout << "请输入文本: ";
    std::getline(std::cin, userText);
    
    std::cout << "请输入模式串: ";
    std::getline(std::cin, userPattern);
    
    if (!userPattern.empty()) {
        BoyerMoore bm3(userPattern);
        std::vector<int> result3 = bm3.search(userText);
        
        std::cout << "找到 " << result3.size() << " 个匹配位置: ";
        for (int pos : result3) {
            std::cout << pos << " ";
        }
        std::cout << std::endl;
    } else {
        std::cout << "模式串不能为空！" << std::endl;
    }

    return 0;
}
```

### 代码说明：

1. **BoyerMoore类**：封装了完整的Boyer-Moore算法实现
   - 包含坏字符规则表和好后缀规则表
   - 提供搜索功能接口

2. **核心功能**：
   - `buildBadCharTable()`: 构建坏字符跳跃表
   - `buildGoodSuffixTable()`: 构建好后缀跳跃表
   - `search()`: 执行搜索算法

3. **示例测试**：
   - 示例1：演示基本字符串搜索功能
   - 示例2：处理边界情况（空模式串）
   - 示例3：支持用户交互式输入测试

4. **编译运行**：
   - 使用C++17标准编译
   - 包含完整的错误处理和边界情况处理
   - 输出详细的搜索结果信息

要编译和运行此代码，可以使用以下命令：
```bash
g++ -std=c++17 -o boyer_moore boyer_moore.cpp
./boyer_moore
```

## 5. 代码解析和说明

以下是一个完整的Boyer-Moore算法实现，我们将逐段解析其核心逻辑：

```cpp
int boyerMoore(const string& text, const string& pattern) {
    int n = text.length();
    int m = pattern.length();
    if (m == 0) return 0;
    
    // 构建坏字符表
    vector<int> badChar(256, -1);
    for (int i = 0; i < m; i++) {
        badChar[(int)pattern[i]] = i;
    }
    
    // 构建好后缀表
    vector<int> goodSuffix(m + 1, 0);
    vector<int> borderPos(m + 1, 0);
    int i = m, j = m + 1;
    borderPos[i] = j;
    while (i > 0) {
        while (j <= m && pattern[i - 1] != pattern[j - 1]) {
            if (goodSuffix[j] == 0) {
                goodSuffix[j] = j - i;
            }
            j = borderPos[j];
        }
        i--;
        j--;
        borderPos[i] = j;
    }
    
    j = borderPos[0];
    for (i = 0; i <= m; i++) {
        if (goodSuffix[i] == 0) {
            goodSuffix[i] = j;
        }
        if (i == j) {
            j = borderPos[j];
        }
    }

    // 搜索过程
    int s = 0;
    while (s <= n - m) {
        int j = m - 1;
        while (j >= 0 && pattern[j] == text[s + j]) {
            j--;
        }
        if (j < 0) {
            return s;
        } else {
            int bcShift = j - badChar[text[s + j]];
            int gsShift = goodSuffix[j + 1];
            s += max(bcShift, gsShift);
        }
    }
    return -1;
}
```

**复杂度分析：**
- 时间复杂度：最好情况下O(n/m)，最坏情况下O(n+m)
- 预处理阶段：O(m+σ)，其中σ是字符集大小
- 空间复杂度：O(m+σ)，用于存储坏字符表和好后缀表

**边界情况处理：**
- 空模式串：直接返回0，因为空串总是出现在任何字符串的开头
- 模式串长度大于文本串：直接返回-1，表示未找到
- 字符超出ASCII范围：代码使用256大小的数组，适用于标准ASCII字符集

**关键实现细节：**
1. 坏字符表记录每个字符在模式串中最后出现的位置
2. 好后缀表使用边界位置算法进行高效构建
3. 搜索时同时考虑坏字符和好后缀规则，取较大偏移值
4. 匹配失败时，确保偏移量至少为1，避免无限循环

## 6. 使用场景和应用

Boyer-Moore算法凭借其高效的匹配性能，在多个领域得到了广泛应用。以下是一些典型的使用场景：

- **文本编辑器与IDE的搜索功能**：许多现代文本编辑器（如VS Code、Sublime Text）和集成开发环境（如Visual Studio）在实现文本搜索时采用Boyer-Moore或其变种算法，以快速定位关键词或代码片段。
- **数据处理与日志分析**：在大规模文本数据（如服务器日志、文档处理）中查找特定模式时，该算法的高效跳转能力能显著减少比较次数，提升处理速度。
- **网络安全与入侵检测**：网络包分析或恶意软件扫描中，常需在数据流中快速匹配特征字符串（如病毒签名），Boyer-Moore的预处理特性适合此类场景。
- **生物信息学**：在基因序列分析中搜索DNA或RNA片段时，该算法能高效处理长模式串的匹配问题。

### 优势与局限性
**优势**：
- 最坏情况下时间复杂度为O(n/m)，平均性能优于线性算法（如KMP）。
- 通过坏字符和好后缀规则跳转，实际比较次数少，尤其适合大字符集（如英文文本）。

**局限性**：
- 需要预处理构建跳转表，空间复杂度较高（O(m+σ)，σ为字符集大小）。
- 对极小模式串或频繁匹配的场景，预处理开销可能抵消性能收益。
- 不适用于某些扩展模式匹配（如正则表达式）。

### 替代方案比较
- **KMP算法**：保证最坏情况下O(n)时间复杂度，但无跳跃机制，平均性能常低于Boyer-Moore。适合模式串较小或字符集小的场景（如二进制匹配）。
- **Rabin-Karp算法**：通过哈希值快速比较，适合多模式匹配（如 plagiarism detection），但哈希冲突可能增加额外比较。
- **正则表达式引擎**：支持复杂模式，但通用实现（如PCRE）通常基于自动机，性能低于专门字符串算法。

以下是一个简单示例，展示Boyer-Moore在C++中的实用代码片段：

```cpp
#include <vector>
#include <string>
#include <algorithm>

void preprocessBadChar(const std::string& pattern, std::vector<int>& badChar) {
    int size = pattern.size();
    for (int i = 0; i < 256; i++) {
        badChar[i] = -1;
    }
    for (int i = 0; i < size; i++) {
        badChar[static_cast<int>(pattern[i])] = i;
    }
}

int boyerMooreSearch(const std::string& text, const std::string& pattern) {
    int n = text.size();
    int m = pattern.size();
    std::vector<int> badChar(256, -1);
    preprocessBadChar(pattern, badChar);

    int shift = 0;
    while (shift <= n - m) {
        int j = m - 1;
        while (j >= 0 && pattern[j] == text[shift + j]) {
            j--;
        }
        if (j < 0) {
            return shift; // 匹配成功
        } else {
            shift += std::max(1, j - badChar[text[shift + j]]);
        }
    }
    return -1; // 未找到
}
```

选择算法时，需结合实际数据特征：Boyer-Moore适合主串较长、字符集大的精确匹配，而需模糊匹配或多模式时则考虑其他方案。

## 7. 注意事项和最佳实践

在使用Boyer-Moore算法时，需要注意以下常见问题、优化建议和测试要点：

### 常见坑
- **坏字符规则冲突**：当坏字符在模式串中出现多次时，应选择最右侧的匹配位置，避免跳过过多字符导致遗漏匹配
- **好后缀规则边界条件**：处理好后缀表构建时需注意空后缀和完整后缀的处理，防止数组越界
- **Unicode字符处理**：处理多字节字符时，需要确保跳转计算的正确性，建议先将文本统一转换为字节序列

### 优化建议
1. **预处理优化**：预先计算并存储坏字符表和好后缀表，避免在搜索过程中重复计算
2. **内存使用**：对于短模式串，可考虑使用简化版的好后缀规则以减少内存开销
3. **算法组合**：在实际应用中可结合KMP算法，在特定情况下切换算法以获得更好性能

```cpp
// 坏字符表构建优化示例
void buildBadCharTable(const string& pattern, int badChar[256]) {
    int len = pattern.length();
    for (int i = 0; i < 256; i++) {
        badChar[i] = len;
    }
    for (int i = 0; i < len - 1; i++) {
        badChar[(int)pattern[i]] = len - 1 - i;
    }
}
```

### 测试要点
- **边界测试**：测试空字符串、单字符模式串、模式串与文本完全相等的情况
- **性能测试**：使用长文本和不同特征的模式串测试算法性能
- **正确性验证**：与简单字符串匹配算法对比结果，确保匹配位置的准确性
- **特殊字符测试**：测试包含数字、符号、Unicode字符等各种字符类型的情况

建议在实际应用前充分测试算法在各种场景下的表现，特别是处理大规模文本时的性能特征。

## 8. 相关知识点与延伸阅读

Boyer-Moore算法是字符串匹配领域的重要基础，了解以下相关概念和进阶方向将帮助你构建更完整的知识体系：

#### 相关概念
- **KMP算法**：另一种高效的单模式匹配算法，通过预处理模式串构建next数组，利用已匹配信息避免回溯
- **Rabin-Karp算法**：基于哈希的字符串匹配算法，通过滚动哈希快速比较模式串与文本子串
- **AC自动机**：多模式匹配算法，结合Trie树和KMP思想，可同时查找多个模式串
- **后缀自动机**：能高效解决多种字符串问题的数据结构，包括模式匹配、最长公共子串等

#### 进阶方向
- 学习Boyer-Moore的变种算法，如Boyer-Moore-Horspool简化版
- 研究如何将Boyer-Moore应用于多模式匹配场景
- 探索在特定领域（如DNA序列分析）中的优化应用
- 了解其他字符串匹配算法在不同场景下的性能对比

#### 参考资料
1. 《算法导论》第32章 - 详细讲解字符串匹配算法
2. Boyer和Moore的原始论文《A Fast String Searching Algorithm》
3. Stanford CS166课程《String Algorithms》中的相关章节
4. 在线可视化工具：可通过动画直观理解算法执行过程

```cpp
// 简单示例：Boyer-Moore基本框架
void boyerMoore(const string& text, const string& pattern) {
    int n = text.length();
    int m = pattern.length();
    
    // 预处理bad character表
    vector<int> badChar(256, -1);
    for (int i = 0; i < m; i++) {
        badChar[pattern[i]] = i;
    }
    
    // 主搜索逻辑
    int s = 0;
    while (s <= n - m) {
        int j = m - 1;
        while (j >= 0 && pattern[j] == text[s + j]) {
            j--;
        }
        
        if (j < 0) {
            cout << "Pattern found at index " << s << endl;
            s += (s + m < n) ? m - badChar[text[s + m]] : 1;
        } else {
            s += max(1, j - badChar[text[s + j]]);
        }
    }
}
```
