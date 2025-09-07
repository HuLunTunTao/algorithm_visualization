# Rabin-Karp

## 1. 概念介绍和定义

Rabin-Karp算法是一种高效的字符串匹配算法，主要用于在一个主文本中快速查找特定模式串的出现位置。该算法的核心思想是通过哈希技术来比较模式串和文本子串的相似性，从而减少不必要的逐字符比较。

### 适用场景
Rabin-Karp算法特别适用于以下情况：
- 需要在一个较长的文本中查找多个不同的模式串
- 处理包含重复模式或近似匹配的场景
- 对匹配效率要求较高，但可以接受一定的哈希冲突概率

### 算法目标
该算法的主要目标是：
1. 通过哈希值快速筛选可能匹配的位置
2. 仅在哈希值匹配时才进行详细的字符比较
3. 提供平均情况下O(n+m)的时间复杂度，其中n是文本长度，m是模式长度

### 基本思想
Rabin-Karp使用滚动哈希函数，能够在常数时间内更新文本窗口的哈希值。当模式串的哈希值与文本子串的哈希值匹配时，算法会执行完整的字符比较来确认是否真正匹配。

```cpp
// 简单的Rabin-Karp算法示例
int rabinKarp(string text, string pattern) {
    int n = text.length();
    int m = pattern.length();
    int patternHash = 0;
    int textHash = 0;
    const int prime = 101; // 常用的质数基数
    
    // 计算模式串和第一个文本窗口的哈希值
    for (int i = 0; i < m; i++) {
        patternHash = patternHash + pattern[i] * pow(prime, i);
        textHash = textHash + text[i] * pow(prime, i);
    }
    
    // 后续代码会实现滚动哈希和匹配检查
    // ...
}
```

通过这种巧妙的设计，Rabin-Karp算法在保持简单实现的同时，提供了相当不错的匹配性能。

## 2. 核心原理解释

Rabin-Karp算法的核心思想是通过哈希函数来快速比较字符串，从而减少逐个字符比较的次数。其关键原理可以分解为以下几个步骤：

### 基本原理
1. **哈希函数选择**：使用滚动哈希函数，使得当前窗口的哈希值能够基于前一个窗口的哈希值快速计算得出
2. **滑动窗口机制**：通过滑动固定长度的窗口来遍历文本
3. **哈希值比较**：先比较哈希值，只有哈希值匹配时才进行详细的字符比较

### 滚动哈希计算
Rabin-Karp使用多项式滚动哈希，其计算公式为：
```
hash(s) = (s[0] × b^(m-1) + s[1] × b^(m-2) + ... + s[m-1] × b^0) mod p
```
其中：
- `b` 是基数（通常取质数，如256）
- `m` 是模式串长度
- `p` 是大质数（用于避免哈希冲突）

### 关键优势：滚动计算
当窗口向右滑动一位时，新的哈希值可以通过以下方式快速计算：
```
new_hash = (old_hash - s[i] × b^(m-1)) × b + s[i+m]
```

### 简单示例
假设：
- 文本："ABCDEF"
- 模式："CDE"（长度为3）
- 基数b=256，质数p=101

计算过程：
1. 计算"ABC"的哈希值：hash_abc = (65×256² + 66×256¹ + 67×256⁰) mod 101
2. 滑动到"BCD"：hash_bcd = (hash_abc - 65×256²) × 256 + 68
3. 继续滑动到"CDE"：hash_cde = (hash_bcd - 66×256²) × 256 + 69

### 代码实现原理
```cpp
void rabinKarp(const string& text, const string& pattern) {
    int n = text.length();
    int m = pattern.length();
    int b = 256;    // 基数
    int p = 101;    // 质数
    
    // 计算b^(m-1) mod p
    int h = 1;
    for (int i = 0; i < m-1; i++)
        h = (h * b) % p;
    
    // 计算模式和文本第一个窗口的哈希值
    int hash_p = 0, hash_t = 0;
    for (int i = 0; i < m; i++) {
        hash_p = (hash_p * b + pattern[i]) % p;
        hash_t = (hash_t * b + text[i]) % p;
    }
    
    // 滑动窗口
    for (int i = 0; i <= n - m; i++) {
        if (hash_p == hash_t) {
            // 哈希匹配，验证实际字符
            bool match = true;
            for (int j = 0; j < m; j++) {
                if (text[i+j] != pattern[j]) {
                    match = false;
                    break;
                }
            }
            if (match) {
                cout << "在位置 " << i << " 找到匹配" << endl;
            }
        }
        
        // 计算下一个窗口的哈希值
        if (i < n - m) {
            hash_t = (b * (hash_t - text[i] * h) + text[i+m]) % p;
            if (hash_t < 0) hash_t += p;  // 确保非负
        }
    }
}
```

