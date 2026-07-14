# Agent 基础

## Agent

Agent 是由模型驱动的执行循环。

模型会根据用户目标判断是否调用工具，把工具结果写回消息历史，再继续推理，直到得到最终答案。



**执行流程**

```
用户输入 -> 模型判断 -> 工具调用 -> 工具结果 -> 再次推理 -> 最终回答
```



**使用场景**

- 需要调用外部 API
- 需要查询数据库或知识库
- 需要分步骤执行任务
- 需要模型自己判断是否调用工具



## 第一个 Agent

使用 `create_agent()` 创建 Agent，并传入模型、工具和系统提示词。



**使用**

```
from langchain.agents import create_agent
from langchain.chat_models import init_chat_model
from langchain_core.tools import tool

@tool
def get_weather(city: str) -> str:
    """查询城市天气。"""
    return f'{city} 今天晴。'

model = init_chat_model('deepseek-chat', model_provider='deepseek')

agent = create_agent(
    model=model,
    tools=[get_weather],
    system_prompt='你是一个会使用工具的助手。'
)
```



# Agent 配置

## create_agent()

`create_agent()` 是创建 LangChain Agent 的主要入口。



**参数说明**

| 参数 | 说明 |
| :-- | :-- |
| `model` | 模型实例或模型配置 |
| `tools` | 工具列表 |
| `system_prompt` | 系统提示词 |
| `middleware` | 中间件列表 |
| `response_format` | 结构化输出格式 |
| `checkpointer` | 会话状态保存 |
| `store` | 跨会话存储 |
| `interrupt_before` | 指定节点前暂停 |
| `interrupt_after` | 指定节点后暂停 |



## AgentState

`AgentState` 是 Agent 执行过程中的状态容器。



**字段说明**

| 字段 | 说明 |
| :-- | :-- |
| `messages` | 消息历史 |
| `structured_response` | 结构化输出 |
| `jump_to` | 流程跳转控制 |



# 中间件

## Middleware

Middleware 用于在 Agent、模型、工具的生命周期中插入横切逻辑。



**钩子说明**

| 钩子 | 时机 |
| :-- | :-- |
| `before_agent` | Agent 开始前 |
| `after_agent` | Agent 完成后 |
| `before_model` | 模型调用前 |
| `after_model` | 模型调用后 |
| `wrap_model_call` | 包裹模型调用 |
| `wrap_tool_call` | 包裹工具调用 |



## wrap_model_call

`wrap_model_call` 适合做模型重试、降级、缓存、日志统计。



**使用**

```
from langchain.agents.middleware import wrap_model_call

@wrap_model_call
def log_model_call(request, handler):
    print('before model')
    response = handler(request)
    print('after model')
    return response
```



## wrap_tool_call

`wrap_tool_call` 适合做工具参数清洗、权限检查、重试、错误包装。



**使用**

```
from langchain.agents.middleware import wrap_tool_call

@wrap_tool_call
def log_tool_call(request, handler):
    print(request.tool_call)
    return handler(request)
```



**建议**

- 简单问答不要强行上 Agent。
- Agent 适合需要工具调用和多步骤执行的任务。
- 工具、状态、中间件要保持边界清晰。
- 复杂 Agent 必须配合日志或 LangSmith 观察执行链路。



# 参考链接

## 教程来源

- https://www.runoob.com/langchain/langchain-first-agent.html
- https://www.runoob.com/langchain/langchain-create_agent.html
- https://www.runoob.com/langchain/langchain-agent-workflow.html
- https://www.runoob.com/langchain/langchain-agent-state.html
- https://www.runoob.com/langchain/langchain-middleware-concepts.html
- https://www.runoob.com/langchain/langchain-before-after-model.html
- https://www.runoob.com/langchain/langchain-wrap-model-call.html
- https://www.runoob.com/langchain/langchain-wrap-tool-call.html
- https://www.runoob.com/langchain/langchain-before-after-agent.html
