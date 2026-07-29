# AI 方向学习路线：每日任务版

> 更新时间：2026-07-29。适合目标：字节、阿里、腾讯 AI 方向校招/社招初中级岗位，包括大模型应用、RAG/Agent、LLM 后训练、AI Search、推荐、多模态、AI Infra 的入门到可投递路线。

这份路线解决一个问题：每天到底学什么，写什么代码，做到什么程度算过关。

如果你每天只有 2 小时，按“基础任务”做。如果你每天有 4 小时，基础任务做完后再做“加餐任务”。如果当天没做完，不要跳，第二天先补完再继续。

---

## 0. 总原则

### 0.1 先走通主线，再选分支

前 16 周不要过早纠结“我要做算法还是应用”。先把共同底座打好：

1. Python / Git / Linux / SQL。
2. 数据结构与算法。
3. 机器学习。
4. PyTorch。
5. Transformer / LLM 基础。
6. RAG。
7. Agent。
8. 评测与工程化。

第 17 周开始再选择分支：

- 应用向：RAG + Agent + AI Search + 工程化。
- 算法向：LLM 架构 + SFT + DPO + RLHF + 评测。
- 搜推向：搜索 + 推荐 + 广告 + LLM 意图理解。
- Infra 向：C++ + CUDA/Triton + vLLM + 分布式训练/推理。
- 多模态向：CV + CLIP/VLM + Diffusion + 视频/语音。

### 0.2 每天固定四件事

每天最少做这四件事：

1. 学一个知识点。
2. 写一段代码。
3. 做一道算法题或复盘一道旧题。
4. 写 5-10 行学习记录。

学习记录格式：

```md
日期：
今天学了：
今天写了：
今天卡住：
明天继续：
可写进简历的素材：
```

### 0.3 每周必须有产出

每周至少交付一个看得见的东西：

- 一份笔记。
- 一个小脚本。
- 一个模型训练结果。
- 一个接口。
- 一个评测表。
- 一个项目 README。

没有产出，只看视频不算完成。

---

# 第一阶段：编程、工具、算法地基，第 1-4 周

目标：能独立写 Python 小项目，熟悉 Git/Linux/SQL，算法进入节奏。

## 第 1 周：Python 从脚本到小项目

本周目标：会用 Python 写一个可运行、可测试、可维护的小工具。

### Day 1：环境与 Python 基础

学习内容：

- 安装 Python 3.11+。
- 学会创建虚拟环境。
- 学会 pip/uv 安装依赖。
- 变量、数字、字符串、list、dict、set、tuple。
- 输入输出和文件路径。

实操任务：

- 新建一个 `ai-learning-labs` 文件夹。
- 写 `hello_ai.py`，输出今天的学习计划。
- 写 `word_count.py`，读取一个 txt 文件并统计词频。

验收标准：

- 能在命令行运行脚本。
- 能解释 list 和 dict 的区别。
- 能解释虚拟环境为什么有必要。

算法任务：

- Two Sum。
- Contains Duplicate。

加餐任务：

- 学会 `argparse`，让 `word_count.py` 支持命令行参数。

### Day 2：函数、模块、异常

学习内容：

- 函数参数、返回值、默认参数。
- 模块导入。
- try/except。
- 自定义异常。

实操任务：

- 把 `word_count.py` 拆成函数。
- 新增一个 `file_utils.py`。
- 文件不存在时给出明确错误提示。

验收标准：

- 每个函数不超过 40 行。
- 函数名能表达用途。
- 错误信息人能看懂。

算法任务：

- Valid Anagram。
- Group Anagrams。

加餐任务：

- 给函数补类型标注。

### Day 3：面向对象与 dataclass

学习内容：

- class。
- `__init__`。
- 实例方法。
- dataclass。
- 对象和字典的区别。

实操任务：

- 实现一个 `Note` 类，字段包括 title、content、tags、created_at。
- 实现 `NoteRepository`，支持新增、列表、搜索。

验收标准：

- 能创建 3 条笔记。
- 能按关键词搜索标题和正文。
- 能解释类为什么比散乱 dict 更适合管理复杂数据。

算法任务：

- Valid Parentheses。
- Merge Two Sorted Lists。

加餐任务：

- 用 dataclass 重写 `Note`。

### Day 4：文件存储与 JSON

学习内容：

- 文件读写。
- JSON 序列化和反序列化。
- UTF-8 编码。
- 数据结构持久化。

实操任务：

- 把笔记保存到 `notes.json`。
- 程序启动时自动读取。
- 支持删除笔记。

验收标准：

- 重启程序后数据不丢失。
- 中文内容不乱码。
- 删除不存在的笔记时有提示。

算法任务：

- Best Time to Buy and Sell Stock。
- Move Zeroes。

加餐任务：

- 给 JSON 加版本字段，例如 `schema_version`。

### Day 5：测试与日志

学习内容：

- pytest。
- assert。
- logging。
- 单元测试和集成测试区别。

实操任务：

- 给 NoteRepository 写 8 个测试。
- 给新增、搜索、删除增加日志。

验收标准：

- `pytest` 能通过。
- 故意输入错误数据时，程序不崩溃。

算法任务：

- Majority Element。
- Intersection of Two Arrays。

加餐任务：

- 学会 pytest fixture。

### Day 6：命令行工具

学习内容：

- argparse。
- 子命令。
- README 写法。

实操任务：

- 给笔记工具增加命令行：`add`、`list`、`search`、`delete`。
- 写 README，包含安装、运行、示例。

验收标准：

- 不打开 IDE 也能用命令行操作笔记。
- README 中的命令能复制运行。

算法任务：

- 3Sum。
- Remove Duplicates from Sorted Array。

加餐任务：

- 支持按 tag 搜索。

### Day 7：周复盘

