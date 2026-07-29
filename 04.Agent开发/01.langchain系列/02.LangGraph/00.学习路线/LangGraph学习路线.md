# LangGraph 是什么

## 定位

LangGraph 是 LangChain 生态中面向 Agent 和复杂 LLM 工作流的底层编排框架。它不是简单的“链式调用工具”，而是用“图”来表达流程：节点负责执行逻辑，边负责控制流，状态负责在节点之间传递信息。

适合使用 LangGraph 的场景：

- 多步骤 Agent，需要在不同节点之间传递状态。
- 流程中存在条件分支、循环、重试或人工审批。
- 需要持久化执行状态，支持中断后继续运行。
- 需要长期维护的生产级 Agent，而不是一次性 prompt demo。
- 需要多 Agent 协作、子图拆分、工具调用和可观测性。

不一定需要 LangGraph 的场景：

- 一次简单 LLM 调用。
- 单轮问答。
- 只有固定顺序的两三步脚本。
- 没有状态管理、恢复、分支、循环需求的轻量任务。

## 核心心智模型

LangGraph 的核心心智模型是：

```text
State：全局状态
Node：处理状态的函数
Edge：决定下一个节点
Reducer：决定多个节点如何合并状态更新
Checkpoint：保存每一步状态
Command：在节点中同时做状态更新和路由控制
Interrupt：暂停图执行，等待人工输入后恢复
```

可以把 LangGraph 理解为“可持久化、可恢复、可分支、可循环的 Agent 状态机”。

# 学习路线

## 推荐顺序

这套笔记适合按照“先跑起来、再理解原理、最后工程化”的顺序阅读。不要一开始就纠结所有 API，先建立图、状态和控制流的基本直觉。

建议按照下面顺序学习：

1. 先理解 LangGraph 与普通链式调用的区别。
2. 学会最小 `StateGraph` 示例。
3. 掌握 `State`、`Node`、`Edge`、`START`、`END`。
4. 学会 reducer，理解状态合并。
5. 学会条件边和循环。
6. 学会工具调用和 ReAct Agent。
7. 学会 checkpoint、thread、短期记忆。
8. 学会长期记忆和 memory store。
9. 学会 interrupt 和 human-in-the-loop。
10. 学会 subgraph 和多 Agent 拆分。
11. 学会工程化：配置、错误处理、观测、测试、部署。

## 模块安排

本目录建议按以下模块阅读：

| 顺序 | 模块 | 重点 |
|---|---|---|
| 00 | 学习路线 | 建立整体地图 |
| 01 | 快速上手 | 跑通最小图和聊天 Agent |
| 02 | 核心概念 | StateGraph、状态、节点、边、reducer |
| 03 | 控制流 | 条件边、循环、Command、Send |
| 04 | 工具调用与 Agent | ToolNode、tools_condition、create_agent |
| 05 | 记忆与持久化 | checkpoint、thread、短期/长期记忆 |
| 06 | 人机协作与中断 | interrupt、resume、审批流 |
| 07 | 子图与多 Agent | subgraph、父子图状态、多 Agent 编排 |
| 08 | 工程实践 | 测试、调试、错误处理、生产建议 |

# 阅读建议

## 如何使用这套笔记

建议每学完一篇都做一个最小练习：

- 学完快速上手：手写一个两节点图。
- 学完核心概念：给 messages 字段加 reducer。
- 学完控制流：写一个带条件分支的图。
- 学完工具调用：写一个能调用查询函数的 Agent。
- 学完记忆持久化：让同一个 `thread_id` 记住历史消息。
- 学完中断：写一个人工审批流程。
- 学完子图：把一个复杂流程拆成两个子图。

# 学习目标

## 初级目标

学完初级部分后，应该能做到：

- 创建一个 `StateGraph`。
- 定义状态结构。
- 添加节点和边。
- 编译并运行图。
- 看懂 `START` 和 `END` 的含义。
- 理解为什么节点应该返回“状态增量”，而不是直接修改全局对象。

## 中级目标

学完中级部分后，应该能做到：

- 使用 reducer 合并消息列表。
- 使用条件边做分支。
- 使用循环构建 Agent 主循环。
- 接入工具调用。
- 使用 checkpoint 保存会话状态。
- 通过 `thread_id` 区分不同会话。

## 高级目标

学完高级部分后，应该能做到：

- 使用 interrupt 构建人工审批流程。
- 使用 `Command(resume=...)` 恢复图执行。
- 使用 subgraph 拆分复杂系统。
- 设计多 Agent 协作图。
- 处理并发状态更新和 reducer 冲突。
- 为 LangGraph 应用补充测试、日志和可观测性。

# 参考资料

## 官方文档

- LangGraph Overview：`https://docs.langchain.com/oss/python/langgraph/overview`
- LangGraph Quickstart：`https://docs.langchain.com/oss/python/langgraph/quickstart`
- Graph API：`https://docs.langchain.com/oss/python/langgraph/graph-api`
- Use Graph API：`https://docs.langchain.com/oss/python/langgraph/use-graph-api`
- Interrupts：`https://docs.langchain.com/oss/python/langgraph/interrupts`
- Persistence：`https://docs.langchain.com/oss/python/langgraph/persistence`
- Memory：`https://docs.langchain.com/oss/python/langgraph/add-memory`
- Checkpointer Integrations：`https://docs.langchain.com/oss/python/integrations/checkpointers`

# 复习清单

## 本篇检查点

- 能说明 LangGraph 适合解决什么问题。
- 能说出学习 LangGraph 的推荐顺序。
- 能区分初级、中级、高级学习目标。
- 能根据任务复杂度判断是否需要 LangGraph。
- 能找到后续每个模块的学习入口。
