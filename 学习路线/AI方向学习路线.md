# AI 方向学习路线

目标：面向字节、阿里、腾讯等大厂 AI 方向岗位，系统学习 AI 应用工程、LLM 应用、Agent、RAG、机器学习算法、推荐/搜索算法所需能力。路线强调循序渐进：先能写代码和处理数据，再理解机器学习和深度学习，再做大模型应用、微调、评测和工程部署。

## 一、总路线

| 阶段 | 建议时间 | 目标 |
|---|---:|---|
| 1. 编程与工具基础 | 2-4 周 | 熟练使用 Python、Git、Linux、SQL |
| 2. 数据结构与算法 | 8-12 周，贯穿全程 | 能完成大厂常见中等算法题 |
| 3. 数学与机器学习基础 | 4-6 周 | 理解模型训练、评估、调参与特征工程 |
| 4. 深度学习与 PyTorch | 4-6 周 | 能独立训练、保存、评估神经网络模型 |
| 5. 大模型基础与 LLM 应用 | 6-8 周 | 掌握 Transformer、Prompt、RAG、Agent |
| 6. 微调、评测与数据工程 | 4-6 周 | 能做 LoRA/SFT、评测集、Badcase 闭环 |
| 7. 推荐/搜索/广告算法 | 4-6 周 | 覆盖大厂业务算法岗常见技术 |
| 8. 工程化与简历项目 | 4-6 周 | 把项目部署成可演示、可讲述的作品 |

建议每天 2-4 小时，周末集中做项目。算法每天坚持，项目每周都要有可见产出。

---

## 二、阶段 1：编程与工具基础

### 1. Python

必须学习：

- 基础语法：变量、类型、条件、循环、函数、异常。
- 常用数据结构：list、dict、set、tuple。
- 文件处理：txt、csv、json、目录遍历。
- 常用标准库：os、pathlib、json、csv、datetime、re、collections、heapq、bisect、itertools。
- 面向对象：类、对象、继承、组合。
- 包管理：pip、venv、requirements.txt。

练习：

- 写一个日志分析脚本，统计错误类型和 Top N。
- 写一个岗位 JD 关键词提取脚本。
- 写一个批量读取文件并生成统计报告的脚本。

### 2. NumPy / Pandas

必须学习：

- NumPy 数组、矩阵运算、广播、随机数。
- Pandas DataFrame、筛选、排序、分组、聚合、缺失值处理。
- CSV、Excel、JSON 的读取和导出。

练习：

- 收集岗位数据，统计公司、城市、岗位方向、技能词频。
- 清洗岗位描述里的重复文本和空字段。

### 3. Git

必须学习：

- git status、git add、git commit、git diff、git log。
- branch、merge、pull、push。
- 解决简单冲突。

练习：

- 给每个学习项目建仓库。
- 每完成一个功能提交一次 commit。

### 4. Linux

必须学习：

- pwd、ls、cd、mkdir、cp、mv。
- cat、less、head、tail。
- grep、find、rg。
- ps、top、kill。
- curl 调接口。

练习：

- 在 Linux 环境启动一个 Python 服务。
- 用 curl 调试接口。
- 用日志定位错误。

### 5. SQL

必须学习：

- SELECT、WHERE、ORDER BY、GROUP BY、HAVING。
- JOIN、子查询、聚合函数。
- 索引的基本概念。

练习：

- 设计用户表、岗位表、投递记录表。
- 查询每个城市岗位数量。
- 查询技能关键词和岗位数量关系。

阶段验收：做一个“岗位数据分析工具”，输入岗位 CSV，输出公司分布、城市分布、技能词频和岗位方向统计。

---

## 三、阶段 2：数据结构与算法

目标不是竞赛，而是大厂面试。重点是中等题稳定通过，能讲清楚思路、复杂度和边界条件。

### 1. 数组与字符串

学习内容：

- 遍历、原地修改、双指针、滑动窗口、前缀和、差分数组。

典型题：

- 两数之和、三数之和、最长无重复子串、最小覆盖子串、合并区间、最大子数组和。

掌握标准：

- 知道什么时候用双指针。
- 知道什么时候用滑动窗口。
- 知道前缀和如何把区间查询降为 O(1)。

### 2. 哈希表

学习内容：

- 计数、去重、映射、快速查找。

典型题：

- 字母异位词分组、最长连续序列、和为 K 的子数组、LRU Cache。

掌握标准：

- 能用空间换时间。
- 能把 O(n^2) 查找优化为 O(n)。

### 3. 栈与队列

学习内容：

- 普通栈、单调栈、普通队列、单调队列。

典型题：

- 有效括号、最小栈、每日温度、接雨水、滑动窗口最大值。

掌握标准：

- 单调栈解决“下一个更大/更小元素”。
- 单调队列解决窗口最值。

### 4. 链表

学习内容：

- 反转链表、快慢指针、环检测、合并链表、删除节点。

典型题：

- 反转链表、合并两个有序链表、环形链表、相交链表、删除倒数第 N 个节点。

掌握标准：

- 会使用 dummy 节点简化边界。
- 会用快慢指针解决中点、环、倒数问题。

### 5. 二叉树

学习内容：

- 前序、中序、后序、层序遍历。
- DFS、BFS、递归返回值设计。

典型题：

- 最大深度、对称二叉树、层序遍历、路径总和、最近公共祖先、验证二叉搜索树。

掌握标准：

- 能写递归。
- 能说明当前节点向父节点返回什么。
- 能用 BFS 处理层级问题。

### 6. 二分查找

学习内容：

- 标准二分、左边界、右边界、二分答案。

典型题：

- 搜索旋转排序数组、查找元素第一个和最后一个位置、爱吃香蕉的珂珂、分割数组最大值。

掌握标准：

- 能判断问题是否有单调性。
- 能写清楚边界。

### 7. 堆与 Top K

学习内容：

- 小顶堆、大顶堆、优先队列、Top K、合并 K 路。

典型题：

- 第 K 个最大元素、前 K 个高频元素、合并 K 个升序链表、数据流中位数。

### 8. 图

学习内容：

- 邻接表、DFS、BFS、拓扑排序、并查集、最短路基础。

典型题：

- 岛屿数量、课程表、腐烂的橘子、单词接龙、冗余连接。

### 9. 动态规划

学习内容：

- 状态定义、状态转移、初始化、遍历顺序、空间优化。

典型题：

- 爬楼梯、打家劫舍、最长递增子序列、最长公共子序列、编辑距离、0/1 背包、完全背包。

刷题建议：

- 第 1 个月：数组、字符串、哈希表、双指针、滑动窗口。
- 第 2 个月：链表、栈、队列、二叉树、二分、堆。
- 第 3 个月：图、动态规划、综合题。
- 总量：120 道必刷，150-200 道更稳。

---

## 四、阶段 3：数学与机器学习基础

### 1. 数学基础

线性代数：

- 向量、矩阵、矩阵乘法、点积、范数、特征值直觉。

概率统计：

- 条件概率、贝叶斯公式、期望、方差、常见分布、最大似然估计。

最优化：

- 梯度、梯度下降、学习率、SGD、Adam。

重点是理解模型训练的直觉，不要一开始陷入证明。

### 2. 机器学习

必须学习：

- 训练集、验证集、测试集。
- 欠拟合、过拟合、正则化。
- 特征工程。
- 分类、回归、聚类。
- 模型评估。

常见模型：

- 线性回归、逻辑回归、决策树、随机森林、GBDT、XGBoost、LightGBM、KMeans。

指标：

- Accuracy、Precision、Recall、F1、ROC-AUC、PR-AUC、MSE、MAE。

项目：岗位匹配分类器。

步骤：

1. 收集 200-500 条岗位 JD。
2. 人工标注岗位类别。
3. 文本清洗。
4. 提取 TF-IDF 或关键词特征。
5. 训练逻辑回归、随机森林、LightGBM。
6. 比较模型效果。
7. 输出混淆矩阵。
8. 分析错误样本。

---

## 五、阶段 4：深度学习与 PyTorch

### 1. 深度学习基础

必须学习：

- 神经元、MLP、激活函数、损失函数、优化器、反向传播直觉、Dropout、BatchNorm。

### 2. PyTorch

必须学习：

- Tensor、autograd、nn.Module、Dataset、DataLoader。
- 训练循环、验证循环、模型保存、模型加载、GPU 训练。

### 3. NLP 与 CV 基础

NLP：

- 分词、词向量、RNN/LSTM 了解、Attention、Transformer 入门。

CV 了解：

- CNN、ResNet、ViT、图像分类。

项目：文本分类深度学习版。

步骤：

1. 准备文本分类数据。
2. 分词和构造词表。
3. 实现 Dataset 和 DataLoader。
4. 搭建 Embedding + Pooling + MLP。
5. 训练模型。
6. 评估 Accuracy 和 F1。
7. 保存模型。
8. 写推理脚本。

进阶：使用 BERT/RoBERTa 做分类，并和传统机器学习模型对比。

---

## 六、阶段 5：大模型基础与 LLM 应用

### 1. 大模型核心概念

必须学习：

- Token、Tokenizer、Embedding。
- Transformer、Self-Attention、Multi-Head Attention、FFN、LayerNorm、Residual Connection。
- RoPE、Decoder-only、KV Cache、Context Length。
- Temperature、Top-p、Top-k。

你要能讲清楚：

- 为什么大模型输入输出是 token。
- Attention 在解决什么问题。
- KV Cache 为什么能加速推理。
- 上下文长度为什么有限。

### 2. Prompt Engineering

必须学习：

- 角色提示、任务提示、Few-shot、结构化输出、JSON 输出约束、幻觉控制、提示词评测。

练习：

- 岗位 JD 分析提示词。
- 简历优化提示词。
- 代码审查提示词。
- 稳定输出 JSON 的提示词。

### 3. RAG

必须学习：

- 文档切分、Embedding、向量检索、Top K、Rerank、上下文拼接、引用来源、幻觉控制、检索评估。

常用技术：

- LangChain 或 LlamaIndex。
- FAISS、Milvus 或 Chroma。
- bge embedding、reranker。
- FastAPI。

项目：企业知识库 RAG 问答系统。

功能：

1. 支持上传 Markdown、PDF、TXT。
2. 自动切分文档。
3. 生成向量并入库。
4. 用户提问后检索相关片段。
5. 调用大模型生成答案。
6. 答案附带引用来源。
7. 支持多轮对话。
8. 记录问题、答案、命中文档、用户反馈。
9. 支持 Badcase 分析。

验收标准：

- 能演示完整流程。
- 能说明 Chunk 大小、Top K、Rerank 对效果的影响。
- 能展示至少 10 个 Badcase 和改进方法。

### 4. Agent

必须学习：

- Tool Calling、Function Calling、Planning、Memory、工具参数校验、工具失败恢复、工具结果总结。

项目：AI 求职助手 Agent。

功能：

1. 输入目标岗位。
2. 自动分析 JD 技术栈。
3. 和用户现有技能做 Gap 分析。
4. 生成学习计划。
5. 生成简历修改建议。
6. 生成面试题。
7. 调用工具保存学习任务。

---

## 七、阶段 6：微调、评测与数据工程

### 1. 数据工程

必须学习：

- 数据收集、清洗、去重、格式统一、指令数据构造、训练/验证/测试划分、数据质量检查、敏感信息处理。

常见格式：

```json
{"instruction": "...", "input": "...", "output": "..."}
```

或：

```json
{"messages": [{"role": "user", "content": "..."}, {"role": "assistant", "content": "..."}]}
```

### 2. 微调

必须学习：

- SFT、LoRA、QLoRA、DPO 基础。
- 学习率、Batch Size、Epoch、梯度累积、Checkpoint。

常用工具：

- Hugging Face Transformers、PEFT、TRL、datasets。

项目：垂直领域助手微调。

可选方向：

- SQL 助手。
- 简历优化助手。
- 代码审查助手。
- 产品需求分析助手。
- 客服问答助手。

步骤：

1. 准备 500-2000 条高质量指令数据。
2. 选择 Qwen/Llama 小模型。
3. 用 LoRA 做 SFT。
4. 构造评测集。
5. 比较微调前后效果。
6. 分析失败案例。
7. 写训练报告。

### 3. 模型评测

必须学习：

- 准确性、完整性、一致性、幻觉率、格式遵循率、人工评测、LLM-as-Judge、A/B 对比。

评测集要覆盖：

- 简单问题、中等问题、边界问题、对抗问题、格式要求问题、多轮上下文问题。

---

## 八、阶段 7：推荐、搜索与广告算法

### 1. 推荐系统

必须学习：

- 用户画像、物品画像、协同过滤、召回、粗排、精排、重排、冷启动、多样性。