复盘任务：

- 整理本周 Python 知识点。
- 把笔记工具提交到 Git。
- 写一篇 `week01-python-note-tool.md`。

验收标准：

- Git 至少 5 个 commit。
- README 可读。
- 测试可运行。

本周产出：

- 一个 Python CLI 笔记工具。
- 一份 README。
- 一份周总结。
- 12 道算法题记录。

---

## 第 2 周：Git、Linux、SQL、工程习惯

本周目标：会管理代码，会用 SQL 存数据，会写基本后端数据逻辑。

### Day 8：Git 基础

学习内容：

- init、add、commit、status、log、diff。
- commit message。
- .gitignore。

实操任务：

- 把第 1 周项目规范化。
- 增加 `.gitignore`。
- 每完成一个小功能提交一次。

验收标准：

- 能看懂 `git log`。
- 能用 `git diff` 看修改。
- 能说清楚 commit 为什么要小。

算法任务：

- Binary Search。
- Search Insert Position。

### Day 9：Git 分支与回滚

学习内容：

- branch。
- checkout/switch。
- merge。
- revert。
- reset 的风险。
- stash。

实操任务：

- 新建分支 `feature/sqlite-storage`。
- 在分支上开发 SQLite 存储。
- 制造一次错误 commit，用 `git revert` 回滚。

验收标准：

- 能解释 revert 和 reset 的区别。
- 能解决一个简单冲突。

算法任务：

- Find First and Last Position of Element in Sorted Array。
- Search in Rotated Sorted Array。

### Day 10：Linux 命令

学习内容：

- ls、cd、pwd、mkdir、cp、mv。
- cat、less、head、tail。
- grep/rg。
- ps、kill。
- 环境变量。

实操任务：

- 用命令行查看项目文件。
- 用 rg 搜索函数名。
- 写一个 `run_tests.ps1` 或 `run_tests.sh`。

验收标准：

- 能不用 IDE 找到某段代码。
- 能解释环境变量是什么。

算法任务：

- Kth Largest Element in an Array。
- Top K Frequent Elements。

### Day 11：SQL 基础

学习内容：

- 表、字段、主键。
- insert/select/update/delete。
- where/order by/limit。
- count/group by。

实操任务：

- 用 SQLite 创建 notes 表。
- 把 JSON 存储替换成 SQLite。
- 支持按 title、tag 搜索。

验收标准：

- 数据存在 SQLite 中。
- 能用 SQL 查询笔记数量。
- 能解释主键作用。

算法任务：

- Merge Intervals。
- Insert Interval。

### Day 12：SQL 进阶

学习内容：

- join。
- index。
- unique constraint。
- transaction。
- window function 入门。

实操任务：

- 新增 tags 表和 note_tags 关联表。
- 给 title 创建索引。
- 新增唯一约束：同名笔记不能重复。

验收标准：

- 能解释多对多关系。
- 能解释唯一约束为什么应由数据库保证。
- 能写一次事务。

算法任务：

- Product of Array Except Self。
- Subarray Sum Equals K。

### Day 13：FastAPI 入门

学习内容：

- HTTP。
- GET/POST/DELETE。
- JSON API。
- FastAPI。
- Pydantic。

实操任务：

- 把笔记工具改成 API 服务。
- 实现创建笔记、查询笔记、删除笔记。
- 用 curl 或 Apifox/Postman 测试。

验收标准：

- API 能启动。
- Swagger 页面可访问。
- 错误请求返回明确错误。

算法任务：

- Linked List Cycle。
- Reverse Linked List。

### Day 14：周复盘

复盘任务：

- 整理 Git 常用命令表。
- 整理 SQL 常用语句表。
- 给笔记 API 写 README。
- 给 API 写 5 个测试。

本周产出：

- 一个 SQLite + FastAPI 笔记服务。
- 一份 Git/SQL 笔记。
- 12 道算法题记录。

---

## 第 3 周：数学与机器学习预备

本周目标：能理解机器学习里的矩阵、概率、损失函数、梯度下降。

### Day 15：线性代数 1

学习内容：

- 向量。
- 矩阵。
- 矩阵乘法。
- 转置。
- 点积。

实操任务：

- 用 numpy 实现向量点积和矩阵乘法。
- 不用 numpy 再手写一版小矩阵乘法。

验收标准：

- 能解释为什么神经网络里到处是矩阵乘法。

算法任务：

- Maximum Subarray。
- Maximum Product Subarray。

### Day 16：线性代数 2

学习内容：

- 范数。
- 距离。
- 余弦相似度。
- 特征值直觉。

实操任务：

- 实现 cosine similarity。
- 用余弦相似度做一个简单文本相似度比较。

验收标准：

- 能解释 embedding 检索为什么常用余弦相似度。

算法任务：

- Climbing Stairs。
- House Robber。

### Day 17：概率统计 1

学习内容：

- 随机变量。
- 均值、方差。
- 条件概率。
- 贝叶斯公式。

实操任务：

- 用 Python 模拟抛硬币、掷骰子。
- 统计均值和方差。

验收标准：

- 能解释训练集采样为什么会有随机性。

算法任务：

- Coin Change。
- Combination Sum。

### Day 18：概率统计 2

学习内容：

- 正态分布。
- 伯努利分布。
- 最大似然估计。
- 交叉熵。

实操任务：

- 手写 binary cross entropy。
- 画出预测概率变化时 loss 如何变化。

验收标准：

- 能解释模型越自信但越错，loss 为什么越大。

算法任务：

- Longest Increasing Subsequence。
- Word Break。

### Day 19：优化基础

学习内容：

- 导数。
- 梯度。
- 梯度下降。
- 学习率。
- 局部最优。

实操任务：

- 手写梯度下降拟合 `y = 3x + 2`。
- 尝试不同学习率。

