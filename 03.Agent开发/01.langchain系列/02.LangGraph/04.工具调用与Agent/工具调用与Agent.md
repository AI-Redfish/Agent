# 学习目标

## 本篇目标

本篇说明如何让 LangGraph Agent 调用外部工具，并理解工具调用 Agent 的典型循环：模型决策、工具执行、结果回填、模型继续推理。

# 工具调用

## 工具是什么

工具是模型可以调用的外部能力，例如：

- 搜索。
- 查数据库。
- 调接口。
- 读写文件。
- 调用业务服务。
- 执行计算。

在 Agent 中，LLM 负责决定“是否需要调用工具”和“调用哪个工具”，工具节点负责真正执行工具。

## 工具定义示例

常见工具定义方式：

```python
from langchain_core.tools import tool


@tool
def search_order(order_id: str) -> str:
    """根据订单 ID 查询订单状态。"""
    return f"订单 {order_id} 当前状态为已支付"
```

工具说明很重要，因为模型会根据工具名称、参数和 docstring 判断如何调用。

# ToolNode

## 基本作用

`ToolNode` 是 LangGraph 中常用的预构建工具节点，用来执行模型消息中的 tool calls。

典型结构：

```text
agent 节点生成 tool_calls
  -> tools 节点执行 tool_calls
  -> agent 节点根据工具结果继续推理
```

示意代码：

```python
from langgraph.prebuilt import ToolNode


tools = [search_order]
tool_node = ToolNode(tools)

builder.add_node("tools", tool_node)
```

## tools_condition

`tools_condition` 常用于判断模型是否发起了工具调用。

示意：

```python
from langgraph.prebuilt import tools_condition

builder.add_conditional_edges("agent", tools_condition)
builder.add_edge("tools", "agent")
```

含义：

- 如果模型回复里有工具调用，则进入 `tools` 节点。
- 如果没有工具调用，则结束或进入其他节点。

# Agent 架构

## ReAct 模式

工具调用 Agent 常见模式是 ReAct：

```text
Reason：模型思考下一步
Act：模型调用工具
Observe：工具返回结果
Reason：模型继续推理
Answer：输出最终答案
```

在 LangGraph 中，这通常表现为：

```text
agent -> tools -> agent -> tools -> agent -> END
```

## create_agent 与 create_react_agent

新版 LangChain 文档中，高层 Agent API 更推荐使用 `create_agent`，它底层由 LangGraph 支撑。

学习建议：

- 想快速做 Agent：先用 `create_agent`。
- 想理解底层流程：手写 `StateGraph`。
- 想做复杂流程：用 LangGraph 自己编排节点和边。

如果看到旧资料中的 `langgraph.prebuilt.create_react_agent`，需要注意版本差异，官方新文档已经更推荐迁移到 LangChain 的 `create_agent`。

# 工具调用流程

## 基本流程

一个工具调用 Agent 的标准流程：

1. 用户输入进入 messages。
2. `agent` 节点调用模型。
3. 模型决定是否产生 tool calls。
4. 条件边判断是否进入 `tools` 节点。
5. `tools` 节点执行工具并把结果写回 messages。
6. 回到 `agent` 节点继续推理。
7. 模型输出最终答案后结束。

## 状态设计

工具调用通常至少需要：

```python
from typing import Annotated
from typing_extensions import TypedDict
from langgraph.graph.message import add_messages


class State(TypedDict):
    messages: Annotated[list, add_messages]
```

如果要做更复杂的业务 Agent，可以增加：

```python
class State(TypedDict):
    messages: Annotated[list, add_messages]
    user_id: str
    permissions: list[str]
    tool_errors: list[str]
    final_answer: str
```

# 最小工具 Agent 结构

## 结构示意

一个最小工具 Agent 通常包含三个部分：

```text
State(messages)
agent 节点：调用模型
工具节点：执行 tool_calls
条件边：判断是否继续调用工具
```

伪代码：

```python
builder.add_node("agent", call_model)
builder.add_node("tools", ToolNode(tools))
builder.add_edge(START, "agent")
builder.add_conditional_edges("agent", tools_condition)
builder.add_edge("tools", "agent")
```

这个结构是后续复杂 Agent 的基础。

# 工程建议

## 工具设计原则

工具设计要做到：

- 名称清晰。
- 参数明确。
- docstring 说明真实能力和限制。
- 返回结果尽量结构化。
- 工具内部做边界校验。
- 不让模型直接拼接危险命令。

## 常见问题

常见问题包括：

- 工具说明太模糊，模型不会调用。
- 工具参数类型不清晰，模型传参失败。
- 工具返回太长，污染上下文。
- 工具异常没有被捕获，导致图中断。
- 缺少最大循环次数，Agent 反复调用工具。

建议在 state 中记录工具错误，并为 Agent 设置最大步数。

# 复习清单

## 本篇检查点

- 能解释工具对 Agent 的意义。
- 能写出一个简单 `@tool`。
- 能说明 `ToolNode` 的作用。
- 能画出 `agent -> tools -> agent` 的工具调用循环。
- 能说出工具设计中的安全注意事项。
