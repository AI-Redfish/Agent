# Agent

Agent 可以理解成由模型驱动的执行循环。

基本过程是：

```text
用户输入 -> 模型判断 -> 工具调用 -> 工具结果写回 -> 继续推理 -> 最终回复
```


# create_agent()

```
from langchain.agents import create_agent

agent = create_agent(
    model,                     # str | BaseChatModel：语言模型
    tools=None,                # Sequence：工具列表
    *,
    system_prompt=None,        # str | SystemMessage：系统提示
    middleware=(),             # Sequence[AgentMiddleware]：中间件列表
    response_format=None,      # ResponseFormat | type：结构化输出配置
    state_schema=None,         # type[AgentState]：自定义状态结构
    context_schema=None,       # type：运行时上下文结构
    checkpointer=None,         # Checkpointer：对话持久化
    store=None,                # BaseStore：跨会话存储
    interrupt_before=None,     # list[str]：在哪些节点前暂停
    interrupt_after=None,      # list[str]：在哪些节点后暂停
    debug=False,               # bool：是否输出详细日志
    name=None,                 # str：Agent 名称
    cache=None,                # BaseCache：缓存配置
)
```



## model

model 可以接受两种形式：字符串（由 init_chat_model() 处理）或已构建好的 BaseChatModel 实例。

```
from langchain.agents import create_agent
from langchain.chat_models import init_chat_model

# 方式 1：传字符串。
# create_agent 内部会调用 init_chat_model() 处理
agent = create_agent(
    model="deepseek:deepseek-v4-flash",  # 会自动从环境变量读取 API_KEY 和 BASE_URL
    system_prompt="你是助手"
)
# 使用模型配置字典
agent = create_agent(
    model={
        "model": "deepseek:deepseek-v4-flash",
        "api_key": "your_api_key_here",
        "base_url": "https://api.deepseek.com/v1",
        "temperature": 0.3,
        "max_tokens": 500
    },
    system_prompt="你是助手"
)

# 方式 2：传已构建好的模型实例
# 适合需要精细控制模型参数的场景
model = init_chat_model("deepseek:deepseek-v4-flash", temperature=0.3, max_tokens=500)
agent = create_agent(
    model=model,
    system_prompt="你是菜鸟教程 RUNOOB 的助手",
)
```

更推荐方式2，更灵活，可控性更强。



## tools 

详情见工具系统。



## system_prompt

定义 Agent 的行为角色和约束规则。支持字符串和 SystemMessage 对象。



system_prompt 是可选的，但不传的话模型会以"通用助手"的角色回答。对于有明确业务场景的应用，建议始终设置 system_prompt 来

约束模型的行为边界。

```
from langchain.agents import create_agent
from langchain.messages import SystemMessage

# 方式 1：字符串（简单直接）
agent = create_agent(
    model="deepseek:deepseek-v4-flash",
    system_prompt="你是菜鸟教程 RUNOOB 的学习顾问。回答要简洁，不超过 100 字。",
)

# 方式 2：SystemMessage 对象（可在多个 Agent 间复用）
system_msg = SystemMessage(
    content="你是菜鸟教程 RUNOOB 的学习顾问。回答要简洁，不超过 100 字。"
)
agent = create_agent(
    model="deepseek:deepseek-v4-flash",
    system_prompt=system_msg,
)
```



## state_schema

详情见状态与记忆.md中state部分。






# Agent 调用

## 返回值

`create_agent()` 返回的是 `CompiledStateGraph` 对象。

它本质上是 LangGraph 编译后的图，提供同步运行、异步运行、流式运行、状态读取和状态更新等能力。


**常用方法**

| 方法 | 说明 | 适用场景 |
| :-- | :-- | :-- |
| `invoke(input, config)` | 同步运行，等待完整结果 | 脚本、简单接口 |
| `ainvoke(input, config)` | 异步运行，等待完整结果 | Web 服务 |
| `stream(input, config, stream_mode)` | 同步流式运行 | 实时展示中间步骤 |
| `astream(input, config, stream_mode)` | 异步流式运行 | WebSocket、SSE |
| `get_state(config)` | 获取当前状态 | 查看、恢复对话状态 |
| `update_state(config, values)` | 更新状态 | 手动修改对话状态 |



## invoke()

`invoke()` 同步执行 Agent，直到拿到最终结果。


**使用**

```python
result = agent.invoke(
    {"messages": [{"role": "user", "content": "帮我查一下北京天气"}]}
)

print(result["messages"][-1].content)
```


**适合**

- 命令行脚本
- 简单后端接口
- 不需要实时展示过程的任务


## ainvoke()

`ainvoke()` 是异步版本的 `invoke()`。

适合 FastAPI、异步 Web 服务等环境。


**使用**

```python
result = await agent.ainvoke(
    {"messages": [{"role": "user", "content": "帮我查一下北京天气"}]}
)

print(result["messages"][-1].content)
```


## stream()

可以一边执行一边把消息、步骤或自定义事件流出来，适合调试和前端展示。


**查看完整状态变化**

```python
for step in agent.stream(
    {"messages": [{"role": "user", "content": "帮我查一下北京天气"}]},
    stream_mode="values",
):
    print(step["messages"][-1].content)
```


**查看节点更新**

```python
for update in agent.stream(
    {"messages": [{"role": "user", "content": "帮我查一下北京天气"}]},
    stream_mode="updates",
):
    print(update)
```


**查看模型消息流**

```python
for token, metadata in agent.stream(
    {"messages": [{"role": "user", "content": "介绍一下 LangChain Agent"}]},
    stream_mode="messages",
):
    print(token.content, end="")
```


## astream()

`astream()` 是异步版本的 `stream()`。

适合 WebSocket、SSE 这类需要持续推送内容的场景。


**使用**

```python
async for token, metadata in agent.astream(
    {"messages": [{"role": "user", "content": "介绍一下 LangChain Agent"}]},
    stream_mode="messages",
):
    print(token.content, end="")
```


## get_state()

`get_state()` 用来读取指定会话线程的当前状态。

通常需要和 `checkpointer`、`thread_id` 一起使用。


**使用**

```python
config = {"configurable": {"thread_id": "user-001"}}

agent.invoke(
    {"messages": [{"role": "user", "content": "我叫小明"}]},
    config=config,
)

state = agent.get_state(config)
print(state.values["messages"][-1].content)
```


## update_state()

`update_state()` 用来手动修改指定会话线程的状态。

适合人工修正、恢复对话、插入外部状态。


**使用**

```python
config = {"configurable": {"thread_id": "user-001"}}

agent.update_state(
    config,
    {
        "messages": [
            {"role": "user", "content": "我喜欢 Python"}
        ],
        "user_level": "入门",
    },
)

state = agent.get_state(config)
print(state.values)
```


**注意**

- `get_state()` 和 `update_state()` 依赖可恢复状态，通常需要配置 `checkpointer`。
- `invoke()` / `ainvoke()` 适合拿最终结果。
- `stream()` / `astream()` 适合观察执行过程或推送到前端。


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