常见模型：

- ItemCF、UserCF、Matrix Factorization、Word2Vec 召回、DSSM、DeepFM、DIN、Two Tower。

指标：

- Recall@K、Precision@K、NDCG、Hit Rate、AUC、CTR、CVR。

项目：岗位推荐系统。

功能：

1. 用户输入技能、城市、目标岗位。
2. 系统召回匹配岗位。
3. 排序模型给出推荐列表。
4. 输出推荐理由。
5. 记录点击和收藏。
6. 支持离线评估。

### 2. 搜索算法

必须学习：

- 倒排索引、BM25、Query 理解、召回、排序、Rerank、语义搜索、向量检索、混合检索。

项目：岗位搜索引擎。

功能：

1. 关键词搜索。
2. 技能、城市、公司过滤。
3. BM25 排序。
4. 向量语义搜索。
5. 混合排序。
6. 搜索结果解释。

### 3. 广告算法，了解

学习：

- CTR 预估、CVR 预估、出价、eCPM、转化漏斗、A/B Test。

---

## 九、阶段 8：工程化、部署与简历项目

### 1. 后端接口

学习：

- FastAPI、REST API、Pydantic、异常处理、日志、文件上传、后台任务。

### 2. 数据存储

学习：

- SQLite、PostgreSQL/MySQL、Redis、FAISS/Milvus/Chroma。

### 3. 部署

学习：

- Docker、Docker Compose、环境变量、日志查看、服务重启、基础压测。

### 4. 推理服务

学习：

- vLLM、流式输出、并发请求、超时控制、Token 使用统计。

### 5. 最终项目组合

最终简历最好有 3 个项目：

1. 企业知识库 RAG 系统。
2. 垂直领域 LoRA 微调助手。
3. 岗位推荐/搜索系统。

每个项目都要准备：

- 背景。
- 目标。
- 架构。
- 技术选型。
- 数据来源。
- 核心难点。
- 解决方案。
- 指标提升。
- Badcase。
- 下一步优化。

简历不要写：

```txt
使用 LangChain 搭建 RAG 系统。
```

要写：

```txt
设计并实现企业知识库 RAG 系统，支持 Markdown/PDF 文档解析、Chunk 切分、Embedding 入库、TopK 检索、Rerank 和引用来源展示；构建 80 条评测问题集，通过调整 Chunk Size、检索 TopK 和 Rerank 策略，将答案命中率从 X% 提升到 Y%。
```

---

## 十、C++ 学习策略

C++ 不一定是第一主线。

如果目标是 LLM 应用、RAG、Agent、AI 产品工程、推荐/搜索业务算法，前期 Python 更重要。

如果目标是大模型推理优化、机器学习系统、CUDA 算子、机器人、自动驾驶、搜索引擎底层，C++ 很重要。

建议后置学习：

第一层：基础语法和 STL。

- 变量、函数、类、指针、引用。
- vector、string、unordered_map、set、queue、priority_queue、sort。

第二层：用 C++ 刷算法题。

第三层：系统方向再学内存管理、多线程、网络编程、CUDA、TensorRT、Triton Kernel。

---

## 十一、6 个月详细计划

### 第 1 个月：Python、SQL、算法入门

第 1 周：Python 基础、文件读写、JSON、CSV、Git、数组字符串题。

第 2 周：Pandas、SQL 基础、哈希表、双指针。

第 3 周：Linux、API 请求、滑动窗口、前缀和。

第 4 周：完成岗位数据分析小项目，复盘 20-30 道算法题。

### 第 2 个月：机器学习基础

第 1 周：训练集/验证集/测试集、线性回归、逻辑回归。

第 2 周：决策树、随机森林、GBDT、AUC、F1、Recall、链表和栈队列。

第 3 周：特征工程、XGBoost/LightGBM、二叉树。

第 4 周：完成岗位分类器项目，写项目报告。

### 第 3 个月：深度学习与 PyTorch

第 1 周：神经网络、Loss、Optimizer、反向传播直觉。

第 2 周：PyTorch Tensor、Dataset、DataLoader、训练循环。

第 3 周：文本分类模型、模型保存推理、二分和堆。

第 4 周：用 BERT/RoBERTa 做文本分类，对比传统 ML。

### 第 4 个月：大模型应用

第 1 周：Transformer、Attention、Tokenizer、Decoder-only。

第 2 周：Prompt Engineering、结构化输出、模型参数调节。

第 3 周：RAG 基础、文档切分、Embedding、向量检索。

第 4 周：完成 RAG 系统第一版。

### 第 5 个月：Agent、微调与评测

第 1 周：Tool Calling、Function Calling、Agent 架构。

第 2 周：给 RAG 系统增加工具调用、日志和错误恢复。

第 3 周：LoRA/SFT、指令数据构造。

第 4 周：完成垂直领域助手微调小项目，写评测报告。

### 第 6 个月：推荐搜索、部署和面试

第 1 周：推荐系统基础、召回、排序、评估指标。

第 2 周：岗位推荐/搜索系统，BM25 + 向量检索。

第 3 周：FastAPI、Docker、Redis、数据库，部署 RAG 项目。

第 4 周：整理简历、项目文档、模拟面试、高频算法复盘。

---

## 十二、每周学习模板

工作日每天 2-3 小时：

- 40 分钟：算法题 1 道。
- 60 分钟：主线学习。
- 40 分钟：代码练习。
- 20 分钟：复盘笔记。

周末每天 4-6 小时：

- 2 小时：项目开发。
- 1 小时：整理文档。
- 1 小时：补算法或机器学习基础。
- 1 小时：复盘 Badcase 或优化项目。

每周至少产出一个东西：

- 一篇学习笔记。
- 一个小脚本。
- 一个项目功能。
- 一组算法题复盘。
- 一份实验报告。

---

## 十三、面试准备清单

算法面试：数组、字符串、哈希表、双指针、滑动窗口、二叉树、二分、堆、DFS/BFS、动态规划基础。

机器学习面试：过拟合、AUC、F1、逻辑回归、树模型、GBDT、特征工程、训练集/测试集隔离。

深度学习面试：反向传播、Dropout、BatchNorm、Adam/SGD、Transformer。

大模型面试：Attention、Transformer、RAG、Agent、SFT、LoRA、模型评测、幻觉控制。

项目面试：背景、目标、架构、技术选型、数据来源、核心难点、解决方案、指标提升、Badcase、下一步优化。

---

## 十四、最终学习顺序

1. Python + SQL + Git + Linux。
2. 算法基础每天刷。
3. 机器学习基础。
4. PyTorch 深度学习。
5. Transformer 和大模型基础。
6. RAG 项目。
7. Agent 项目。
8. LoRA 微调项目。
9. 推荐/搜索项目。
10. FastAPI + Docker 部署。
11. 简历项目打磨。
12. 面试题复盘。

先把 RAG 项目做出来，再逐步加 Agent、微调、推荐搜索。不要一开始把方向铺太散，每个阶段都要有可交付成果。

---

# 十五、基于字节、阿里、腾讯最新 AI 岗位的补充学习路线

> 检索时间：2026-07-29。岗位变化很快，具体投递状态以官方招聘页为准。本节根据字节 Seed、阿里星、腾讯 AI Lab/腾讯招聘公开页面中出现的 AI 岗位方向，倒推出更细的学习内容。

## 15.1 参考岗位来源

### 字节跳动 Seed

公开页面显示的热招和校招方向包括：

- 大语言模型通用 Agent 研究工程师。
- 大语言模型强化学习算法研究工程师。
- 大语言模型预训练算法工程师。
- 大模型数据工程师。
- 3D 生成算法工程师。
- AIGC 视频生成算法专家。
- 多模态世界模型算法研究员/专家。
- 世界模型训练产品经理。
- 基础大模型、视觉智能、语音智能、机器学习系统、大模型应用、具身智能。

对应来源：

- https://seed.bytedance.com/zh/career
- https://seed.bytedance.com/zh/seedearlycareer
- https://seed.bytedance.com/zh/topseed

### 阿里巴巴

阿里星官方课题池显示 AI 方向非常广，重点包括：

- Qwen 基础大模型。
- Wan 视觉生成与世界模型。
- 语音大模型。
- 多模态世界模型强化学习。
- Agentic RL。
- AI Coding。
- Search Agent。
- 大模型推荐/广告/搜索。
- 电商购物 Agent、全球零售经营 AI Agent、供应链物流 AI Agent。
- 大模型推理优化、训练/推理 Infra、AI 编译器、GPU 算子、向量数据库、AI Agent 基础设施。
- 医疗多模态智能体、医疗 AI 基础模型。
- 安全大模型、Agent 安全评测与防御。

对应来源：

- https://campus-talent.alibaba.com/campus/alistar
- https://campus-talent.alibaba.com/

### 腾讯

腾讯 AI Lab 和腾讯混元相关公开信息体现的方向包括：

- 图像图形算法，尤其是 3D 虚拟人、人脸、图形学、CV。
- 自然语言处理，包括词法分析、自动对话、语义挖掘、语言逻辑。
- 语音识别、语音合成、声学模型、语言模型、TTS。
- 混元大模型 Post-training、RAG、AI 搜索、Agent、翻译。
- 多模态算法应用、虚拟人、语音-表情同步、动作生成。
- 大模型量化压缩、推理加速、训练框架、DeepSpeed、Megatron、FlashAttention、CUDA。

对应来源：

- https://ailab.tencent.com/ailab/zh/recruit/
- https://ailab.tencent.com/ailab/zh/about/
- https://careers.tencent.com/zh-cn/
- https://careers.tencent.com/campusrecruit.html

---

## 15.2 岗位族一：大模型应用工程 / LLM 应用 / Agent / RAG

这是最适合作为第一主线的方向。字节的大模型应用、阿里的 AI Agent 应用研发、阿里的 Search Agent、电商购物 Agent、腾讯混元应用算法工程师，都大量覆盖这个能力。

### 对应岗位关键词

- 大模型应用算法工程师。
- LLM 应用工程师。
- Agent 应用研发。
- AI Agent 应用研发与系统架构。
- Search Agent 算法工程师。
- AI 搜索算法工程师。
- RAG 算法工程师。
- 多轮对话算法工程师。
- 大模型产品算法工程师。

### 必学内容 1：LLM 基础调用与参数

学习点：

- Chat Completion 基本流程。
- System/User/Assistant 消息结构。
- Temperature、Top-p、Top-k。
- Max Tokens。
- Stop Words。
- Streaming 输出。
- Token 计费与上下文窗口。
- 结构化输出 JSON。
- 错误重试、超时、限流。

练习：

1. 写一个命令行聊天助手。
2. 支持流式输出。
3. 支持 JSON 输出校验。
4. 统计每次请求的 token 数量。
5. 对失败请求做重试和日志记录。

验收标准：

- 能解释 temperature 和 top-p 的区别。
- 能控制模型稳定输出 JSON。
- 能处理接口失败、超时、上下文过长。

### 必学内容 2：Prompt Engineering

学习点：

- 角色设定。
- 任务目标定义。
- 输出格式约束。
- Few-shot 示例。
- 分步推理提示。
- 反幻觉提示。
- 提示词版本管理。
- 提示词评测。

练习：

1. 岗位 JD 技术栈提取 Prompt。
2. 简历优化 Prompt。
3. SQL 生成 Prompt。
4. 代码审查 Prompt。
5. 面试题生成 Prompt。

验收标准：

- 同一个输入多次运行，输出格式稳定。
- 能发现 Prompt 的 Badcase。
- 能通过增加约束或示例修复 Badcase。

### 必学内容 3：RAG

学习点：

- 文档解析：Markdown、PDF、HTML、TXT。
- Chunk 切分策略：固定长度、按标题、按语义。
- Embedding 模型选择。
- 向量数据库：FAISS、Milvus、Chroma。
- 检索 TopK。
- 混合检索：BM25 + 向量检索。
- Rerank。
- 查询改写 Query Rewrite。
- 多轮对话下的历史压缩。
- 引用来源。
- 去幻觉。
- 检索评测。

详细学习步骤：

1. 先做最小版 RAG：文档切分、向量化、TopK 检索、拼接上下文、调用模型回答。
2. 加引用来源：每个答案必须展示对应文档片段。
3. 加 Rerank：比较无 Rerank 和有 Rerank 的差异。
4. 加混合检索：BM25 负责关键词准确性，向量检索负责语义召回。
5. 加 Query Rewrite：把用户口语问题改写成更适合检索的问题。
6. 加多轮对话：历史压缩，只保留和当前问题相关的信息。
7. 加评测集：至少 100 条问题，标注标准答案和引用片段。
8. 加 Badcase 看板：记录没召回、召回错、生成错、引用错。

