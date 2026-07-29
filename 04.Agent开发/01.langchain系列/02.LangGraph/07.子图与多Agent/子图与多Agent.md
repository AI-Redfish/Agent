# 学习目标

## 本篇目标

本篇关注如何把复杂 LangGraph 应用拆成子图和多 Agent。它适合在掌握单图、控制流、持久化之后阅读。

# Subgraph

## 基本概念

Subgraph 是把一个图作为另一个图的节点使用。它适合拆分复杂系统。

例如：

```text
主图
  -> 需求分析子图
  -> 代码实现子图
  -> 测试验证子图
  -> 总结输出子图
```

每个子图内部可以有自己的节点、边、状态和 checkpoint 逻辑。

## 为什么使用子图

使用子图的原因：

- 降低主图复杂度。
- 让不同模块可以独立开发和测试。
- 复用通用流程。
- 隔离不同 Agent 的职责。
- 方便把复杂 Agent 拆成多个阶段。

# 状态传递

## 共享状态字段

父图和子图可以共享部分 state 字段。常见做法是让子图读取父图传入的输入，然后返回父图需要的输出。

示意：

```text
父图 state:
  requirement
  design_doc
  code_result

子图 state:
  requirement
  findings
  design_doc
```

子图输出 `design_doc` 后，父图继续使用。

## 状态隔离

不要让子图直接依赖父图的所有字段。更好的做法是：

- 父图只传必要输入。
- 子图内部维护自己的临时状态。
- 子图只返回明确输出。

这样子图更容易复用。

# 多 Agent 编排

## 单图多 Agent

可以把不同 Agent 设计成不同节点：

```text
planner_agent
  -> researcher_agent
  -> coder_agent
  -> reviewer_agent
  -> final_summary
```

每个 Agent 节点负责一种角色。

优点：结构清晰，状态共享简单。

缺点：所有逻辑在一个图里，复杂后会变大。

## 子图多 Agent

更复杂时可以用子图：

```text
主控图
  -> PRD 评审子图
  -> 后端开发子图
  -> 前端开发子图
  -> 测试子图
  -> Review 子图
```

每个子图可以由多个节点组成。

适合：

- 长流程。
- 多团队协作。
- 每个阶段都很复杂。
- 需要独立测试和复用。

# 典型架构

## 研发流程图

```text
receive_requirement
  -> clarify_requirement
  -> design_solution
  -> human_approval
  -> implement_backend
  -> implement_frontend
  -> run_tests
  -> review_changes
  -> final_report
```

其中：

- `clarify_requirement` 可以是 PRD Agent。
- `design_solution` 可以是架构 Agent。
- `implement_backend` 可以是后端子图。
- `implement_frontend` 可以是前端子图。
- `run_tests` 可以是测试 Agent。
- `review_changes` 可以是审查 Agent。

## 多文档评审图

```text
split_documents
  -> Send(document_1) -> review_document
  -> Send(document_2) -> review_document
  -> Send(document_3) -> review_document
  -> merge_reviews
```

这个结构适合并行处理多个 PRD 页面、接口文档或代码文件。

# 多 Agent 状态设计

## 推荐字段

多 Agent 图里可以设计统一状态：

```python
class MultiAgentState(TypedDict):
    requirement: str
    plan: str
    findings: list[str]
    implementation_notes: list[str]
    review_findings: list[str]
    final_report: str
```

其中列表字段通常需要 reducer，避免多个 Agent 并行写入时互相覆盖。

# 设计建议

## 子图边界

子图边界应该围绕“职责”划分，而不是围绕“代码文件”划分。

好的边界：

- 需求分析子图。
- 工具调用子图。
- 人工审批子图。
- 测试验证子图。
- 代码审查子图。

不好的边界：

- 随机把节点拆出去。
- 子图之间互相依赖大量内部字段。
- 父图和子图共享过多临时状态。

## 可测试性

每个子图都应该能单独测试：

```python
subgraph.invoke(test_input)
```

如果子图无法单独运行，说明边界可能没有设计好。

# 常见问题

## 子图过度拆分

如果流程很简单，不需要子图。过早拆分会增加理解成本。

## 状态字段冲突

父图和子图共享字段时，要注意字段命名和 reducer。多个子图并行写同一个字段时，需要明确合并策略。

## checkpoint 关系混乱

子图也可能涉及持久化和中断。设计时要明确：

- 使用父图 checkpointer。
- 子图单独 checkpointer。
- 哪些状态需要恢复。
- 哪些节点可能 interrupt。

# 复习清单

## 本篇检查点

- 能解释 subgraph 的作用。
- 能说明父图和子图如何传递状态。
- 能设计一个单图多 Agent 流程。
- 能判断什么时候该拆子图。
- 能说明子图过度拆分的风险。