验收标准：

- 能解释学习率过大震荡、过小收敛慢。

算法任务：

- Unique Paths。
- Minimum Path Sum。

### Day 20：从数学到模型

学习内容：

- 特征。
- 标签。
- loss。
- optimizer。
- train/valid/test。

实操任务：

- 手写线性回归。
- 手写逻辑回归。

验收标准：

- 能输出训练 loss 曲线。
- 能解释过拟合和欠拟合。

算法任务：

- Decode Ways。
- Jump Game。

### Day 21：周复盘

复盘任务：

- 写一篇《机器学习数学最小必要知识》。
- 把线性回归、逻辑回归代码整理成 notebook。
- 回顾本周 12 道算法题。

本周产出：

- 数学基础笔记。
- 线性回归和逻辑回归手写代码。
- 12 道算法题记录。

---

## 第 4 周：算法第一轮强化

本周目标：把常见算法模式跑一遍，形成题型意识。

### Day 22：数组与哈希

学习内容：

- 哈希表计数。
- 前缀和。
- 去重。

练习题：

- Two Sum。
- 3Sum。
- Subarray Sum Equals K。
- Longest Consecutive Sequence。

验收标准：

- 能说清楚什么时候用哈希。
- 能说清楚前缀和为什么能优化子数组问题。

### Day 23：双指针与滑动窗口

学习内容：

- 左右指针。
- 快慢指针。
- 可变窗口。
- 固定窗口。

练习题：

- Container With Most Water。
- Longest Substring Without Repeating Characters。
- Minimum Window Substring。
- Permutation in String。

验收标准：

- 能判断窗口什么时候扩大、什么时候收缩。

### Day 24：链表

学习内容：

- dummy node。
- 快慢指针。
- 原地反转。

练习题：

- Reverse Linked List。
- Merge Two Sorted Lists。
- Linked List Cycle。
- Remove Nth Node From End of List。

验收标准：

- 能画图解释链表指针变化。

### Day 25：栈与单调栈

学习内容：

- 普通栈。
- 单调递增栈。
- 单调递减栈。

练习题：

- Valid Parentheses。
- Min Stack。
- Daily Temperatures。
- Largest Rectangle in Histogram。

验收标准：

- 能解释单调栈保存的是什么信息。

### Day 26：二分与堆

学习内容：

- 二分边界。
- 答案二分。
- 小顶堆和大顶堆。

练习题：

- Binary Search。
- Search in Rotated Sorted Array。
- Kth Largest Element in an Array。
- Merge K Sorted Lists。

验收标准：

- 二分不靠背模板，能说明区间含义。

### Day 27：树和图

学习内容：

- DFS。
- BFS。
- 层序遍历。
- 拓扑排序。

练习题：

- Binary Tree Level Order Traversal。
- Lowest Common Ancestor。
- Number of Islands。
- Course Schedule。

验收标准：

- 能区分树 DFS 和图 DFS 为什么图要 visited。

### Day 28：动态规划入门

学习内容：

- 状态定义。
- 状态转移。
- 初始化。
- 遍历顺序。

练习题：

- Climbing Stairs。
- Coin Change。
- Longest Increasing Subsequence。
- Edit Distance。

验收标准：

- 每题能写出状态定义和转移方程。

本周产出：

- 算法模式笔记。
- 28 道题记录。
- 常用模板代码。

---

# 第二阶段：机器学习、搜索推荐、数据工程，第 5-8 周

目标：会做传统机器学习项目，理解搜索推荐，这是字节/阿里/腾讯 AI 应用和商业 AI 的共同底座。

## 第 5 周：机器学习完整项目

### Day 29：机器学习项目流程

学习内容：

- 问题定义。
- 数据集划分。
- 特征和标签。
- baseline。
- 指标。

实操任务：

- 选择 Titanic、房价预测、用户点击预测任一数据集。
- 完成数据读取和基本统计。

验收标准：

- 输出数据字段说明。
- 输出缺失率和标签分布。

算法任务：

- 复盘哈希题 3 道。

### Day 30：特征工程

学习内容：

- 缺失值处理。
- 类别特征编码。
- 数值标准化。
- 时间特征。
- 文本长度特征。

实操任务：

- 给数据集做 10 个特征。
- 记录每个特征的含义。

验收标准：

- 特征处理代码可重复运行。
- 训练集和测试集没有数据泄漏。

算法任务：

- 复盘滑动窗口题 3 道。

### Day 31：线性模型与树模型

学习内容：

- Logistic Regression。
- Decision Tree。
- Random Forest。
- GBDT。
- LightGBM/XGBoost。

实操任务：

- 训练 3 个模型并比较指标。

验收标准：

- 输出 AUC、F1、Precision、Recall。
- 输出特征重要性。

算法任务：

- 复盘二分题 3 道。

### Day 32：评估指标

学习内容：

- Accuracy。
- Precision/Recall。
- F1。
- ROC/AUC。
- PR-AUC。
- 混淆矩阵。

实操任务：

- 给模型输出完整评估报告。
- 尝试调整阈值。

验收标准：

- 能解释业务上为什么有时 Recall 比 Precision 更重要。

算法任务：

- 复盘链表题 3 道。

### Day 33：过拟合与调参

学习内容：

- 过拟合。
- 正则化。
- 交叉验证。
- Grid Search。
- Early Stopping。

实操任务：

- 调 LightGBM 参数。
- 对比训练集和验证集指标。

验收标准：

- 能解释模型过拟合证据。
- 能给出 3 个缓解方法。

算法任务：

- 复盘树题 3 道。

### Day 34：项目整理

实操任务：

- 整理 notebook。
- 写 README。
- 输出模型报告。
- 保存模型文件。

验收标准：

- 别人能根据 README 复现。
- 报告中有图表和结论。