项目：企业知识库 RAG 系统。

功能清单：

- 文档上传。
- 文档解析。
- Chunk 切分。
- Embedding 入库。
- TopK 检索。
- Rerank。
- 引用来源。
- 多轮对话。
- 用户反馈。
- 检索日志。
- Badcase 分析。

验收指标：

- 检索 Recall@5。
- 答案正确率。
- 引用命中率。
- 幻觉率。
- 平均响应时间。

### 必学内容 4：Agent

学习点：

- Tool Calling。
- Function Calling。
- 工具参数 schema。
- Planning。
- Task Decomposition。
- Reflection 了解。
- Memory。
- Multi-Agent。
- 工具调用日志。
- 工具失败恢复。
- 权限控制。

详细学习步骤：

1. 做一个单工具 Agent：只会查天气或查数据库。
2. 做多工具 Agent：可以查数据库、读文件、调用搜索、生成报告。
3. 做任务规划 Agent：能把复杂任务拆成多步。
4. 做带记忆 Agent：记住用户偏好和历史任务。
5. 做可观测 Agent：每一步工具调用都可回放。
6. 做安全控制：禁止危险命令，限制文件访问范围。

项目：AI 求职助手 Agent。

功能：

- 分析岗位 JD。
- 提取技能栈。
- 和个人简历做差距分析。
- 生成学习计划。
- 生成项目建议。
- 生成面试题。
- 自动保存任务。

验收标准：

- 至少接入 5 个工具。
- 每个工具都有参数校验。
- 工具失败时能 fallback。
- 复杂任务能拆成 3 步以上。

---

## 15.3 岗位族二：大模型后训练 / Post-training / SFT / RLHF / DPO

字节 Seed 的强化学习、Agent RL、RL Scaling，阿里的 Agentic Post-training、LLM and Multimodal Post-training，腾讯混元 Post-training 都指向这个方向。

### 对应岗位关键词

- 大模型后训练算法工程师。
- 大模型强化学习算法工程师。
- Post-training 算法工程师。
- RLHF 算法工程师。
- Agentic RL 算法工程师。
- 多模态 Post-training。
- 对话模型优化工程师。

### 必学内容 1：后训练基础

学习点：

- Pretraining、SFT、Reward Model、RLHF 的区别。
- Instruction Tuning。
- Preference Data。
- DPO。
- PPO 了解。
- GRPO 了解。
- RLHF 数据构造。
- 对话数据质量。
- 安全对齐。

练习：

1. 构造 1000 条指令数据。
2. 构造 300 条偏好数据。
3. 做一次 LoRA SFT。
4. 做一次 DPO 实验。
5. 对比 Base、SFT、DPO 三个模型效果。

### 必学内容 2：SFT

学习点：

- 数据格式。
- Chat Template。
- Tokenizer。
- Loss Mask。
- LoRA Rank。
- Learning Rate。
- Epoch。
- Gradient Accumulation。
- Overfitting。

实战：

- 选 Qwen 小模型。
- 做 SQL 助手或简历助手 SFT。
- 记录训练 loss。
- 保存 checkpoint。
- 做推理对比。

验收标准：

- 能解释 LoRA 的作用。
- 能解释为什么只训练部分参数。
- 能发现微调后格式变差、幻觉变多等问题。

### 必学内容 3：偏好优化

学习点：

- Pairwise Preference。
- Chosen / Rejected。
- DPO Loss 直觉。
- Reward Model 直觉。
- Human Preference。
- AI Feedback。

实战：

- 对同一个问题生成两个答案。
- 人工标注哪个更好。
- 构造 DPO 数据。
- 跑小规模 DPO。
- 观察模型是否更符合偏好。

验收标准：

- 能讲清楚 SFT 和 DPO 的区别。
- 能说明偏好数据质量为什么关键。
- 能分析 DPO 过拟合或退化。

### 必学内容 4：Agent RL 入门

学习点：

- 强化学习基本概念：State、Action、Reward、Policy、Trajectory。
- Tool-use Reward。
- Task Success Rate。
- Long Horizon Task。
- 多步任务评测。
- 环境构造。

练习：

- 构造一个简单工具调用环境。
- 定义成功奖励和失败惩罚。
- 记录 Agent 轨迹。
- 对比无规划和有规划的成功率。

---

## 15.4 岗位族三：基础大模型 / 预训练 / 数据工程

字节 Seed 的预训练算法工程师、大模型数据工程师，阿里 Qwen 基础大模型、通义万相基础生成模型、训练数据闭环，都需要这个方向。

### 对应岗位关键词

- 大模型预训练算法工程师。
- 基础模型算法工程师。
- 大模型数据工程师。
- 数据治理算法工程师。
- 预训练数据算法工程师。
- 多语言大模型预训练。

### 必学内容 1：预训练基本概念

学习点：

- Tokenizer。
- 语料清洗。
- 数据去重。
- 数据配比。
- Curriculum Learning 了解。
- Scaling Law 直觉。
- MoE 了解。
- 长上下文训练。
- 训练稳定性。

不要求一开始真的训练大模型，但要理解流程。

### 必学内容 2：数据工程

学习点：

- 数据采集。
- 文本清洗。
- 语言识别。
- 去重 MinHash。
- 质量分类器。
- PII 检测。
- 毒性/安全过滤。
- 多语言数据。
- 文档结构保留。
- 代码数据清洗。

练习：

1. 收集一批网页文本。
2. 去 HTML 标签。
3. 做语言识别。
4. 去重。
5. 按质量打分。
6. 输出清洗前后对比报告。

项目：大模型训练数据清洗管线。

功能：

- 输入原始文档。
- 自动清洗。
- 质量打分。
- 重复检测。
- 敏感信息过滤。
- 输出训练格式。
- 生成数据统计报告。

验收指标：

- 重复率下降。
- 低质量文本占比下降。
- 格式错误率下降。
- 抽样人工检查通过率。

### 必学内容 3：模型结构

学习点：

- Transformer Decoder。
- Attention。
- RoPE。
- RMSNorm。
- SwiGLU。
- MoE。
- GQA/MQA。
- Long Context。
- Speculative Decoding 了解。

验收标准：

- 能画出 Decoder-only 模型结构。
- 能解释 Attention 复杂度。
- 能解释 KV Cache。
- 能解释 MoE 为什么能扩参数不等比例增加计算量。

---

## 15.5 岗位族四：AI 搜索 / Search Agent / DeepResearch

字节大模型应用里有 LLM 搜索方案、Search Agent；阿里有多模态 Search Agent、基于大模型的搜索算法；腾讯混元 AI 搜索强调 Agentic RAG、Planning、Fact-checking。

### 对应岗位关键词

- AI 搜索算法工程师。
- Search Agent 算法工程师。
- RAG 搜索算法工程师。
- DeepResearch 算法工程师。
- 搜索内容理解算法工程师。

### 必学内容

#### 1. 传统搜索

- 倒排索引。
- TF-IDF。
- BM25。
- Query 分析。
- 分词。
- 同义词。
- 纠错。
- Query Rewrite。
- Learning to Rank。

#### 2. 语义搜索

- Embedding。
- 向量召回。
- ANN 检索。
- FAISS/HNSW。
- Rerank。
- Dense Retrieval。
- Hybrid Search。

#### 3. AI 搜索

- Query Decomposition。
- Multi-hop Retrieval。
- Planning。
- Evidence Collection。
- Fact-checking。
- Citation。
- Source Reliability。
- Answer Synthesis。
- DeepResearch 报告生成。

项目：AI Search / DeepResearch 系统。

功能：

1. 用户输入复杂问题。
2. 系统拆解子问题。
3. 每个子问题执行检索。
4. 对来源做可信度排序。
5. 对结论做事实核查。
6. 生成带引用的长答案。
7. 标记不确定信息。

验收指标：

- 子问题拆解质量。
- 证据覆盖率。
- 引用准确率。
- 幻觉率。
- 深度问题完成率。

---

## 15.6 岗位族五：多模态理解 / 多模态生成 / 视频生成 / 3D / 数字人

字节 Seed 有 3D 生成、AIGC 视频生成、多模态世界模型；阿里 Wan 视觉生成、3D 重建、多模态生成理解统一；腾讯 AI Lab 有图像图形、3D 虚拟人，混元多模态也覆盖虚拟人和多模态驱动。

### 对应岗位关键词

- 多模态算法工程师。
- AIGC 视频生成算法工程师。
- 3D 生成算法工程师。
- 图像图形算法工程师。
- 视觉生成算法工程师。
- 数字人算法工程师。
- 多模态世界模型算法工程师。

### 必学内容 1：计算机视觉基础

- CNN。
- ResNet。
- ViT。
- 图像分类。
- 目标检测。
- 语义分割。
- 图像检索。
- 人脸检测/识别。

### 必学内容 2：生成模型

- VAE 了解。
- GAN 了解。
- Diffusion。
- DDPM。
- DDIM。
- Latent Diffusion。
- Stable Diffusion。
- DiT。
- ControlNet。
- LoRA for Diffusion。

### 必学内容 3：视频生成

- 图像生成到视频生成的差异。
- Temporal Consistency。
- Motion Modeling。
- Frame Interpolation。
- Video Diffusion。
- 文生视频、图生视频。
- 视频评测指标。

### 必学内容 4：3D 与数字人

- 3D 几何基础。
- Mesh。
- Point Cloud。
- NeRF 了解。
- Gaussian Splatting 了解。
- 3D Face。
- 表情驱动。
- 语音-口型同步。
- 姿态估计。
- 动作生成。

项目：多模态简历讲解数字人 Demo。

功能：

1. 输入简历文本。
2. 大模型生成讲解稿。
3. TTS 生成语音。
4. 数字人口型同步。
5. 输出短视频。

如果难度太高，可以降级为：图片 + TTS + 字幕 + 视频合成。

验收标准：

- 能解释多模态管线。
- 能说明视觉、语音、文本如何对齐。
- 能分析生成质量问题。

---

## 15.7 岗位族六：语音智能 / 语音大模型 / 语音 Agent

字节 Seed 有语音智能、语音 Agent、音频理解/生成、音乐生成；阿里有语音大模型和端到端语音智能体；腾讯 AI Lab 有 ASR/TTS/语音前端/声学模型/语言模型。

### 对应岗位关键词

- 语音识别算法工程师。
- 语音合成算法工程师。
- 语音大模型算法工程师。
- Audio LLM 算法工程师。
- 语音 Agent 算法工程师。

### 必学内容

#### 1. 音频基础

- 采样率。
- 声道。
- 波形。
- 频谱。
- STFT。
- Mel Spectrogram。
- MFCC。

#### 2. ASR

- 声学模型。
- 语言模型。
- CTC。
- Transducer 了解。
- Whisper 类模型。
- 远场识别。
- 噪声鲁棒性。

#### 3. TTS

- 文本前端。
- 声学模型。
- 声码器。
- 音色克隆。
- 情感语音。
- 流式 TTS。

#### 4. 语音 Agent

- 语音活动检测 VAD。
- 打断检测。
- 端到端语音对话。
- 低延迟。
- 多轮语音上下文。

项目：语音问答助手。

功能：

1. 麦克风输入。
2. ASR 转文字。
3. LLM 生成答案。
4. TTS 播放。
5. 支持打断和继续对话。

验收指标：

- ASR 错误率。
- 首包延迟。
- 总响应延迟。
- TTS 自然度。

---

## 15.8 岗位族七：机器学习系统 / AI Infra / 推理优化

字节 Seed 机器学习系统强调超大规模训练、推理优化、异构硬件、编译加速；阿里 AI Infra 覆盖 Qwen 训练推理、RL Infra、GPU 算子、AI 编译器、KV Cache、向量数据库；腾讯混元覆盖量化压缩、推理加速、训练框架、CUDA、DeepSpeed、Megatron、FlashAttention。

### 对应岗位关键词

- 大模型推理优化工程师。
- 大模型训练框架研发工程师。
- AI Infra 工程师。
- 机器学习系统工程师。
- GPU 算子工程师。
- 大模型量化压缩算法工程师。
- 分布式训练工程师。

### C++ 是否必须

这个方向 C++ 很重要。Python 负责实验和框架调用，C++/CUDA 负责性能核心。

### 必学内容 1：分布式训练

- Data Parallel。
- Tensor Parallel。
- Pipeline Parallel。
- ZeRO。
- FSDP。
- DeepSpeed。
- Megatron-LM。
- Checkpoint。
- Mixed Precision。
- BF16/FP16。
- Gradient Accumulation。
- 通信开销。

### 必学内容 2：推理优化