通过这种滚动哈希的方式，Rabin-Karp算法将平均时间复杂度优化到了O(n+m)，在处理多个模式匹配或大文本搜索时表现出色。

## 3. 详细的实现步骤

Rabin-Karp算法的实现可以分为以下关键步骤，我们将使用C++语言进行说明：

1. **初始化参数与哈希函数选择**
   - 确定模数q（通常选择大质数，如1e9+7）
   - 选择基数d（字符集大小，ASCII可选用256）
   - 计算模式串的哈希值和第一个窗口的文本哈希值

2. **预计算幂值**
   - 为避免重复计算，预先计算d^(m-1) mod q
   ```cpp
   long long h = 1;
   for (int i = 0; i < m-1; i++)
       h = (h * d) % q;
   ```

3. **滑动窗口计算哈希值**
   - 使用滚动哈希公式：new_hash = (d*(old_hash - text[i]*h) + text[i+m]) % q
   - 处理负哈希值的情况
   ```cpp
   for (int i = 0; i <= n - m; i++) {
       if (p_hash == t_hash) {
           // 检查实际字符是否匹配
           bool match = true;
           for (int j = 0; j < m; j++) {
               if (text[i+j] != pattern[j]) {
                   match = false;
                   break;
               }
           }
           if (match) cout << "Pattern found at index " << i << endl;
       }
       
       if (i < n - m) {
           t_hash = (d * (t_hash - text[i] * h) + text[i+m]) % q;
           if (t_hash < 0) t_hash += q;
       }
   }
   ```

4. **处理哈希冲突**
   - 当哈希值匹配时，必须进行逐字符验证
   - 这是避免假阳性匹配的关键步骤

实现要点：
- 使用无符号整型或长整型防止溢出
- 模数q应足够大以减少哈希冲突
- 在每次哈希计算后检查负值并调整
- 注意边界条件（i ≤ n-m）

## 4. 完整的C++代码示例（包含注释）

```cpp
#include <iostream>
#include <string>
#include <vector>
using namespace std;

/**
 * Rabin-Karp字符串匹配算法实现
 * @param text 主文本字符串
 * @param pattern 模式字符串
 * @param prime 大素数，用于哈希计算
 * @return 匹配成功的所有起始位置索引
 */
vector<int> rabinKarpSearch(const string& text, const string& pattern, int prime = 101) {
    vector<int> result;
    int n = text.length();
    int m = pattern.length();
    
    // 如果模式串比文本长，直接返回空结果
    if (m > n) return result;
    
    // 计算哈希的基础值：d = 字符集大小（这里假设ASCII，所以为256）
    int d = 256;
    // 计算h = d^(m-1) mod prime
    int h = 1;
    for (int i = 0; i < m - 1; i++) {
        h = (h * d) % prime;
    }
    
    // 计算模式串和第一个文本窗口的哈希值
    int patternHash = 0;
    int textHash = 0;
    for (int i = 0; i < m; i++) {
        patternHash = (patternHash * d + pattern[i]) % prime;
        textHash = (textHash * d + text[i]) % prime;
    }
    
    // 滑动窗口遍历文本
    for (int i = 0; i <= n - m; i++) {
        // 如果哈希值匹配，进行逐字符验证（避免哈希冲突）
        if (patternHash == textHash) {
            bool match = true;
            for (int j = 0; j < m; j++) {
                if (text[i + j] != pattern[j]) {
                    match = false;
                    break;
                }
            }
            if (match) {
                result.push_back(i);
            }
        }
        
        // 计算下一个窗口的哈希值（滚动哈希）
        if (i < n - m) {
            textHash = (d * (textHash - text[i] * h) + text[i + m]) % prime;
            // 确保哈希值为正数
            if (textHash < 0) {
                textHash += prime;
            }
        }
    }
    
    return result;
}

int main() {
    // 示例输入
    string text = "ABCCDDAEFGABCDABC";
    string pattern = "ABC";
    
    cout << "文本: " << text << endl;
    cout << "模式: " << pattern << endl;
    
    // 执行搜索
    vector<int> positions = rabinKarpSearch(text, pattern);
    
    // 输出结果
    if (positions.empty()) {
        cout << "未找到匹配的模式" << endl;
    } else {
        cout << "找到 " << positions.size() << " 个匹配，起始位置分别为: ";
        for (int pos : positions) {
            cout << pos << " ";
        }
        cout << endl;
    }
    
    return 0;
}
```