算法任务：

- 复盘 DP 题 3 道。

### Day 35：周复盘

复盘问题：

- 你的 baseline 是什么？
- 哪个特征最重要？
- 模型有没有过拟合？
- AUC 提升是否可信？
- 如果上线，如何监控模型效果？

本周产出：

- 一个完整机器学习项目。
- 一份评估报告。
- 18 道算法复盘。

---

## 第 6 周：推荐系统入门项目

### Day 36：推荐系统基本概念

学习内容：

- 用户、物品、行为。
- 显式反馈和隐式反馈。
- 召回、排序、重排。
- 冷启动。

实操任务：

- 下载 MovieLens 或自造小型电商点击数据。
- 统计用户数、物品数、交互数、稀疏度。

验收标准：

- 能画出用户行为分布和物品热度分布。

算法任务：

- Top K Frequent Elements。
- Kth Largest Element。

### Day 37：ItemCF

学习内容：

- 物品相似度。
- 共现矩阵。
- 余弦相似度。

实操任务：

- 实现 ItemCF 推荐。
- 给每个用户推荐 Top 10。

验收标准：

- 能解释热门物品偏置。
- 输出 Recall@10。

算法任务：

- Merge K Sorted Lists。
- Find Median from Data Stream。

### Day 38：矩阵分解

学习内容：

- user embedding。
- item embedding。
- 负采样。
- BPR loss。

实操任务：

- 用 PyTorch 实现简单矩阵分解。

验收标准：

- loss 能下降。
- 推荐结果不是全热门。

算法任务：

- Binary Tree Level Order Traversal。
- Maximum Depth of Binary Tree。

### Day 39：Two-Tower

学习内容：

- 双塔模型。
- 召回向量。
- 负样本。
- ANN 检索。

实操任务：

- 实现用户塔和物品塔。
- 训练后导出 item embedding。

验收标准：

- 能按用户向量检索相似物品。
- 输出 Recall@K。

算法任务：

- Lowest Common Ancestor。
- Diameter of Binary Tree。

### Day 40：排序模型

学习内容：

- CTR 预估。
- 特征拼接。
- LightGBM 排序。
- AUC。

实操任务：

- 构造用户-物品特征。
- 训练点击预测模型。

验收标准：

- 输出 AUC。
- 输出特征重要性。

算法任务：

- Number of Islands。
- Course Schedule。

### Day 41：推荐系统评估

学习内容：

- Recall@K。
- Precision@K。
- NDCG@K。
- MRR。
- 离线评估局限。

实操任务：

- 对 ItemCF、矩阵分解、Two-Tower 做统一评估。

验收标准：

- 有对比表。
- 能解释为什么离线高不等于线上好。

算法任务：

- Word Ladder。
- Clone Graph。

### Day 42：周复盘

复盘问题：

- 召回和排序有什么区别？
- Two-Tower 为什么适合大规模召回？
- 负采样怎么影响结果？
- 推荐系统如何处理新用户？

本周产出：

- 推荐系统 mini 项目。
- ItemCF、MF、Two-Tower 三个 baseline。
- 推荐评估报告。

---

## 第 7 周：搜索系统与 AI Search 基础

### Day 43：搜索引擎基础

学习内容：

- 倒排索引。
- 分词。
- TF-IDF。
- BM25。
- Query。
- Document。

实操任务：

- 准备 100 篇文档。
- 用 Whoosh、Elasticsearch 或 OpenSearch 建索引。

验收标准：

- 支持关键词搜索。
- 返回标题、摘要、得分。

算法任务：

- Trie 实现。

### Day 44：BM25 与相关性

学习内容：

- BM25 直觉。
- 词频饱和。
- 文档长度归一。

实操任务：

- 对比短 query 和长 query 的搜索结果。
- 手动标注 20 条 query 的相关文档。

验收标准：

- 能解释为什么关键词匹配不等于语义相关。

算法任务：

- Implement Trie。
- Word Search。

### Day 45：向量检索

学习内容：

- Embedding。
- 余弦相似度。
- ANN。
- HNSW。
- FAISS/Qdrant/Milvus。

实操任务：

- 用 sentence-transformers 生成文档向量。
- 建一个向量搜索接口。

验收标准：

- 输入自然语言能搜到语义相近文档。

算法任务：

- Pacific Atlantic Water Flow。

### Day 46：混合检索

学习内容：

- BM25 + Vector。
- score normalization。
- Reciprocal Rank Fusion。
- 多路召回。

实操任务：

- 实现 BM25 和向量检索融合。
- 对比单路和融合效果。

验收标准：

- 输出 Recall@5 对比表。

算法任务：

- Accounts Merge。

### Day 47：Rerank

学习内容：

- Cross Encoder。
- Bi Encoder。
- reranker 的位置。
- 召回和精排。

实操任务：

- 加入 reranker。
- 对 Top 20 结果重排。

验收标准：

- 对 20 条 query 人工观察前后变化。
- 写出 5 个提升案例和 5 个失败案例。

算法任务：

- Network Delay Time。

### Day 48：AI Search 雏形

学习内容：

- Query rewrite。
- Answer generation。
- Citation。
- 无答案拒答。

实操任务：

- 搜索后调用 LLM 生成答案。
- 答案必须引用文档。

验收标准：

- 至少 30 条测试问题。
- 统计答案正确率和引用正确率。

算法任务：

- Alien Dictionary，可选 hard。

### Day 49：周复盘

复盘问题：

- BM25 适合什么问题？
- 向量检索适合什么问题？
- 为什么需要 rerank？
- AI Search 和传统搜索最大差异是什么？

本周产出：

- 一个基础 AI Search 系统。
- 30 条评测 query。
- 检索评估表。

---

## 第 8 周：数据工程与数据质量

### Day 50：数据清洗