- KV Cache。
- PagedAttention。
- Continuous Batching。
- Speculative Decoding。
- Quantization。
- AWQ/GPTQ 了解。
- TensorRT-LLM。
- vLLM。
- FlashAttention。
- Prefill/Decode 分离。

### 必学内容 3：系统基础

- Linux。
- C++。
- 多线程。
- 内存管理。
- 网络基础。
- Docker/Kubernetes。
- GPU 基础。
- CUDA 入门。

### 项目：大模型推理服务压测与优化

功能：

1. 用 vLLM 部署一个开源模型。
2. 写压测脚本。
3. 统计 QPS、延迟、显存、吞吐。
4. 比较不同 batch size。
5. 比较不同量化方式。
6. 输出性能报告。

验收标准：

- 能解释 Prefill 和 Decode。
- 能解释 KV Cache 的内存消耗。
- 能解释为什么连续批处理能提升吞吐。
- 能用数据说明优化效果。

---

## 15.9 岗位族八：推荐 / 广告 / 电商 AI / 用户理解

阿里非常强调大模型推荐、广告、电商 Agent、AI 导购、全球电商推荐大模型；字节和腾讯也有大量内容推荐、广告、搜索、用户理解场景。

### 对应岗位关键词

- 推荐算法工程师。
- 搜索算法工程师。
- 广告算法工程师。
- 用户理解算法工程师。
- AI 导购算法工程师。
- 电商 Agent 算法工程师。
- 多模态商品理解算法工程师。

### 必学内容 1：推荐基础

- 召回、粗排、精排、重排。
- UserCF、ItemCF。
- Embedding 召回。
- Two Tower。
- DeepFM。
- DIN。
- 多目标排序。
- 冷启动。
- 多样性。

### 必学内容 2：广告基础

- CTR。
- CVR。
- eCPM。
- 出价。
- 转化漏斗。
- A/B Test。
- 因果推断基础。

### 必学内容 3：大模型 + 推荐/电商

- 商品理解。
- 用户意图理解。
- 多模态商品表征。
- 对话式导购。
- 推荐解释。
- LLM 生成特征。
- LLM 做 Query Rewrite。
- Agent 做购物任务规划。

项目：AI 导购 + 推荐系统。

功能：

1. 用户自然语言描述需求。
2. LLM 抽取预算、风格、用途、限制条件。
3. 向量召回商品。
4. 排序模型排序。
5. LLM 生成推荐理由。
6. 支持追问和多轮偏好更新。

验收指标：

- 需求抽取准确率。
- Recall@K。
- NDCG。
- 推荐点击率模拟。
- 推荐理由可解释性。

---

## 15.10 岗位族九：具身智能 / 机器人 / 世界模型

字节 Seed 和阿里都明确出现了具身智能、机器人基础模型、机器人强化学习、机器人数据算法、世界模型。

### 对应岗位关键词

- 具身智能算法工程师。
- 机器人多模态大模型算法工程师。
- 机器人强化学习算法工程师。
- 世界模型算法研究员。
- VLA 模型算法工程师。

### 必学内容

- 强化学习基础。
- 模仿学习。
- 行为克隆。
- 机器人运动学基础。
- 视觉-语言-动作模型 VLA。
- 仿真环境。
- 数据采集。
- 轨迹数据。
- 任务成功率评测。
- Sim2Real 了解。

项目建议：

- 先不要直接做真实机器人。
- 使用仿真环境做简单抓取/导航任务。
- 或者做一个“视觉输入 + 语言指令 + 动作规划”的小 Demo。

验收标准：

- 能解释 State、Action、Reward。
- 能解释 imitation learning 和 RL 的区别。
- 能说清机器人数据闭环为什么难。

---

## 15.11 岗位族十：AI 安全 / 对齐 / 评测

阿里星课题中有安全领域基础大模型、Security AI Agent、智能体安全评测与防御；字节 Seed 有 Responsible AI；腾讯混元也有大模型安全相关岗位公开信息。

### 对应岗位关键词

- 大模型安全算法工程师。
- AI Safety 工程师。
- 大模型评测工程师。
- Agent 安全评测工程师。
- 内容安全算法工程师。

### 必学内容

- Prompt Injection。
- Jailbreak。
- 数据泄露。
- PII 检测。
- 有害内容检测。
- 红队测试。
- 安全对齐。
- 拒答策略。
- Agent 工具权限控制。
- 沙箱执行。
- 模型评测集。

项目：Agent 安全评测平台。

功能：

1. 构造攻击样本。
2. 测试 Prompt Injection。
3. 测试越权工具调用。
4. 记录模型响应。
5. 给出风险分级。
6. 生成安全报告。

验收标准：

- 能解释 RAG 场景下的 Prompt Injection。
- 能设计工具权限边界。
- 能构造安全评测集。

---

## 15.12 按岗位目标选择你的学习主线

### 如果目标是最快进入 AI 应用方向

优先顺序：

1. Python。
2. FastAPI。
3. LLM API。
4. Prompt。
5. RAG。
6. Agent。
7. 模型评测。
8. Docker 部署。
9. SQL/Redis/向量数据库。
10. 算法题每天刷。

必须项目：

- 企业知识库 RAG。
- AI 求职助手 Agent。
- 模型评测与 Badcase 平台。

### 如果目标是大模型算法方向

优先顺序：

1. 数学。
2. 机器学习。
3. PyTorch。
4. Transformer。
5. SFT/LoRA。
6. DPO/RLHF。
7. 数据工程。
8. 论文阅读。
9. 模型评测。
10. 算法题。

必须项目：

- LoRA 微调助手。
- DPO 偏好优化实验。
- 大模型评测集。

### 如果目标是 AI Infra / 推理优化

优先顺序：

1. Python。
2. C++。
3. Linux。
4. CUDA 入门。
5. PyTorch。
6. DeepSpeed/Megatron。
7. vLLM。
8. TensorRT-LLM。
9. FlashAttention。
10. 分布式训练和推理。

必须项目：

- vLLM 推理服务压测。
- 量化前后效果和性能对比。
- 小型 CUDA 算子实验。

### 如果目标是多模态/AIGC

优先顺序：

1. PyTorch。
2. CV 基础。
3. Transformer。
4. Diffusion。
5. ViT。
6. 多模态模型。
7. 视频生成。
8. 图像/视频评测。
9. 3D 基础。

必须项目：

- 文生图/图生图 Demo。
- 多模态 RAG。
- 视频生成或数字人小 Demo。

### 如果目标是推荐/搜索/广告算法

优先顺序：

1. Python。
2. SQL。
3. 机器学习。
4. 特征工程。
5. 推荐系统。
6. 搜索系统。
7. 排序模型。
8. A/B Test。
9. LLM + 推荐/搜索结合。

必须项目：

- 岗位推荐系统。
- AI Search 系统。
- AI 导购 Demo。

---

## 15.13 更细的 12 个月路线

### 第 1-2 个月：编程、算法、数据处理

目标：把基础打稳。

学习：

- Python。
- Pandas。
- SQL。
- Git。
- Linux。
- 数组、字符串、哈希表、双指针、滑动窗口、链表、二叉树。

产出：

- 岗位数据分析工具。
- 50 道算法题复盘。

### 第 3-4 个月：机器学习、深度学习、PyTorch

学习：

- 线性模型、树模型、GBDT。
- AUC、F1、Recall。
- 神经网络。
- PyTorch 训练循环。
- 文本分类。

产出：

- 岗位分类器。
- PyTorch 文本分类模型。
- 100 道算法题复盘。

### 第 5-6 个月：LLM、RAG、Agent

学习：

- Transformer。
- Prompt。
- RAG。
- Agent。
- Tool Calling。
- 模型评测。

产出：

- 企业知识库 RAG。
- AI 求职助手 Agent。
- 评测集和 Badcase 报告。

### 第 7-8 个月：微调与后训练

学习：

- SFT。
- LoRA。
- QLoRA。
- DPO。
- 偏好数据。
- 数据清洗。

产出：

- 垂直领域微调助手。
- DPO 实验报告。
- 微调前后对比报告。

### 第 9-10 个月：选择一个岗位分支深入

选择一：AI 应用工程。

- 深入 Agent、RAG、AI Search、工程部署。

选择二：大模型算法。

- 深入 Post-training、RLHF、评测、论文复现。

选择三：AI Infra。

- 深入 C++、CUDA、vLLM、DeepSpeed、推理优化。

选择四：多模态。

- 深入 Diffusion、视频生成、多模态理解。

选择五：推荐搜索。

- 深入召回、排序、A/B Test、LLM+推荐。

产出：

- 一个分支型硬核项目。

### 第 11-12 个月：简历、面试、投递

学习：

- 高频算法题二刷。
- 项目八股整理。
- ML/DL/LLM 高频面试题。
- 系统设计：RAG 系统、Agent 系统、推荐系统、推理服务。

产出：

- 简历 1 份。
- 项目文档 3 份。
- 面试题库 1 份。
- 模拟面试 5 次以上。

---

## 15.14 最推荐的项目组合升级版

### 项目 1：企业知识库 RAG + Agent

技术栈：

- Python。
- FastAPI。
- LangChain 或 LlamaIndex。
- FAISS/Milvus/Chroma。
- Reranker。
- LLM API 或本地 Qwen。
- Redis。
- Docker。

必须写进简历的点：

- Chunk 策略。
- Hybrid Search。
- Rerank。
- 引用来源。
- 多轮历史压缩。
- Badcase 闭环。
- 延迟和准确率优化。

### 项目 2：AI Search / DeepResearch

技术栈：

- BM25。
- 向量检索。
- Query Rewrite。
- Query Decomposition。
- Planning。
- Fact-checking。
- Citation。

必须写进简历的点：

- 复杂问题拆解。
- 多源证据融合。
- 幻觉控制。
- 引用准确率。
- 事实核查。

### 项目 3：LoRA 微调 + DPO 偏好优化

技术栈：

- Qwen/Llama。
- Transformers。
- PEFT。
- TRL。
- datasets。
- LoRA。
- DPO。

必须写进简历的点：

- 数据构造。
- 清洗规则。
- 训练参数。
- 评测集。
- 微调前后效果。
- Badcase 分析。

### 项目 4：岗位推荐 / AI 导购系统

技术栈：

- Pandas。
- LightGBM。
- Two Tower。
- 向量检索。
- BM25。
- LLM 解释。

必须写进简历的点：

- 召回。
- 排序。
- 用户意图理解。
- 推荐解释。
- Recall@K/NDCG/AUC。

### 项目 5：推理服务压测与优化，可选

适合 AI Infra 方向。

技术栈：

- vLLM。
- Docker。
- GPU。
- Quantization。
- Continuous Batching。
- KV Cache。

必须写进简历的点：

- QPS。
- P95 延迟。
- 显存占用。
- Batch Size 对吞吐影响。
- 量化前后效果。

---

## 15.15 学习优先级结论

如果你现在还没有明确分支，建议按这个优先级：

1. Python + SQL + Git + Linux。
2. 算法题 150 道。
3. 机器学习 + PyTorch。
4. Transformer + LLM 基础。
5. RAG 项目。
6. Agent 项目。
7. LoRA 微调。
8. AI Search。
9. 推荐/搜索基础。
10. 根据目标补 C++/CUDA 或多模态/语音/安全。

最先做的项目仍然建议是：企业知识库 RAG + Agent。它覆盖字节的大模型应用、阿里的 Agent/搜索/电商智能体、腾讯混元 Post-training 应用和 AI Search 中最共性的部分。

---

## 15.16 检索摘要

- 网站：opencli | 查询词：opencli list -f yaml | 次数：1 次预检 | 状态：成功，结果量过大，未继续使用具体 opencli 站点
- 网站：Web 搜索 | 查询词：字节 Seed AI 招聘 大模型 Agent 强化学习 预训练 语音 视频 机器人 | 次数：1
- 网站：Web 搜索 | 查询词：阿里星 Qwen Wan Agentic RL AI Coding Search Agent 大模型 招聘 | 次数：1
- 网站：Web 搜索 | 查询词：腾讯 AI Lab 招聘 NLP 语音 图像 图形 算法 实习 / 腾讯 混元 大模型 招聘 | 次数：2
- 主要参考：字节 Seed 官网、Seed 大模型人才校招、阿里星官方页面、腾讯 AI Lab 招聘和研究方向页、腾讯招聘官网公开页。

---

# 十六、增强版：对齐字节、阿里、腾讯最新 AI 岗位的详细学习作战手册

> 更新时间：2026-07-29。以下内容根据近期公开招聘页面与岗位方向整理，重点对齐字节 Seed、阿里星/通义千问/万相/Agentic AI、腾讯青云计划/AI Lab 的 AI 岗位能力要求。它不是泛泛的“AI 学习清单”，而是把岗位关键词拆成可学习、可练习、可放进简历、可被面试追问的任务。