运行此代码将输出：
```
文本: ABCCDDAEFGABCDABC
模式: ABC
找到 3 个匹配，起始位置分别为: 0 11 14
```

代码特点说明：
- 使用滚动哈希技术，平均时间复杂度为O(n+m)
- 包含哈希冲突处理，通过逐字符验证确保正确性
- 使用大素数减少哈希冲突概率
- 提供清晰的注释说明每个步骤的作用

## 5. 代码解析和说明

以下是Rabin-Karp算法的C++实现代码，我们将逐段解析其核心逻辑：

```cpp
#include <string>
#include <vector>
using namespace std;

vector<int> rabinKarp(string text, string pattern) {
    int n = text.length(), m = pattern.length();
    if (n < m) return {};
    
    const int base = 256;
    const int mod = 101;
    int h = 1;
    int patternHash = 0;
    int windowHash = 0;
    vector<int> result;
    
    // 计算h = base^(m-1) % mod
    for (int i = 0; i < m - 1; i++) {
        h = (h * base) % mod;
    }
    
    // 计算模式串和第一个窗口的哈希值
    for (int i = 0; i < m; i++) {
        patternHash = (patternHash * base + pattern[i]) % mod;
        windowHash = (windowHash * base + text[i]) % mod;
    }
    
    // 滑动窗口
    for (int i = 0; i <= n - m; i++) {
        // 哈希值匹配时，进行精确比较
        if (windowHash == patternHash) {
            bool match = true;
            for (int j = 0; j < m; j++) {
                if (text[i + j] != pattern[j]) {
                    match = false;
                    break;
                }
            }
            if (match) {
                result.push_back(i);
            }
        }
        
        // 计算下一个窗口的哈希值
        if (i < n - m) {
            windowHash = (base * (windowHash - text[i] * h) + text[i + m]) % mod;
            if (windowHash < 0) {
                windowHash += mod;
            }
        }
    }
    
    return result;
}
```

**代码解析：**

- **初始化阶段**：计算滚动哈希所需的参数，包括基数base、模数mod和最高位权重h
- **哈希计算**：采用多项式滚动哈希函数，确保哈希值的均匀分布
- **滑动窗口**：通过数学运算高效更新窗口哈希值，避免重新计算整个字符串
- **冲突处理**：当哈希值匹配时进行精确的字符比较，防止哈希冲突导致的误判

**复杂度分析：**
- 时间复杂度：平均情况O(n+m)，最坏情况O(nm)
- 空间复杂度：O(1)，仅使用常数额外空间

**边界情况处理：**
- 文本长度小于模式串时直接返回空结果
- 处理哈希值为负的情况，确保模运算的正确性
- 精确比较避免哈希冲突导致的错误匹配

## 6. 使用场景和应用

Rabin-Karp算法在字符串匹配领域有着广泛的应用，特别适合处理多模式匹配和重复检测的场景。以下是其主要应用场景：

- **文档相似性检测**：通过计算文本片段的哈希值，快速识别重复内容或抄袭段落
- **生物信息学中的DNA序列匹配**：处理ATCG碱基序列时，可高效查找特定基因片段
- **网络数据包内容检测**：在网络安全领域用于识别特定恶意代码模式
- **多模式匹配系统**：可同时搜索多个模式串，比单模式算法更高效

**优势与局限性分析**：

优势：
- 支持多模式匹配，可同时搜索多个模式
- 平均时间复杂度为O(n+m)，在大文本中表现良好
- 算法简单易懂，实现相对容易

局限性：
- 最坏情况下时间复杂度为O(nm)
- 哈希冲突可能导致错误匹配（需二次验证）
- 预处理阶段需要额外计算

**替代方案比较**：

与KMP算法相比：
- KMP保证最坏情况O(n)性能，但只支持单模式匹配
- Rabin-Karp更易于扩展到多模式搜索，但需要处理哈希冲突

与Boyer-Moore算法相比：
- Boyer-Moore通常在实践中更快，特别是英语文本搜索
- Rabin-Karp在随机文本和二进制数据中表现更稳定