学习内容：

- 缺失值。
- 重复数据。
- 异常值。
- 数据类型。
- 编码问题。

实操任务：

- 清洗一份商品或文档数据。
- 输出数据质量报告。

验收标准：

- 报告包含缺失率、重复率、异常样本示例。

### Day 51：文本数据处理

学习内容：

- HTML 清洗。
- Markdown 清洗。
- 正则。
- 分句。
- 去重。

实操任务：

- 写文档清洗 pipeline。
- 清洗网页正文、标题、段落。

验收标准：

- 清洗前后样例对比清晰。

### Day 52：数据集划分

学习内容：

- train/valid/test。
- 时间切分。
- 用户切分。
- 数据泄漏。

实操任务：

- 为推荐数据做时间切分。
- 为问答数据做评测集切分。

验收标准：

- 能解释为什么随机切分有时会泄漏。

### Day 53：标注与评测集

学习内容：

- Golden Set。
- 人工标注。
- 一致性。
- 难度分层。

实操任务：

- 为 RAG 项目构造 50 条评测问题。
- 标注标准答案和来源文档。

验收标准：

- 每条问题有问题类型、标准答案、证据段落。

### Day 54：大模型数据格式

学习内容：

- instruction/input/output。
- conversations。
- chosen/rejected。
- tool call trace。

实操任务：

- 构造 100 条 SFT 样本。
- 构造 50 条偏好样本。

验收标准：

- 数据能被脚本校验。
- 输出 JSONL。

### Day 55：数据闭环

学习内容：

- 用户反馈。
- badcase。
- 日志表。
- trace_id。
- 回归测试。

实操任务：

- 为 AI Search 系统增加反馈记录。
- 设计 badcase 表结构。

验收标准：

- 能记录 query、answer、context、feedback、error_type。

### Day 56：周复盘

本周产出：

- 文档清洗 pipeline。
- RAG 评测集 50 条。
- SFT 数据 100 条。
- 偏好数据 50 条。
- 数据质量报告。

---

# 第三阶段：PyTorch、深度学习、Transformer，第 9-12 周

目标：不再只会调用模型 API，开始理解模型是怎么训练和推理的。

## 第 9 周：PyTorch 基础训练循环

每天安排：

- Day 57：Tensor、shape、broadcast，写 20 个 tensor 操作练习。
- Day 58：autograd，手写一个二次函数优化过程。
- Day 59：Dataset/DataLoader，封装自己的 CSV 数据集。
- Day 60：nn.Module，写 MLP 分类模型。
- Day 61：optimizer、scheduler、loss，训练 MNIST。
- Day 62：checkpoint、eval mode、no_grad，保存和加载模型。
- Day 63：复盘训练循环，整理 PyTorch 模板。

本周验收：

- 能独立写出训练循环。
- 能解释 `model.train()` 和 `model.eval()`。
- 能解释梯度清零为什么必要。
- 有一个 MNIST 或 CIFAR10 分类项目。

## 第 10 周：深度学习结构

每天安排：

- Day 64：MLP，理解激活函数 ReLU/GELU/Sigmoid。
- Day 65：CNN，训练 CIFAR10，小结卷积核、stride、padding。
- Day 66：RNN/LSTM，做文本分类或时间序列预测。
- Day 67：Attention，手写 scaled dot-product attention。
- Day 68：Transformer Encoder，做文本分类。
- Day 69：Normalization、Dropout、Residual，做消融实验。
- Day 70：整理模型结构对比表。

本周验收：

- 能讲清楚 CNN、RNN、Attention 的适用场景。
- 能手写 attention 核心代码。
- 能解释残差连接为什么重要。

## 第 11 周：Transformer Decoder 与语言模型

每天安排：

- Day 71：Tokenizer，理解 BPE、WordPiece、SentencePiece。
- Day 72：Embedding 和位置编码，手写 sinusoidal positional encoding。
- Day 73：Masked Self-Attention，理解 causal mask。
- Day 74：Transformer Block，组合 attention、MLP、norm、residual。
- Day 75：语言模型训练目标，next token prediction。
- Day 76：跑通 nanoGPT 或 tiny transformer。
- Day 77：整理 Transformer 架构图和源码笔记。

本周验收：

- 能解释 Decoder-only 模型如何生成文本。
- 能解释 causal mask。
- 能解释训练和推理的区别。

## 第 12 周：LLM 架构和 Hugging Face

每天安排：

- Day 78：Hugging Face Transformers 基础，加载 tokenizer/model。
- Day 79：文本生成参数，temperature、top_p、top_k、max tokens。
- Day 80：KV Cache，理解 prefill/decode。
- Day 81：RoPE、RMSNorm、SwiGLU、GQA/MQA 概念。
- Day 82：PEFT/LoRA 入门，跑一个最小微调样例。
- Day 83：模型评测脚本，固定 prompt 比较 base 和 lora 输出。
- Day 84：整理 LLM 基础面试问答 30 个。

本周验收：

- 能跑通开源 LLM 推理。
- 能完成一次 LoRA demo。
- 能讲清楚 KV Cache、LoRA、RoPE 的直觉。

---

# 第四阶段：RAG、Agent、评测工程，第 13-16 周

目标：做出第一个能投简历的大模型应用项目。

## 第 13 周：基础 RAG 项目

每天安排：

- Day 85：搭建 FastAPI 项目结构，定义文档上传接口。
- Day 86：实现 PDF/Markdown/TXT 解析，保存原文和元数据。
- Day 87：实现 chunk，记录 chunk_id、doc_id、位置、标题。
- Day 88：接入 embedding 模型，生成向量。
- Day 89：接入 FAISS/Qdrant/Milvus 任一向量库。
- Day 90：实现检索接口，返回 TopK chunk。
- Day 91：接入 LLM 生成答案，答案带引用。