## 16.1 最新岗位信号：三家公司到底在招什么能力

### 字节跳动 Seed：更像“基础模型 + Agent + 多模态 + 系统 + 机器人”的全栈大模型团队

公开页面能看到的热招岗位包括：

- 大语言模型 Code Agent 算法工程师。
- 大语言模型通用 Agent 算法工程师。
- 大语言模型强化学习算法工程师。
- 大语言模型预训练算法工程师。
- 语音识别算法工程师。
- 语音生成算法工程师。
- AIGC 算法专家，视频生成方向。
- 机器人本体结构工程师，Seed Robotics。

Seed 2027 大模型人才校招页面列出的技术研究方向更具体：

- 基础大模型：模型结构、训练范式、数据压缩、Code Agent RL、Test-time Scaling、Long Horizon Task、Multi-Agent RL、RL Scaling、AI4Math、模型蒸馏、Memory 与推理。
- 视觉智能：多模态数据管线、视频与图像评估体系、多模态预训练、视觉表征、视觉推理、多模态 Agent、工具使用与行动能力。
- 语音智能：语音/音频理解与生成、多模态联合学习、个性化对话记忆、在线学习、语音 Agent、音乐生成。
- 机器学习系统：超大规模训练集群、MFU、低精度、容错、弹性训练、RL 系统、多机推理、异构并行推理、算子编译优化、通信优化。
- 大模型应用：LLM 搜索、Search Agent、模型记忆、个性化、用户反馈信号。
- 具身智能：机器人操作大模型、机器人数据算法、机器人强化学习。

对应学习结论：

- 如果目标是字节 Seed 的算法岗，不能只会 LangChain/RAG。至少要懂 Transformer、训练/后训练、评测、数据闭环、RL 或多模态其中一条深线。
- 如果目标是大模型应用岗，最核心是 RAG + Agent + Eval + 数据反馈 + 工程化落地，而不是只会调用模型 API。
- 如果目标是机器学习系统岗，C++/CUDA/分布式系统/推理引擎会变成硬要求。

### 阿里巴巴阿里星：非常强调 Qwen、Wan、Agentic AI、电商/商业场景、AI Infra 与安全

阿里星 2027 页面把方向拆得很细，能看到这些非常明确的关键词：

- 基础模型：千问 Qwen、万相 Wan、视觉生成与世界模型、语音大模型、多模态世界模型强化学习、理解与生成统一架构、具身基础模型。
- 后训练与 Agent：Agentic RL、Agentic Post-training、LLM/Multimodal Post-training、Agentic Coding 后训练、海量工具调用 Agent 的强化学习、主动式 Agent、多 Agent 群体智能、自我学习进化。
- 大模型应用：AI 导购、智能推荐、电商购物 Agent、广告大模型、用户理解、权益发放、供应链/物流/定价 Agent、1688 产业大模型、AI Coding、数字员工。
- AI Search：多模态 Search Agent、基于大模型的搜索算法、AI Search 平台、企业搜索 Agent、向量搜索、答案引擎。
- 多模态：AIGC 内容生成、视频生成、3D 重建、跨模态理解、商品图文短视频生成、医疗/旅行等行业多模态。
- AI Infra：Qwen 训练/推理工程、RL Infrastructure、分布式训练/推理、GPU Kernel、AI Compiler、异构计算、KV Cache、模型推理优化、Kubernetes/调度/Agent Runtime。
- 安全与对齐：大模型安全对齐、Agent 安全、威胁识别、对抗防御、内容安全自进化 Agent。

对应学习结论：

- 阿里岗位很看重“AI + 产业场景”：电商、搜索、广告、供应链、云、数据库、安全、医疗、旅行。
- 只学通用大模型不够，最好做一个带业务闭环的项目，比如 AI 导购、商品理解、企业搜索、AI Coding 或安全 Agent。
- 阿里很强调 Agentic、Search、Infra，所以“工具调用 + 长任务规划 + 线上反馈数据 + 推理成本治理”是高价值组合。

### 腾讯：青云计划聚焦六大 AI 技术域，AI Lab 强调 CV、语音、NLP、机器学习和业务落地

腾讯 2027 青云计划近期公开信息聚焦六大方向：

- 大语言模型与 NLP。
- 多模态、计算机视觉、语音算法。
- 智能体与强化学习。
- 搜索、推荐、模型应用。
- AI 基础设施、系统与安全。
- AI 数据、数据工程。

腾讯 AI Lab 的长期研究方向包括：

- 计算机视觉：图像分类、语义分割、图像描述、人像分析、检测、跟踪、识别、3D 建模与生成、视频内容分析/搜索/推荐。
- 语音技术：音频编解码、远场信号处理、语音分离增强、声纹、ASR、TTS、语音转换。
- NLP：文本理解、文本生成、对话、机器翻译。
- 机器学习：机器学习理论、元学习、联邦学习、图深度学习、生成学习、序列学习、AutoML、强化学习。
- 应用场景：社交、游戏、内容、数字人。

对应学习结论：

- 腾讯 AI 岗位更容易出现“技术研究 + 亿级产品场景”的结合，比如内容理解、推荐、数字人、游戏 AI、社交 AI。
- 如果想投腾讯，项目最好有“用户场景”和“稳定性指标”，比如推荐点击率预测、内容多模态理解、AI 对话助手、数字人语音/表情生成链路。
- 腾讯青云把 AI 数据/数据工程单列出来，说明数据质量、数据闭环、评测集建设也是明确竞争力。

## 16.2 先选主线：不同目标岗位怎么学

### 主线 A：大模型应用 / RAG / Agent 工程师

适合目标：字节大模型应用、通用 Agent、Code Agent；阿里 AI Search、AI 导购、AI Coding、数字员工；腾讯搜索推荐模型应用、智能体、AI 产品落地。

必须掌握：

- Python 工程：类型标注、异常处理、日志、异步编程、FastAPI、pytest、依赖管理、配置管理。
- LLM 基础：Token、上下文窗口、温度、采样、系统提示词、函数调用、结构化输出、流式输出、上下文压缩。
- RAG：文档解析、切分、Embedding、向量库、BM25、混合检索、重排、引用溯源、Query Rewrite、Multi-query、HyDE、Contextual Retrieval。
- Agent：ReAct、Plan-and-Execute、Reflection、Tool Calling、MCP、任务状态机、长短期记忆、多 Agent 协作、失败重试、权限控制。
- Eval：离线评测集、Golden Set、RAGAS/DeepEval/promptfoo、答案正确性、引用准确率、幻觉率、任务成功率、成本、延迟、P95。
- 工程化：Docker、Redis、SQLite/PostgreSQL、Qdrant/Milvus/FAISS、OpenSearch/Elasticsearch、队列、任务调度、鉴权、限流、灰度、监控。

学习顺序：

1. 先用 FastAPI 写一个可调用 LLM 的聊天接口，支持流式输出。
2. 加入文件上传和文档解析，支持 PDF、Markdown、Word、网页文本。
3. 实现基础 RAG：切分、Embedding、入库、检索、拼接上下文、生成答案。
4. 加入混合检索：BM25 + 向量召回 + reranker。
5. 加入引用：回答中标注来自哪篇文档、哪一段。
6. 加入 Query Rewrite：把用户问题改写成检索友好的查询。
7. 加入 Agent 工具调用：搜索文档、查数据库、运行安全沙箱代码、生成报告。
8. 加入任务状态：pending/running/failed/succeeded，支持长任务恢复。
9. 加入评测集：至少 100 条问题，记录正确性、召回、引用准确率、延迟、成本。
10. 加入线上反馈：点赞/点踩、badcase 采集、自动生成回归测试。

可放简历的项目表达：

- 搭建企业知识库 RAG + Agent 系统，支持 PDF/Markdown/网页数据接入、混合检索、rerank、引用溯源和长任务报告生成。
- 构建 100+ 条业务评测集，覆盖事实问答、流程问答、跨文档综合和拒答场景，将 Top-5 召回率、引用准确率、P95 延迟作为核心指标。
- 设计 badcase 闭环，对无答案、召回错误、引用错误、上下文污染、工具调用失败进行分类修复。

### 主线 B：大模型算法 / 后训练 / RLHF / DPO

适合目标：字节预训练、强化学习、Code Agent RL；阿里 Qwen/Wan 后训练、Agentic RL、LLM/Multimodal Post-training；腾讯大语言模型/NLP、智能体/RL。

必须掌握：

- 数学：线性代数、概率统计、信息论、优化方法、梯度下降、Adam/AdamW、学习率调度、正则化。
- 深度学习：MLP、CNN、RNN/LSTM、Attention、Transformer、LayerNorm/RMSNorm、残差连接、位置编码、RoPE、SwiGLU、MoE、GQA/MQA、KV Cache。
- 训练基础：数据加载、Tokenizer、预训练目标、指令微调、LoRA/QLoRA、混合精度、梯度累积、梯度裁剪、checkpoint、loss 曲线分析。
- 对齐与偏好优化：RLHF、Reward Model、PPO、DPO、IPO、KTO、ORPO、GRPO、拒答数据、安全对齐、偏好数据构造。
- Agent 后训练：工具调用轨迹、执行反馈、单元测试反馈、代码修复数据、长任务成功率、环境模拟、self-play、test-time scaling。
- 评测：MMLU、CMMLU、C-Eval、GSM8K、HumanEval、MBPP、MT-Bench、Arena、IFEval、RAG/Agent 自建评测。
- 分布式训练：DDP、FSDP、DeepSpeed ZeRO、Megatron-LM 概念、张量并行、流水并行、数据并行、NCCL 基础。

学习顺序：

1. 用纯 PyTorch 实现一个小型 Transformer Decoder，训练字符级语言模型。
2. 复现 NanoGPT 或 TinyStories 级别训练，理解训练循环、loss、采样、过拟合。
3. 学 Hugging Face Transformers：AutoTokenizer、AutoModelForCausalLM、Trainer、datasets、PEFT。
4. 做 LoRA 微调：选择 1B-8B 开源模型，用自建中文指令数据微调。
5. 做 DPO：构造 chosen/rejected 偏好数据，让模型在某个任务上更符合偏好。
6. 做 Eval：微调前后跑同一套测试集，输出表格和 badcase。
7. 学 RLHF/PPO/GRPO 原理，先不追求大规模复现，但要能讲清楚为何需要 reward、policy、KL 约束。
8. 做一个 Code Agent 小实验：让模型生成代码、跑测试、根据错误修改，再统计 pass rate。
9. 学训练稳定性：学习率、batch size、梯度爆炸、数据污染、重复数据、loss spike、checkpoint resume。
10. 学安全对齐：拒答边界、越狱样本、prompt injection、PII 脱敏、红队评测。

可放简历的项目表达：

- 基于开源 LLM 完成领域 SFT + DPO，对比微调前后在自建评测集上的准确率、风格一致性、拒答合规率和幻觉率。
- 构造多轮工具调用偏好数据，探索 Agent 任务成功率优化，统计 pass@1、pass@3、平均工具调用次数和失败类型。
- 编写训练监控脚本，记录 loss、eval score、显存、吞吐、checkpoint 恢复，形成可复现实验报告。

### 主线 C：AI Search / 推荐 / 广告 / 电商智能

适合目标：字节 LLM 搜索与 Search Agent；阿里 AI Search、AI 导购、智能推荐、电商购物 Agent、广告大模型；腾讯搜索、推荐、模型应用、内容理解。

必须掌握：

- 信息检索：倒排索引、TF-IDF、BM25、Query Understanding、Query Rewrite、召回、排序、重排、Learning to Rank。
- 向量检索：Embedding、ANN、HNSW、IVF、PQ、Milvus/Qdrant/FAISS、向量召回评估。
- 推荐系统：召回、粗排、精排、重排、多目标排序、冷启动、探索利用、召回率、AUC、NDCG、MAP、MRR。
- 推荐模型：协同过滤、矩阵分解、YouTube DNN、DSSM、Two-Tower、Wide&Deep、DeepFM、DIN、DIEN、MMoE、序列推荐。
- 广告模型：CTR/CVR、ESMM、多任务学习、预算约束、竞价、创意生成、广告相关性。
- LLM + Search：答案引擎、查询规划、Web Search Agent、工具调用、引用溯源、多跳检索、报告生成。
- 电商 AI：商品理解、属性抽取、图文匹配、用户意图、导购对话、比价、购物决策、售后工具调用。

学习顺序：