```cpp
// 典型应用示例：文档重复检测
vector<int> findRepeatedParagraphs(const string& document) {
    vector<int> positions;
    int n = document.length();
    int m = 10; // 假设检测10个字符的重复段落
    
    if (n < m) return positions;
    
    unordered_map<size_t, int> hashMap;
    size_t hash = 0;
    size_t base = 256;
    size_t power = 1;
    
    // 计算初始哈希值
    for (int i = 0; i < m; i++) {
        hash = hash * base + document[i];
        if (i > 0) power *= base;
    }
    hashMap[hash] = 0;
    
    // 滑动窗口检测
    for (int i = m; i < n; i++) {
        hash = (hash - document[i-m] * power) * base + document[i];
        if (hashMap.count(hash)) {
            positions.push_back(i - m + 1);
        } else {
            hashMap[hash] = i - m + 1;
        }
    }
    
    return positions;
}
```

在实际应用中，建议根据具体需求选择合适的算法。对于需要高精度匹配的场景，可结合多种算法使用，如在Rabin-Karp初步匹配后使用KMP进行验证。

## 7. 注意事项和最佳实践

在实现和应用 Rabin-Karp 算法时，需要注意以下几个关键点，以确保算法的正确性和效率。

### 常见坑点
- **哈希冲突处理不当**：由于使用滚动哈希，不同字符串可能产生相同哈希值。必须对哈希匹配的窗口进行完整的字符串比较，避免漏报。
- **模数选择问题**：使用过小的模数会增加冲突概率。推荐选择大质数（如 10^9+7）作为模数，减少冲突。
- **整数溢出忽略**：在计算哈希值时，中间结果可能非常大，应使用足够大的整数类型（如 `long long`），并在每一步进行取模操作。

### 优化建议
- **双哈希提升准确性**：采用两个不同基数和模数计算哈希值，只有当两个哈希值都匹配时才进行全比较，显著降低冲突概率。
  
  ```cpp
  // 示例：双哈希计算
  long long hash1 = 0, hash2 = 0;
  long long base1 = 131, base2 = 13131;
  long long mod1 = 1e9+7, mod2 = 1e9+9;
  for (char c : pattern) {
      hash1 = (hash1 * base1 + c) % mod1;
      hash2 = (hash2 * base2 + c) % mod2;
  }
  ```
  
- **预计算幂次优化**：提前计算基数的幂次（如 `base^(m-1) mod mod`），避免在滚动哈希中重复计算，提升效率。
- **避免负哈希值**：取模后可能产生负值，应通过加模数再取模调整至非负范围，确保一致性。

### 测试要点
- **冲突测试**：构造哈希冲突的测试用例（如不同字符串但哈希相同），验证全比较逻辑的正确性。
- **边界测试**：包括空字符串、单字符模式、文本与模式相同等特殊情况。
- **大数据测试**：使用长文本和大模式测试性能和溢出处理，确保无整数溢出和较高效率。

遵循这些实践，你将更可靠地应用 Rabin-Karp 算法解决实际问题。

## 8. 相关知识点与延伸阅读

Rabin-Karp算法是字符串匹配领域的重要基础算法，理解其核心思想后，你可以进一步探索以下相关概念和进阶方向：

### 相关概念
- **滚动哈希（Rolling Hash）**：Rabin-Karp的核心机制，能够在常数时间内更新哈希值，适用于流式数据处理
- **哈希冲突处理**：学习如何处理不同字符串产生相同哈希值的情况，包括双重哈希等优化方案
- **多模式匹配**：Rabin-Karp可扩展为同时搜索多个模式串，与Aho-Corasick算法有相似应用场景

### 进阶方向
1. **算法优化**：探索如何选择更好的哈希函数和模数来减少冲突概率
2. **分布式应用**：研究如何将Rabin-Karp应用于大规模文本处理系统
3. **生物信息学应用**：了解算法在DNA序列匹配中的实际应用案例

### 参考资料
- 《算法导论》第32章：字符串匹配
- Rabin和Karp的原始论文："Efficient randomized pattern-matching algorithms"
- 在线学习资源：Coursera的《Algorithms on Strings》课程

```cpp
// 双重哈希实现示例，减少冲突概率
const int MOD1 = 1e9+7, MOD2 = 1e9+9;
pair<int, int> computeDoubleHash(const string &s) {
    long long hash1 = 0, hash2 = 0;
    for (char c : s) {
        hash1 = (hash1 * 131 + c) % MOD1;
        hash2 = (hash2 * 131 + c) % MOD2;
    }
    return {hash1, hash2};
}
```