本周验收：

- 能上传文档。
- 能检索文档。
- 能回答问题。
- 回答中有引用。

## 第 14 周：高级 RAG

每天安排：

- Day 92：加入 BM25 检索。
- Day 93：实现 BM25 + 向量融合。
- Day 94：接入 reranker。
- Day 95：实现 query rewrite。
- Day 96：实现无答案拒答。
- Day 97：构造 100 条评测集。
- Day 98：输出评测报告。

本周验收：

- Recall@5 有统计。
- 引用准确率有统计。
- 拒答准确率有统计。
- 有 badcase 表。

## 第 15 周：Agent 工具调用

每天安排：

- Day 99：定义 Tool 接口，统一输入输出。
- Day 100：实现 calculator 工具。
- Day 101：实现 SQL 查询工具。
- Day 102：实现文档搜索工具。
- Day 103：实现 Markdown 报告生成工具。
- Day 104：实现 ReAct 调用循环。
- Day 105：记录 tool call trace。

本周验收：

- Agent 能调用至少 4 个工具。
- 工具调用有日志。
- 失败时能重试或给出原因。

## 第 16 周：评测、可观测性、工程化

每天安排：

- Day 106：加入 trace_id，把一次请求所有日志串起来。
- Day 107：记录 token 用量、耗时、模型名、工具调用次数。
- Day 108：写端到端测试 30 条。
- Day 109：增加 prompt regression 测试。
- Day 110：Docker 化项目。
- Day 111：写完整 README 和架构图。
- Day 112：整理简历项目描述。

本周验收：

- 项目能一键启动。
- 有测试集。
- 有指标表。
- 有 README。
- 可以写进简历。

---

# 第五阶段：分支深入，第 17-24 周

从这里开始选择方向。建议只选一个主分支，另一个作为辅助。

## 分支 A：大模型应用 / Agent 工程，第 17-24 周

### 第 17 周：复杂任务规划

- Day 113：学习 Plan-and-Execute。
- Day 114：把用户问题拆成子任务。
- Day 115：实现任务队列和状态机。
- Day 116：支持长任务暂停和恢复。
- Day 117：实现人工确认节点。
- Day 118：写 20 条复杂任务测试。
- Day 119：输出任务成功率报告。

### 第 18 周：Memory 与个性化

- Day 120：学习短期记忆和长期记忆。
- Day 121：实现会话摘要。
- Day 122：实现用户偏好存储。
- Day 123：实现记忆检索。
- Day 124：防止错误记忆污染。
- Day 125：加入记忆开关和删除能力。
- Day 126：写 Memory badcase 分析。

### 第 19 周：多 Agent 协作

- Day 127：学习 planner、executor、critic 角色。
- Day 128：实现 planner agent。
- Day 129：实现 executor agent。
- Day 130：实现 critic agent。
- Day 131：实现协作协议。
- Day 132：比较单 Agent 和多 Agent。
- Day 133：输出实验报告。

### 第 20 周：MCP 与工具生态

- Day 134：学习 MCP 基本概念。
- Day 135：接入文件系统工具。
- Day 136：接入数据库工具。
- Day 137：接入搜索工具。
- Day 138：实现工具权限控制。
- Day 139：实现工具调用审计日志。
- Day 140：整理 MCP 工具接入文档。

### 第 21 周：Agent 安全

- Day 141：学习 prompt injection。
- Day 142：构造 20 条攻击样本。
- Day 143：实现输入过滤。
- Day 144：实现工具权限白名单。
- Day 145：实现敏感信息脱敏。
- Day 146：跑安全评测。
- Day 147：输出安全报告。

### 第 22 周：成本与性能

- Day 148：统计 token 成本。
- Day 149：实现上下文压缩。
- Day 150：实现缓存。
- Day 151：实现模型路由，小任务用小模型。
- Day 152：压测并发。
- Day 153：优化 P95 延迟。
- Day 154：输出成本优化表。

### 第 23 周：业务化项目

- Day 155：选择业务场景：企业知识库、会议纪要、数据分析、客服、代码助手。
- Day 156：写需求文档。
- Day 157：补齐核心功能。
- Day 158：补齐异常流程。
- Day 159：补齐评测集。
- Day 160：录制 demo 或截图。
- Day 161：整理项目文档。

### 第 24 周：投递级打磨

- Day 162：项目 README 重写。
- Day 163：架构图重画。
- Day 164：指标表补齐。
- Day 165：badcase 分析补齐。
- Day 166：简历描述压缩到 5 行。
- Day 167：准备 10 分钟项目讲解。
- Day 168：模拟面试。

## 分支 B：LLM 后训练 / 算法方向，第 17-24 周

### 第 17 周：SFT 数据与训练

- 学会 instruction 数据格式。
- 构造 1000 条领域数据。
- 跑 LoRA SFT。
- 记录训练参数：模型、数据量、batch、lr、epoch、max length、显存。
- 输出 base 和 SFT 对比。

### 第 18 周：评测集建设

- 构造 200 条固定评测。
- 分为事实问答、推理、格式遵循、拒答、安全。
- 写自动评测脚本。
- 输出准确率、格式合规率、拒答准确率。

### 第 19 周：偏好数据与 DPO

- 构造 chosen/rejected 数据。
- 学 DPO loss 直觉。
- 跑 DPO。
- 比较 SFT 和 DPO 输出风格。
- 写 badcase。

### 第 20 周：RLHF/RL 入门

- 学 policy、reward、value、advantage。
- 学 PPO 和 KL penalty。
- 理解 GRPO 为什么适合大模型推理类任务。
- 不追求大规模训练，但要能讲清流程。

### 第 21 周：Code Agent 实验