1. 用 Elasticsearch/OpenSearch 建一个商品搜索系统，支持关键词检索、过滤、排序。
2. 用 sentence-transformers 做商品标题/描述向量召回。
3. 实现 BM25 + 向量召回融合，比较 Recall@K。
4. 用 LightGBM/XGBoost 做排序模型，特征包括文本相关性、价格、销量、类目、用户画像。
5. 实现 Two-Tower 推荐，训练用户向量和商品向量。
6. 加入 LLM 意图理解：把“适合程序员久坐的椅子”解析成预算、场景、偏好、禁忌条件。
7. 加入 AI 导购 Agent：搜索商品、比较商品、解释推荐理由、生成购买建议。
8. 加入评测：离线 NDCG、Recall@K、人工偏好评测、答案引用准确率。
9. 加入反馈闭环：点击、收藏、购买、跳出、点踩进入训练样本。
10. 形成“搜索 + 推荐 + Agent”的完整项目报告。

可放简历的项目表达：

- 构建电商 AI 导购系统，融合 BM25、向量召回、Learning-to-Rank 与 LLM 意图解析，支持多轮商品比较和推荐解释。
- 设计离线评测集，统计 Recall@20、NDCG@10、CTR 预估 AUC、人工偏好胜率，并建立 badcase 归因表。
- 用用户反馈构建训练样本，完成从召回、排序到 LLM 解释的闭环优化。

### 主线 D：多模态 / 视频生成 / 语音 / 数字人

适合目标：字节视频生成、视觉智能、语音识别/生成；阿里 Wan、多模态世界模型、视频生成、3D 重建、语音大模型；腾讯多模态/视觉/语音、数字人、内容 AI。

必须掌握：

- 计算机视觉基础：图像分类、目标检测、语义分割、图像检索、OCR、ViT、CLIP、BLIP、SAM、DINO。
- 多模态理解：图文对齐、对比学习、VLM、视觉问答、文档理解、视频理解、跨模态检索。
- 生成模型：VAE、GAN 基础、Diffusion、DDPM、DDIM、Stable Diffusion、DiT、ControlNet、LoRA、视频扩散模型。
- 视频方向：时序建模、关键帧、光流、视频 caption、视频检索、视频生成评测、一致性、运动控制。
- 3D 方向：NeRF、3D Gaussian Splatting、3D 重建、相机参数、点云/mesh 基础。
- 语音方向：声学特征、Mel Spectrogram、CTC、RNN-T、Conformer、Whisper、VITS、FastSpeech、声纹、语音增强。
- 数字人方向：ASR + LLM + TTS + Avatar，唇形同步、表情驱动、低延迟流式链路。

学习顺序：

1. 用 PyTorch 训练一个 CIFAR10 图像分类模型，理解 CNN/ViT 输入输出。
2. 用 CLIP 做图文检索，完成“图片搜文本/文本搜图片”。
3. 用开源 VLM 做图片问答，整理失败案例。
4. 用 Stable Diffusion/ComfyUI 做 LoRA 风格微调，理解数据、prompt、采样、CFG、ControlNet。
5. 做一个短视频理解项目：视频抽帧、caption、向量入库、按文本搜索片段。
6. 做一个文档多模态 RAG：PDF 图片、表格、OCR、布局解析、引用回答。
7. 语音方向：用 Whisper 做 ASR，接 LLM，再用 TTS 输出，完成语音助手闭环。
8. 数字人方向：语音输入 -> 意图理解 -> 文本回复 -> TTS -> Avatar 或视频口型驱动。
9. 建立评测：WER、CER、CLIPScore、人工偏好、视频一致性、延迟。
10. 写项目报告：模型选择、数据、推理链路、延迟瓶颈、badcase。

### 主线 E：AI Infra / 推理优化 / 训练系统

适合目标：字节机器学习系统、推理系统、训练集群；阿里 Qwen 训练/推理工程、AI Compiler、GPU Kernel、分布式训练推理、Agent Runtime；腾讯 AI 基础设施、系统架构与安全。

必须掌握：

- 基础工程：Linux、Shell、网络、进程线程、内存、文件系统、Docker、Kubernetes、Prometheus/Grafana。
- 编程语言：Python 必须熟；C++ 对这个方向基本必须；CUDA/Triton 至少掌握一门 GPU 编程路径。
- 推理系统：prefill/decode、KV Cache、PagedAttention、Continuous Batching、Speculative Decoding、量化、并发调度、流式输出。
- 训练系统：DDP、FSDP、ZeRO、Tensor Parallel、Pipeline Parallel、NCCL、checkpoint、容错、弹性训练。
- 性能优化：吞吐、延迟、显存、算子融合、FlashAttention、通信计算重叠、profile、瓶颈定位。
- 框架：PyTorch、vLLM、TensorRT-LLM、Triton Inference Server、DeepSpeed、Megatron-LM、Ray。
- 成本治理：不同模型大小、batch size、上下文长度、量化策略对 QPS/P95/成本的影响。

学习顺序：

1. 学 C++ 基础：语法、STL、RAII、智能指针、多线程、编译链接、CMake。
2. 学 Linux 性能工具：top、htop、nvidia-smi、iostat、pidstat、perf、nsys/nsight。
3. 部署一个 vLLM 服务，压测不同 batch size、max tokens、并发数。
4. 实验量化：FP16、INT8、INT4，对比显存、吞吐、质量变化。
5. 学 FlashAttention 与 KV Cache 原理，能解释为什么长上下文推理贵。
6. 用 Triton 写一个简单向量加法/矩阵乘算子，理解 block/thread/grid。
7. 用 DeepSpeed/FSDP 跑一次小模型分布式训练实验。
8. 搭建 Prometheus/Grafana 监控推理服务 QPS、P50/P95、显存、错误率。
9. 做推理优化报告：瓶颈、实验变量、对比表、结论。
10. 如果目标非常偏底层，继续补 CUDA、编译器、NCCL、RDMA、SmartNIC、AI 芯片。

可放简历的项目表达：

- 基于 vLLM 部署开源 LLM 推理服务，设计压测脚本评估不同并发、上下文长度和量化策略下的吞吐、P95 延迟、显存占用。
- 分析 prefill/decode 与 KV Cache 对性能的影响，给出 batch、max token、模型量化和缓存策略的优化建议。
- 搭建可观测性面板，监控 QPS、错误率、GPU 利用率、显存、请求排队时间。

### 主线 F：AI 数据 / 数据工程 / 评测工程

适合目标：字节模型数据、用户反馈信号、评测体系；阿里线上回流数据训练评测体系、AI 数据 Infra；腾讯 AI 数据/数据工程。

必须掌握：

- 数据工程：SQL、Python、Pandas、Spark 基础、Flink 概念、数据仓库、ETL、数据质量校验。
- 大模型数据：清洗、去重、去毒、PII 脱敏、语言识别、质量打分、数据配比、合成数据。
- 标注体系：指令数据、偏好数据、工具调用轨迹、拒答数据、安全数据、多模态标注。
- 评测体系：Golden Set、自动评测、人工评测、一致性、抽样、置信区间、badcase 分类。
- 数据闭环：线上日志、用户反馈、搜索点击、工具调用结果、模型回答质量、回流训练。

学习顺序：

1. 用 SQL 练会 join、group by、窗口函数、分桶、留存、转化漏斗。
2. 用 Pandas/Spark 处理千万级样本的清洗、去重、统计。
3. 构造一个指令数据集，包含任务类型、输入、输出、难度、来源、质量分。
4. 构造一个偏好数据集，包含 chosen/rejected、偏好理由、安全标签。
5. 构造 RAG/Agent 评测集，覆盖正常问题、无答案问题、跨文档问题、工具调用问题。
6. 写自动评测脚本，输出准确率、召回率、引用准确率、幻觉率、延迟、成本。
7. 对 badcase 做根因归类：数据缺失、召回失败、rerank 错误、prompt 错误、工具失败、模型推理错误。
8. 设计线上反馈表结构，记录 query、context、answer、tool_call、feedback、trace_id。
9. 做一次数据回流：把高质量反馈转成训练或评测样本。
10. 输出数据治理文档：字段、口径、质量规则、隐私规则、版本管理。

## 16.3 32 周详细学习路线

### 第 1-4 周：编程、数学、工具地基

第 1 周：Python 工程基础

- 学习内容：Python 语法、函数、类、异常、文件读写、venv/uv/pip、typing、dataclass、logging。
- 练习任务：写一个命令行笔记搜索工具，支持新增、搜索、删除、导出 Markdown。
- 验收标准：代码有 README、单元测试不少于 10 个、能用命令行运行。
- 面试准备：能解释 list/dict/set、生成器、装饰器、上下文管理器、浅拷贝/深拷贝。

第 2 周：Git、Linux、SQL

- 学习内容：Git 分支、commit、merge/rebase、stash、Linux 常用命令、Shell、SQLite/PostgreSQL、SQL join/window function。
- 练习任务：把第 1 周项目放入 Git，使用 SQLite 存储笔记，写 20 条 SQL 查询。
- 验收标准：能回滚一次提交，能解释索引、事务、唯一约束、慢查询基本排查。
- 面试准备：准备 Git 冲突解决、数据库索引、事务 ACID、SQL 优化。

第 3 周：数学基础

- 学习内容：矩阵乘法、向量空间、特征值、概率分布、期望方差、最大似然、交叉熵、KL 散度、梯度下降。
- 练习任务：不用深度学习框架实现线性回归、逻辑回归、softmax 分类。
- 验收标准：能画出 loss 曲线，能解释学习率过大/过小的现象。
- 面试准备：交叉熵为什么适合分类，L1/L2 正则有什么区别，梯度下降为何能优化。

第 4 周：数据结构与算法开局

- 学习内容：复杂度、数组、链表、栈、队列、哈希表、双指针、滑动窗口。
- 练习任务：LeetCode 30 题，重点做 easy/medium，写题解。
- 验收标准：每题能说清楚思路、复杂度、边界条件。
- 面试准备：两数之和、三数之和、最长无重复子串、最小覆盖子串、合并区间、LRU Cache。

### 第 5-8 周：机器学习和推荐/搜索基础

第 5 周：传统机器学习

- 学习内容：训练/验证/测试集、过拟合、欠拟合、特征工程、线性模型、树模型、随机森林、XGBoost/LightGBM。
- 练习任务：做一个二分类项目，比如用户是否点击/是否流失预测。
- 验收标准：输出 AUC、Precision、Recall、F1、混淆矩阵、特征重要性。
- 面试准备：AUC 含义、GBDT 为什么强、类别不平衡怎么处理。

第 6 周：推荐系统入门

- 学习内容：协同过滤、矩阵分解、召回/排序/重排、冷启动、负采样、Embedding。
- 练习任务：用 MovieLens 做推荐，分别实现 itemCF、matrix factorization、Two-Tower。
- 验收标准：输出 Recall@K、NDCG@K、HitRate，对比不同模型。
- 面试准备：推荐系统为什么分多阶段，召回和排序优化目标有什么区别。

第 7 周：搜索系统入门

- 学习内容：倒排索引、TF-IDF、BM25、分词、Query Rewrite、Learning to Rank、向量检索。
- 练习任务：用 Elasticsearch/OpenSearch 或 Whoosh 做文档搜索，再加向量检索。
- 验收标准：支持关键词检索、语义检索、过滤、排序、分页。
- 面试准备：BM25 公式直觉，向量检索和关键词检索如何融合。

第 8 周：数据工程基础

- 学习内容：Pandas、数据清洗、缺失值、异常值、去重、采样、数据版本、质量校验。
- 练习任务：构造一个商品数据集，清洗标题、属性、价格、类目、图片 URL。
- 验收标准：输出数据质量报告，包括缺失率、重复率、异常价格、类目分布。
- 面试准备：如何发现数据污染，如何做训练/测试集切分避免泄漏。

### 第 9-12 周：深度学习、PyTorch、Transformer

第 9 周：PyTorch 基础

- 学习内容：Tensor、autograd、Dataset/DataLoader、nn.Module、optimizer、scheduler、checkpoint。
- 练习任务：训练 MNIST/CIFAR10 分类模型。
- 验收标准：能保存/加载模型，能画 loss/accuracy 曲线，能解释每一行训练循环。
- 面试准备：反向传播、batch size、epoch、optimizer、weight decay。

第 10 周：深度学习核心结构

- 学习内容：MLP、CNN、RNN/LSTM、Attention、Normalization、Dropout、Residual。
- 练习任务：实现文本分类模型，比较 RNN、CNN、Transformer Encoder。
- 验收标准：输出模型结构、参数量、训练速度、准确率对比。
- 面试准备：Attention 为什么能建模长距离依赖，LayerNorm 和 BatchNorm 区别。

