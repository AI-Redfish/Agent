# Agent 基础

## Agent

Agent 可以理解成由模型驱动的执行循环。

基本过程是：

```text
用户输入 -> 模型判断 -> 工具调用 -> 工具结果写回 -> 继续推理 -> 最终回复
```


## create_agent()

`create_agent()` 是 LangChain Agent 的核心入口。


**常见参数**

| 参数 | 说明 |
| :-- | :-- |
| `model` | 模型实例或模型标识 |
| `tools` | 工具列表 |
| `system_prompt` | 系统提示词 |
| `middleware` | 中间件列表 |
| `response_format` | 结构化输出格式 |
| `checkpointer` | 会话状态持久化 |
| `store` | 跨会话存储 |


## 核心组件

Agent 页面把核心组件拆成：

- model
- tools
- system prompt
- name

高级概念再扩展到：

- structured output
- memory
- streaming
- middleware


# Agent 调用

## invoke()

**使用**

```python
result = agent.invoke(
    {"messages": [{"role": "user", "content": "帮我查一下北京天气"}]}
)
```


## stream()

可以一边执行一边把消息、步骤或自定义事件流出来，适合调试和前端展示。


# 中间件

## Middleware

Middleware 用来在 Agent、模型、工具执行过程里插入横切逻辑。


## 中间件作用

- 动态改 prompt
- 动态选模型
- 动态选工具
- 工具调用监控
- 重试、降级、日志
- 人工干预
- 上下文裁剪


## 常见挂钩

| 类型 | 说明 |
| :-- | :-- |
| 节点样式钩子 | 在指定节点前后处理 |
| 包装样式钩子 | 包住一次模型或工具调用 |


## 自定义中间件

可以用装饰器，也可以用类实现。


**使用**

```python
from langchain.agents.middleware import wrap_model_call

@wrap_model_call
def log_model_call(request, handler):
    print("before model")
    response = handler(request)
    print("after model")
    return response
```


## 内置中间件

预置中间件页覆盖的重点包括：

- 人工干预
- 模型调用限制
- 工具调用限制
- 模型 fallback
- PII 检测
- 工具重试
- 模型重试
- 上下文编辑
- 文件系统相关能力
- 子智能体


# Guardrails

## 防护栏

Guardrails 页的重点是：在 Agent 执行前后增加“安全、规则、质量”检查。


## 两类防护

| 类型 | 说明 |
| :-- | :-- |
| 确定性防护栏 | 基于规则、正则、白名单等 |
| 基于模型的防护栏 | 用模型判断是否违规或是否继续 |


## 常见场景

- PII 检测
- 高风险工具审批
- 输出合规检查
- 执行前拦截危险请求


## 组合方式

官方支持：

- Agent 执行前防护
- Agent 执行后防护
- 多种 guardrails 组合


# 结论

LangChain Agent 的核心不是“让模型回答”，而是：

- 让模型按规则工作
- 让工具在合适时机被调用
- 让中间件接管复杂控制逻辑
- 让 guardrails 把风险挡在关键节点上