- 选择 HumanEval/MBPP 小样本。
- 让模型生成代码。
- 自动运行测试。
- 根据错误反馈修复。
- 统计 pass@1。

### 第 22 周：训练稳定性

- 实验不同学习率。
- 实验不同 LoRA rank。
- 实验不同数据质量。
- 分析 loss spike。
- 分析过拟合。

### 第 23 周：安全对齐

- 构造拒答样本。
- 构造 prompt injection 样本。
- 评估模型安全边界。
- 记录误拒和漏拒。

### 第 24 周：算法岗项目报告

- 写实验背景。
- 写数据构造。
- 写训练参数。
- 写评测结果。
- 写 badcase。
- 写局限和下一步。

## 分支 C：AI Search / 推荐 / 广告，第 17-24 周

### 第 17 周：商品/内容搜索

- 建商品库或文章库。
- 实现 BM25。
- 实现向量召回。
- 实现融合排序。
- 构造 100 条 query。

### 第 18 周：Learning to Rank

- 构造 query-doc 特征。
- 训练 LightGBM Ranker。
- 输出 NDCG@10。
- 分析排序失败案例。

### 第 19 周：推荐召回

- 实现 ItemCF。
- 实现 Two-Tower。
- 建 ANN 索引。
- 输出 Recall@K。

### 第 20 周：推荐排序

- 构造 CTR 特征。
- 训练 LightGBM/DeepFM。
- 输出 AUC。
- 做特征重要性分析。

### 第 21 周：LLM 意图理解

- 把自然语言 query 解析成结构化条件。
- 识别预算、品牌、场景、偏好。
- 用解析结果改写搜索。

### 第 22 周：AI 导购 Agent

- 工具 1：商品搜索。
- 工具 2：商品比较。
- 工具 3：价格过滤。
- 工具 4：推荐理由生成。
- 工具 5：用户反馈记录。

### 第 23 周：评测与业务指标

- Recall@20。
- NDCG@10。
- AUC。
- 推荐理由准确率。
- 人工偏好胜率。

### 第 24 周：项目打磨

- 写架构图。
- 写数据流。
- 写模型方案。
- 写指标表。
- 写简历描述。

## 分支 D：AI Infra，第 17-24 周

### 第 17 周：C++ 基础

- C++ 语法。
- STL。
- 指针和引用。
- RAII。
- 智能指针。
- CMake。
- 用 C++ 刷 10 道算法题。

### 第 18 周：Linux 与性能工具

- 进程线程。
- 内存。
- top/htop。
- nvidia-smi。
- perf。
- 日志和监控。

### 第 19 周：vLLM 部署

- 部署开源模型。
- OpenAI-compatible API。
- 流式输出。
- 并发请求。
- 压测脚本。

### 第 20 周：推理性能分析

- prefill。
- decode。
- KV Cache。
- batch size。
- max tokens。
- P95 延迟。

### 第 21 周：量化

- FP16。
- INT8。
- INT4。
- GPTQ/AWQ 概念。
- 对比显存、速度、质量。

### 第 22 周：CUDA/Triton 入门

- GPU 线程模型。
- block/thread/grid。
- shared memory。
- 写 vector add。
- 写简单 matmul 或调用 Triton 教程。

### 第 23 周：分布式训练概念

- DDP。
- FSDP。
- ZeRO。
- Tensor Parallel。
- Pipeline Parallel。
- NCCL。

### 第 24 周：Infra 项目报告

- QPS。
- Tokens/s。
- P95/P99。
- 显存。
- GPU 利用率。
- 优化前后对比。

---

# 第六阶段：作品集、面试、投递，第 25-32 周

目标：把学习成果变成能面试、能投递、能讲清楚的材料。

## 第 25 周：算法二轮

每天任务：

- 每天 3 道 medium。
- 每天复盘 1 道旧错题。
- 每题写复杂度。
- 每题口述一遍。

本周重点：

- 滑动窗口。
- 二分。
- 树。
- 图。
- DP。

验收标准：

- 一周 21 道题。
- 至少 15 道能 30 分钟内写出。

## 第 26 周：算法三轮与模拟

每天任务：

- 每天 2 道限时题。
- 每天 1 次 45 分钟模拟。
- 每天整理一道经典题模板。

验收标准：

- 形成算法模板文档。
- 常见题型能讲思路。

## 第 27 周：ML/DL/LLM 面试题

每天任务：

- Day 183：机器学习 20 问。
- Day 184：深度学习 20 问。
- Day 185：Transformer 20 问。
- Day 186：RAG 20 问。
- Day 187：Agent 20 问。
- Day 188：推荐/搜索 20 问。
- Day 189：复盘不会的问题。

验收标准：

- 形成 120 问问答卡片。
- 每个问题能 2 分钟内讲清楚。

## 第 28 周：项目一打磨

任务：

- 选择最强项目作为主项目。
- README 重写。
- 架构图重画。
- 增加运行截图。
- 增加评测表。
- 增加 badcase。
- 增加未来优化。

验收标准：

- 面试官 3 分钟能看懂项目价值。
- 自己 10 分钟能讲清楚细节。

## 第 29 周：项目二打磨

任务：

- 选择第二项目作为差异化项目。
- 应用岗建议：AI Search / Agent。
- 算法岗建议：LoRA + DPO。
- 搜推岗建议：推荐排序 / AI 导购。
- Infra 岗建议：vLLM 压测优化。

验收标准：

- 第二项目和第一项目不要重复。
- 两个项目能体现不同能力。

## 第 30 周：简历

每天任务：

- Day 204：整理个人信息、教育经历、技能。
- Day 205：写项目 1。
- Day 206：写项目 2。
- Day 207：写项目 3，可选。
- Day 208：压缩到 1 页。
- Day 209：针对字节版本改一版。
- Day 210：针对阿里和腾讯各改一版。