第 11 周：Transformer 与 LLM 架构

- 学习内容：Self-Attention、Masked Attention、RoPE、RMSNorm、SwiGLU、GQA/MQA、KV Cache、MoE、Tokenizer。
- 练习任务：阅读并跑通 nanoGPT，训练一个小语言模型。
- 验收标准：能解释 prefill/decode、为什么 KV Cache 能加速、上下文越长为什么越贵。
- 面试准备：Transformer 计算复杂度，位置编码作用，MoE 优缺点。

第 12 周：Hugging Face 与开源模型

- 学习内容：transformers、datasets、tokenizers、accelerate、PEFT、bitsandbytes。
- 练习任务：加载一个中文开源模型，完成推理、批量生成、LoRA 微调样例。
- 验收标准：有训练脚本、推理脚本、评测脚本、实验记录。
- 面试准备：SFT 数据格式、LoRA 原理、QLoRA 为什么省显存。

### 第 13-16 周：RAG、Agent、评测

第 13 周：基础 RAG

- 学习内容：文档解析、chunk、embedding、向量库、prompt 拼接、引用。
- 练习任务：做一个本地知识库问答系统。
- 验收标准：至少导入 50 篇文档，回答必须带引用。
- 面试准备：chunk 太大/太小的问题，embedding 模型如何选择。

第 14 周：高级 RAG

- 学习内容：混合检索、rerank、query rewrite、multi-query、HyDE、上下文压缩、无答案拒答。
- 练习任务：给第 13 周系统加 BM25 + reranker + 无答案检测。
- 验收标准：构建 100 条评测集，统计 Recall@5、引用准确率、拒答准确率。
- 面试准备：召回失败怎么排查，RAG 幻觉怎么降低。

第 15 周：Agent 基础

- 学习内容：ReAct、工具调用、Planning、Reflection、Memory、状态机、错误恢复。
- 练习任务：做一个研究报告 Agent，能搜索知识库、调用计算工具、生成 Markdown 报告。
- 验收标准：至少支持 5 个工具，所有工具调用有日志和 trace_id。
- 面试准备：Agent 和普通 ChatBot 的区别，工具调用如何做权限和安全。

第 16 周：Agent 评测与工程化

- 学习内容：任务成功率、工具调用成功率、成本、延迟、稳定性、prompt regression、线上反馈。
- 练习任务：为 Agent 写 50 条端到端测试，记录每次调用轨迹。
- 验收标准：输出评测报告，至少包含成功率、平均步数、失败分类、优化建议。
- 面试准备：Agent 不稳定怎么办，多 Agent 什么时候有价值，Memory 如何避免污染。

### 第 17-24 周：选择一个大厂岗位分支深挖

第 17-18 周：如果选大模型应用/Agent

- 深挖内容：MCP、浏览器/数据库/文件系统工具、沙箱执行、长任务规划、报告生成、权限边界。
- 项目任务：企业知识库 Agent 升级为“可执行任务”的系统，比如自动生成竞品分析、自动整理会议纪要、自动写 SQL 分析数据。
- 验收标准：任务成功率超过 70%，失败有可解释原因，支持人工确认关键操作。

第 17-18 周：如果选后训练/RLHF

- 深挖内容：SFT、DPO、Reward Model、PPO/GRPO、偏好数据、拒答数据、工具调用轨迹。
- 项目任务：微调一个小模型，让它在某个领域问答或代码任务上明显提升。
- 验收标准：微调前后同一评测集分数提升，badcase 有归因。

第 17-18 周：如果选搜索/推荐/广告

- 深挖内容：召回、粗排、精排、多目标排序、CTR/CVR、NDCG、A/B 测试、LLM 意图理解。
- 项目任务：AI 导购或内容推荐系统，结合传统排序模型和 LLM 解释。
- 验收标准：离线指标可复现，推荐理由不编造，商品/内容引用准确。

第 17-18 周：如果选 AI Infra

- 深挖内容：vLLM、PagedAttention、量化、推理并发、Prometheus 监控、C++/CUDA 基础。
- 项目任务：部署 LLM 推理服务并做压测优化。
- 验收标准：输出 QPS/P95/显存/成本对比表。

第 19-20 周：论文与源码阅读

- 必读论文/技术：Attention Is All You Need、BERT、GPT 系列思想、InstructGPT、LoRA、DPO、RAG、ReAct、Toolformer、CLIP、Diffusion、FlashAttention。
- 源码阅读：nanoGPT、transformers generation、PEFT LoRA、vLLM 调度核心、一个向量库样例。
- 验收标准：每篇论文写 1 页笔记，包括问题、方法、实验、局限、可用于项目的点。

第 21-22 周：项目增强

- 加入真实工程能力：鉴权、队列、重试、幂等、日志、监控、配置、灰度、错误码、部署脚本。
- 加入真实 AI 能力：评测集、badcase、数据闭环、自动回归、成本统计。
- 验收标准：项目不是 demo，能让别人按 README 跑起来，能看到指标。

第 23-24 周：简历项目打磨

- 写项目背景：业务问题是什么，为什么普通方案不够。
- 写技术方案：架构图、模块、数据流、模型/工具选择。
- 写指标：准确率、召回、延迟、成本、吞吐、失败率。
- 写难点：数据质量、检索失败、幻觉、工具调用不稳定、推理成本、长上下文。
- 写结果：用数字表达，不要只写“提升效果明显”。

### 第 25-32 周：面试冲刺与作品集

第 25-26 周：算法题冲刺

- 每天 3-5 题，重点 medium。
- 每题必须写：思路、复杂度、边界条件、易错点。
- 高频类别：数组/哈希、双指针、滑动窗口、二分、栈、堆、链表、树、图、动态规划、回溯、并查集、前缀和、单调栈、拓扑排序。

第 27-28 周：机器学习/深度学习八股

- 准备 100 个问答卡片。
- 内容覆盖：过拟合、正则、优化器、Transformer、Attention、Embedding、RAG、RLHF、推荐系统、评测指标。
- 每天口述 20 个问题，训练“说清楚”的能力。

第 29-30 周：项目面试模拟

- 准备 3 分钟项目介绍。
- 准备 10 分钟深入讲解。
- 准备 30 个追问：为什么这样切 chunk、为什么选这个 embedding、rerank 怎么评估、Agent 失败怎么办、成本怎么控制、线上怎么灰度。

第 31 周：公司定向准备

- 字节：强化算法题、系统设计、Agent/RL/模型训练理解、指标意识、快速迭代能力。
- 阿里：强化业务场景、电商/搜索/推荐/云/安全结合，强调数据闭环和产业落地。
- 腾讯：强化产品场景、内容/社交/游戏/数字人、稳定性、用户体验和大规模业务指标。

第 32 周：投递材料

- 简历：1 页，项目不超过 3 个，每个项目必须有指标。
- GitHub：至少 2 个可运行项目，有 README、架构图、运行命令、评测结果。
- 博客/文档：至少 5 篇技术文章，写项目复盘、论文笔记、badcase 分析。
- 面试材料：自我介绍、项目介绍、算法模板、ML/DL 问答卡、公司岗位匹配表。

## 16.4 数据结构与算法详细清单

不管投字节、阿里还是腾讯，算法题仍然要准备。AI 岗不是只看模型，尤其校招和实习很容易先过算法筛选。

### 必学类别与目标题量

| 类别 | 目标题量 | 必须掌握的能力 |
| --- | ---: | --- |
| 数组/哈希 | 20 | 去重、计数、映射、前缀统计 |
| 双指针/滑动窗口 | 20 | 区间维护、最长/最短子数组、去重窗口 |
| 二分 | 15 | 单调性判断、边界查找、答案二分 |
| 链表 | 10 | 反转、快慢指针、环、合并 |
| 栈/单调栈 | 15 | 括号、表达式、下一个更大元素、直方图 |
| 堆/优先队列 | 15 | TopK、合并 K 路、动态中位数 |
| 树/二叉树 | 25 | DFS/BFS、递归、路径、最近公共祖先 |
| 图 | 20 | BFS/DFS、最短路、拓扑排序、并查集 |
| 动态规划 | 35 | 背包、序列、区间、状态压缩、树形 DP |
| 回溯 | 15 | 排列组合、子集、剪枝 |
| 字符串 | 15 | KMP 思想、Trie、字符串哈希、编辑距离 |
| 综合设计 | 10 | LRU、LFU、限流器、延迟队列、排行榜 |

### 推荐刷题顺序

1. 第 1 轮，150 题：只追求会做，覆盖所有类别。
2. 第 2 轮，80 题：只刷 medium 和 hard 入门，练速度。
3. 第 3 轮，50 题：按公司面试频率复盘，要求 20 分钟内讲清楚。

### 高频题型举例

- 哈希：Two Sum、Group Anagrams、Longest Consecutive Sequence。
- 滑动窗口：Longest Substring Without Repeating Characters、Minimum Window Substring、Permutation in String。
- 二分：Search in Rotated Sorted Array、Find First and Last Position、Median of Two Sorted Arrays。
- 链表：Reverse Linked List、Merge Two Sorted Lists、Linked List Cycle、LRU Cache。
- 树：Level Order Traversal、Lowest Common Ancestor、Diameter of Binary Tree、Serialize and Deserialize Binary Tree。
- 图：Number of Islands、Course Schedule、Clone Graph、Word Ladder。
- DP：Climbing Stairs、House Robber、Coin Change、Longest Increasing Subsequence、Edit Distance、Longest Common Subsequence。
- 堆：Top K Frequent Elements、Merge K Sorted Lists、Find Median from Data Stream。
- 回溯：Permutations、Subsets、Combination Sum、N-Queens。

## 16.5 C++ 到底学到什么程度

结论：

- 投大模型应用、RAG、Agent、AI 产品工程：C++ 不是第一优先级，Python + 后端 + LLM 工程更重要。
- 投算法研究：C++ 加分，但通常不是唯一核心，PyTorch/数学/论文/实验更重要。
- 投 AI Infra、推理优化、训练系统、机器人、自动驾驶、音视频编解码：C++ 基本要学，而且要能写工程代码。

如果只做应用岗，C++ 学到：

- 基础语法、指针/引用、类、STL、时间复杂度。
- 能用 C++ 刷算法题。
- 能读懂简单 C++ 工程。

如果做 Infra 岗，C++ 学到：

- RAII、智能指针、移动语义、模板、并发、多线程、锁、原子变量。
- CMake、gdb/lldb、性能分析、内存泄漏排查。
- CUDA/Triton 基础、GPU 内存层级、kernel launch、shared memory、warp、block/grid。
- 能读懂 vLLM/TensorRT-LLM/Triton/PyTorch extension 的部分源码。

## 16.6 必做项目：从入门到大厂可聊

### 项目 1：企业知识库 RAG + Agent

功能要求：

- 支持 PDF、Markdown、网页、Word 文档导入。
- 支持文档切分、embedding、向量入库、BM25、rerank。
- 回答必须带引用，引用能定位到文档段落。
- 支持无答案拒答，不允许强行编造。
- 支持工具调用：数据库查询、计算器、代码执行、报告生成。
- 支持评测集和 badcase 管理。

技术栈：

- FastAPI。
- SQLite/PostgreSQL。
- Qdrant/Milvus/FAISS。
- Elasticsearch/OpenSearch，可选。
- sentence-transformers / bge embedding。
- reranker。
- pytest。
- Docker。

验收指标：

- Top-5 召回率。
- 引用准确率。
- 无答案拒答准确率。
- 平均响应延迟。
- P95 延迟。
- 单次回答 token 成本。
- badcase 修复前后对比。

### 项目 2：AI Search / DeepResearch Agent

功能要求：

- 输入一个开放问题，自动拆解子问题。
- 多轮检索，合并信息，去重和冲突处理。
- 生成结构化 Markdown 报告。
- 报告中每个关键结论都要有来源。
- 支持继续追问和局部重写。

技术重点：

- Query Planning。
- Search Tool Calling。
- Evidence Ranking。
- Claim Verification。
- Citation。
- Report Agent。
- 长任务状态恢复。

对齐岗位：

- 字节 LLM 搜索 / Search Agent。
- 阿里 Agentic Search / AI Search。
- 腾讯搜索、模型应用、Agent。

### 项目 3：LoRA SFT + DPO 后训练

功能要求：

- 选择一个领域，比如代码问答、知识库问答、客服话术、SQL 生成。
- 构造 1000-5000 条 SFT 数据。
- 构造 500-2000 条偏好数据。
- 完成 LoRA SFT。
- 完成 DPO。
- 对比 base、SFT、DPO 三个版本效果。

验收指标：

- 任务准确率。
- 人工偏好胜率。
- 拒答准确率。
- 幻觉率。
- 输出格式合规率。
- 推理延迟。

### 项目 4：AI 导购 / 商品理解 / 推荐排序

功能要求：

- 商品数据清洗与类目体系。
- 商品标题、属性、图片的多模态理解，可先做文本版，后续加图片。
- 用户意图解析。
- BM25 + 向量召回。
- 排序模型。
- LLM 生成推荐理由。
- 用户反馈闭环。

验收指标：

- Recall@20。
- NDCG@10。
- CTR 预估 AUC。
- 推荐解释准确率。
- 用户反馈转训练样本比例。

对齐岗位：

- 阿里 AI 导购、电商购物 Agent、智能推荐、广告大模型。
- 腾讯搜索推荐与模型应用。
- 字节搜索内容理解和个性化。

### 项目 5：vLLM 推理服务压测与优化

功能要求：

- 部署开源 LLM。
- 支持 OpenAI-compatible API。
- 编写压测脚本。
- 对比不同并发、输入长度、输出长度、batch、量化方案。
- 建立监控面板。

验收指标：

- QPS。
- Tokens/s。
- P50/P95/P99 延迟。
- GPU 显存。
- GPU 利用率。
- 错误率。
- 单 token 成本估算。

对齐岗位：

- 字节机器学习系统。
- 阿里 AI Infra、推理优化、训练/推理工程。
- 腾讯 AI 基础设施。

### 项目 6：多模态内容理解 / 视频搜索

功能要求：

- 视频抽帧。
- 图像 caption。
- OCR。
- ASR，可选。
- CLIP/VLM 向量化。
- 支持按自然语言搜索视频片段。
- 生成视频摘要。

验收指标：

- 检索 Recall@K。
- 摘要准确率。
- OCR/ASR 错误率。
- 人工相关性评分。

对齐岗位：

- 字节视觉智能、视频生成、语音智能。
- 阿里 Wan、多模态搜索、多模态生成。
- 腾讯多模态、视觉、语音、内容 AI、数字人。

## 16.7 简历应该怎么写才像 AI 岗

不要写：

- 熟悉大模型。
- 使用 LangChain 搭建智能体。
- 调用 API 完成问答。
- 了解机器学习算法。

要写：

- 项目规模：文档数量、样本数量、问题数量、模型大小、并发数。
- 技术方案：BM25 + 向量召回 + rerank，ReAct + Tool Calling，LoRA + DPO。
- 指标：Recall@5、NDCG@10、AUC、P95、Tokens/s、幻觉率、引用准确率、任务成功率。
- 问题与修复：召回失败、上下文污染、工具调用失败、偏好数据质量差、训练过拟合、推理成本高。
- 业务价值：减少人工检索时间、提升问答正确率、降低推理成本、提高推荐相关性。

简历项目模板：

```text
项目名称：企业知识库 RAG + Agent 系统
背景：面向企业文档问答和自动报告生成，解决知识检索慢、答案不可追溯、复杂问题需要多步处理的问题。
技术：FastAPI + Qdrant + BM25 + reranker + Tool Calling + Eval Pipeline。
贡献：负责文档解析、混合检索、引用溯源、Agent 工具调用和评测集建设。
指标：构建 120 条 Golden Set，Top-5 召回率 xx%，引用准确率 xx%，无答案拒答准确率 xx%，P95 延迟 xx 秒。
难点：针对跨文档问题召回失败，引入 query rewrite 和 rerank；针对幻觉问题加入引用约束和拒答策略。
```

## 16.8 面试追问清单

### RAG/Agent 方向

- 你的 chunk size 怎么定？为什么？
- overlap 多大合适？如何避免上下文重复？
- embedding 模型怎么选？中文场景怎么评估？
- BM25 和向量检索各自解决什么问题？
- reranker 放在哪里？为什么会提升？
- 如何判断模型回答引用是否正确？
- 无答案问题如何拒答？
- Agent 工具调用失败怎么办？
- 长任务如何保存状态？
- 如何防 prompt injection？
- 多 Agent 是否一定比单 Agent 好？
- 如何降低 token 成本？

### LLM 算法/后训练方向

- Transformer 为什么使用 self-attention？
- Attention 复杂度是多少？长上下文怎么优化？
- RoPE 的直觉是什么？
- RMSNorm 和 LayerNorm 有什么区别？
- KV Cache 为什么加速推理？
- LoRA 的参数量怎么算？
- SFT 和 DPO 的区别？
- RLHF 为什么需要 KL 约束？
- Reward Model 怎么训练？
- 偏好数据质量差会怎样？
- 训练 loss spike 怎么排查？
- 如何防数据泄漏和 benchmark contamination？

### 搜索/推荐/广告方向

- 召回、粗排、精排分别优化什么？
- BM25 的核心思想是什么？
- 向量召回如何评估？
- Two-Tower 为什么适合召回？
- AUC 和 NDCG 分别衡量什么？
- 冷启动怎么做？
- 多目标排序怎么平衡？
- 推荐理由如何避免编造？
- LLM 在搜索推荐里应该放在哪些环节？
- A/B 实验如何设计？

### AI Infra 方向

- Prefill 和 Decode 的瓶颈分别是什么？
- KV Cache 为什么占显存？
- Continuous Batching 如何提高吞吐？
- 量化会带来什么收益和风险？
- FlashAttention 为什么快？
- FSDP 和 ZeRO 的区别？
- 张量并行和流水并行适合什么场景？
- NCCL 在分布式训练里做什么？
- 如何定位 GPU 利用率低？
- 如何设计 LLM 服务限流和降级？

## 16.9 每天怎么安排

如果每天只有 2 小时：

- 30 分钟：算法题 1 题，必须复盘。
- 40 分钟：学习一个 AI 概念或读一段源码。
- 40 分钟：写项目代码。
- 10 分钟：记录今天学到什么、遇到什么 bug、明天做什么。

如果每天有 4 小时：

- 60 分钟：算法题 2-3 题。
- 60 分钟：课程/论文/源码。
- 100 分钟：项目实现。
- 20 分钟：整理笔记和简历素材。

周末安排：

- 半天：补齐一周没完成的代码。
- 半天：写一篇项目笔记或论文笔记。
- 半天：做一次项目评测和 badcase 分析。
- 半天：模拟面试或复盘算法题。

## 16.10 阶段性验收标准

### 1 个月后

你应该具备：

- Python/SQL/Git/Linux 基础可用。
- LeetCode 30-50 题。
- 能手写线性回归、逻辑回归。
- 能解释训练/验证/测试集、过拟合、AUC、交叉熵。

### 2 个月后

你应该具备：

- LeetCode 80-100 题。
- 能完成一个机器学习分类项目。
- 能完成一个搜索或推荐小项目。
- 能讲清楚 BM25、向量检索、召回/排序。

### 3 个月后

你应该具备：

- 能用 PyTorch 训练模型。
- 能讲清楚 Transformer、Attention、Embedding、KV Cache。
- 能跑通 Hugging Face 模型推理和 LoRA 微调。
- 有一个基础 RAG 项目。

### 4 个月后

你应该具备：

- RAG 项目支持混合检索、rerank、引用、拒答。
- Agent 项目支持工具调用、状态追踪、评测。
- 有 100 条以上评测集。
- 能讲清楚 RAG/Agent 的失败原因和优化方法。

### 5 个月后

你应该具备：

- 选择一个分支深挖：后训练、AI Search、推荐、AI Infra、多模态、语音、安全。
- 至少完成一个可展示的进阶项目。
- 简历里有明确指标和项目难点。

### 6-8 个月后

你应该具备：

- LeetCode 150-250 题。
- 2-3 个高质量 AI 项目。
- 5 篇以上技术文章。
- 能通过 3 轮模拟技术面。
- 能针对字节、阿里、腾讯分别讲清楚自己的岗位匹配度。

## 16.11 推荐资料清单

基础编程与数学：

- 《Python Crash Course》或任意系统 Python 教程。
- 《算法图解》入门，然后刷 LeetCode。
- 《Introduction to Linear Algebra》或 3Blue1Brown 线性代数。
- Stanford CS229 机器学习讲义。

机器学习与深度学习：

- 《Hands-On Machine Learning with Scikit-Learn, Keras, and TensorFlow》。
- 《Dive into Deep Learning》。
- PyTorch 官方教程。
- fast.ai Practical Deep Learning。

NLP/LLM：

- Stanford CS224N。
- Hugging Face Course。
- nanoGPT。
- transformers 官方文档。
- PEFT 官方文档。

RAG/Agent：

- LlamaIndex 文档。
- LangChain/LangGraph 文档。
- OpenAI/Anthropic/Google/阿里云百炼等模型 API 文档。
- RAGAS、DeepEval、promptfoo。
- MCP 官方资料。

搜索/推荐：

- 《推荐系统实践》。
- Google 推荐系统相关公开课程。
- Elasticsearch/OpenSearch 文档。
- FAISS/Milvus/Qdrant 文档。

AI Infra：

- vLLM 文档与源码。
- TensorRT-LLM 文档。
- DeepSpeed 文档。
- Megatron-LM。
- CUDA by Example 或 NVIDIA CUDA 教程。
- Triton language 文档。

多模态/语音：

- CLIP、BLIP、SAM、DINO、Stable Diffusion、DiT 相关论文与开源项目。
- Whisper。
- ESPnet。
- VITS/FastSpeech 相关资料。

## 16.12 最推荐的学习路径选择

如果你目前没有明确方向，建议优先走这条：

1. Python + SQL + Git + Linux。
2. 数据结构与算法 150 题。
3. 机器学习 + PyTorch + Transformer。
4. 企业知识库 RAG。
5. Agent 工具调用与评测。
6. AI Search / 推荐基础。
7. LoRA SFT + DPO。
8. 根据目标岗位选择一个深挖方向：
   - 想投字节 Seed：Agent/RL/后训练/多模态/AI Infra 任选一条深挖。
   - 想投阿里：AI Search、电商 Agent、Qwen 后训练、AI Infra、安全 Agent 更匹配。
   - 想投腾讯：LLM/NLP、多模态语音视觉、搜索推荐、模型应用、AI 数据工程更匹配。

最稳的作品集组合：

- 一个企业知识库 RAG + Agent。
- 一个 AI Search / AI 导购 / 推荐排序。
- 一个 LoRA SFT + DPO 或 vLLM 推理优化。

这样组合的好处是：既能覆盖大模型应用岗，又能向算法、搜索推荐、Infra 或后训练方向延展。面试时你不是只会“调 API”，而是能讲数据、模型、系统、指标和业务闭环。

## 16.13 最新岗位来源记录

- 字节 Seed 加入我们：https://seed.bytedance.com/zh/career
- 字节 Seed 大模型人才校招：https://seed.bytedance.com/zh/seedearlycareer
- 阿里星顶尖人才计划：https://campus-talent.alibaba.com/campus/alistar
- 阿里巴巴校园招聘：https://campus-talent.alibaba.com/
- 腾讯校园招聘：https://careers.tencent.com/campusrecruit.html
- 腾讯 AI Lab 招聘：https://ailab.tencent.com/ailab/zh/recruit/
- 腾讯 AI Lab 研究方向：https://ailab.tencent.com/ailab/zh/index/
- 腾讯人工智能业务介绍：https://www.tencent.com.cn/zh-cn/business/artificial-intelligence.html
- 腾讯 2027 青云计划公开报道补充：IT之家、第一财经，因腾讯招聘官网页面对青云专题信息展示较简略，六大方向用公开报道作补充交叉验证。

## 16.14 本次补充检索摘要

- 网站：opencli | 查询词：opencli list -f yaml | 次数：1 次预检 | 状态：成功
- 网站：opencli doubao | 查询词：字节 Seed、阿里星/Qwen、腾讯 AI Lab/青云计划 AI 岗位方向归纳 | 次数：1 | 状态：超时，未作为主要依据
- 网站：Web 搜索 | 查询词：ByteDance Seed career AI foundation model inference multimodal agent roles official / 字节 Seed AI 招聘 | 次数：1 组
- 网站：Web 搜索 | 查询词：阿里星 2027 AI 人才计划 Qwen Wan Agentic Search Agent 代码 Agent 安全 Agent | 次数：1 组
- 网站：Web 搜索 | 查询词：腾讯 2027 青云计划 AI技术 六大方向 大模型 多模态 官方 / Tencent AI Lab recruit | 次数：1 组
- 主要依据：优先使用字节 Seed、阿里巴巴校园招聘、腾讯招聘、腾讯 AI Lab、腾讯官网；腾讯青云六大方向因官网检索页信息较少，补充使用近期公开报道交叉核对。