验收标准：

- 每个项目都有指标。
- 每个项目都有你的贡献。
- 每个项目都有难点和解决方案。

## 第 31 周：公司定向准备

### 字节准备重点

- 算法题速度。
- 大模型基础。
- Agent/RL/评测。
- 系统设计。
- 快速迭代和数据驱动。

准备动作：

- 复盘 RAG/Agent 项目。
- 准备 Code Agent 或 Search Agent 讲法。
- 准备 3 个指标优化案例。

### 阿里准备重点

- AI + 业务场景。
- 搜索推荐/电商/广告。
- Qwen/Wan/Agentic 方向理解。
- 数据闭环。
- 工程可靠性。

准备动作：

- 把项目包装成“业务问题 -> AI 方案 -> 指标收益”。
- 准备 AI 导购、企业搜索、Agent 安全相关问题。

### 腾讯准备重点

- LLM/NLP。
- 多模态/语音/视觉。
- 搜索推荐。
- 内容、社交、游戏、数字人场景。
- 稳定性和用户体验。

准备动作：

- 准备模型应用如何接入真实产品。
- 准备多模态或推荐项目讲法。

## 第 32 周：模拟面试与投递

每天任务：

- Day 218：算法模拟 1 次。
- Day 219：项目模拟 1 次。
- Day 220：ML/LLM 八股模拟 1 次。
- Day 221：系统设计模拟 1 次。
- Day 222：修改简历和项目文档。
- Day 223：投递第一批岗位。
- Day 224：记录投递表，准备后续复盘。

验收标准：

- 能稳定完成 45 分钟技术面。
- 能讲清楚 2 个项目。
- 能回答岗位匹配问题。
- 有投递记录表。

---

# 附录 A：每个方向的最低可投递标准

## 大模型应用 / RAG / Agent

最低标准：

- Python/FastAPI 熟练。
- 做过一个 RAG 项目。
- 知道 chunk、embedding、向量库、BM25、rerank、引用、拒答。
- 做过 Agent 工具调用。
- 有评测集和 badcase。

能加分：

- 有 MCP、LangGraph、任务状态机。
- 有监控、成本、延迟优化。
- 有安全防护。

## LLM 后训练 / 算法

最低标准：

- PyTorch 熟练。
- Transformer 能讲清楚。
- 跑过 LoRA SFT。
- 有评测集。
- 知道 DPO/RLHF 基本流程。

能加分：

- 有 DPO 实验。
- 有 Code Agent 或 Tool-use 数据。
- 有训练稳定性分析。

## AI Search / 推荐

最低标准：

- 会 BM25、向量检索、rerank。
- 会 Recall@K、NDCG、AUC。
- 做过推荐 baseline。
- 知道召回、粗排、精排。

能加分：

- 做过 AI 导购。
- 做过 LLM Query Understanding。
- 有反馈闭环。

## AI Infra

最低标准：

- Linux、Docker、Python 熟练。
- C++ 基础扎实。
- 部署过 vLLM。
- 能压测 QPS/P95/显存。
- 知道 KV Cache、Continuous Batching、量化。

能加分：

- CUDA/Triton。
- DeepSpeed/FSDP。
- 读过 vLLM 或 TensorRT-LLM 源码。

## 多模态 / 语音

最低标准：

- CV 基础。
- CLIP/VLM 用过。
- 做过图文检索或文档多模态 RAG。
- 了解 Diffusion 或 Whisper。

能加分：

- 视频理解。
- TTS/ASR 闭环。
- 数字人链路。

---

# 附录 B：每周复盘模板

```md
# Week xx 复盘

## 本周目标

## 完成情况

## 学到的知识

## 写了哪些代码

## 算法题清单

## 项目进展

## 指标变化

## Badcase

## 下周计划

## 简历素材
```

---

# 附录 C：投递前检查表

- 简历是否 1 页。
- 每个项目是否有指标。
- 每个项目是否能讲 10 分钟。
- 是否有 GitHub/代码仓库。
- README 是否能让别人跑起来。
- 是否有评测集。
- 是否有 badcase。
- 是否有算法题记录。
- 是否准备了 3 个公司定向版本。
- 是否能解释为什么投这个岗位。

---

# 附录 D：最小资源清单

只用这些也够入门：

- Python：官方教程 + 自己写项目。
- 算法：LeetCode 热题 100 + 代码随想录/灵茶题单任选一个。
- 机器学习：CS229 笔记 + Hands-On Machine Learning。
- 深度学习：Dive into Deep Learning + PyTorch 官方教程。
- NLP/LLM：CS224N + Hugging Face Course + nanoGPT。
- RAG/Agent：LlamaIndex/LangChain/LangGraph 文档 + 自建项目。
- 搜索：Elasticsearch/OpenSearch 文档 + FAISS/Qdrant/Milvus 文档。
- 后训练：Transformers + PEFT + TRL。
- Infra：vLLM 文档 + DeepSpeed 文档 + CUDA/Triton 入门。

---

# 附录 E：最终建议

如果你现在基础一般，最推荐执行顺序是：

1. 第 1-4 周不要碰大模型框架，先把 Python、SQL、Git、算法打牢。
2. 第 5-8 周做传统机器学习、搜索、推荐，因为这些是 AI 岗的底层业务能力。
3. 第 9-12 周学 PyTorch 和 Transformer，避免只会调用 API。
4. 第 13-16 周做 RAG + Agent，这是最快能形成作品集的方向。
5. 第 17 周以后再按岗位选择深挖方向。
6. 最终至少准备两个项目：一个大模型应用项目，一个体现差异化的算法/搜索/Infra/多模态项目。

真正能通过面试的路线，不是“看完多少课”，而是你能不能拿出项目、指标、badcase 和复盘。每天都要把学习转成产出。