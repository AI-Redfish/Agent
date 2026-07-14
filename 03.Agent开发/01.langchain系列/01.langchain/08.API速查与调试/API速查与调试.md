# API 速查

## Chat Model API

Chat Model API 用于模型调用、批量调用、流式输出、工具绑定和结构化输出。



**方法说明**

| 方法 | 说明 |
| :-- | :-- |
| `invoke()` | 同步调用模型 |
| `ainvoke()` | 异步调用模型 |
| `stream()` | 同步流式调用 |
| `astream()` | 异步流式调用 |
| `batch()` | 批量调用 |
| `bind_tools()` | 绑定工具 |
| `with_structured_output()` | 结构化输出 |



## Agent API

Agent API 用于执行 Agent、流式观察过程、读取和更新状态。



**方法说明**

| 方法 | 说明 |
| :-- | :-- |
| `invoke()` | 执行完整 Agent |
| `ainvoke()` | 异步执行 |
| `stream()` | 流式执行 |
| `astream()` | 异步流式执行 |
| `get_state()` | 获取状态 |
| `update_state()` | 更新状态 |



## Messages API

Messages API 用于组织对话上下文。



**类型说明**

| 类型 | 说明 |
| :-- | :-- |
| `SystemMessage` | 系统规则 |
| `HumanMessage` | 用户消息 |
| `AIMessage` | AI 回复 |
| `ToolMessage` | 工具结果 |



## Tools API

Tools API 用于定义工具、描述参数、注入状态和存储。



**能力说明**

| 能力 | 说明 |
| :-- | :-- |
| `name` | 工具名称 |
| `description` | 工具描述 |
| `args_schema` | 参数 schema |
| `return_direct` | 是否直接返回最终结果 |
| `InjectedState` | 注入 Agent 状态 |
| `InjectedStore` | 注入持久化 Store |



## Middleware API

Middleware API 用于扩展 Agent、模型、工具的执行过程。



**装饰器说明**

| 装饰器 | 说明 |
| :-- | :-- |
| `@before_agent` | Agent 前置处理 |
| `@after_agent` | Agent 后置处理 |
| `@before_model` | 模型前置处理 |
| `@after_model` | 模型后置处理 |
| `@wrap_model_call` | 模型调用包装 |
| `@wrap_tool_call` | 工具调用包装 |
| `@dynamic_prompt` | 动态系统提示词 |



# 配置

## RunnableConfig

`RunnableConfig` 用于传递运行配置，如线程 ID、标签、元数据、回调等。



**使用**

```
config = {
    'configurable': {'thread_id': 'user-001'},
    'tags': ['demo'],
    'metadata': {'source': 'notebook'},
}
```



# 调试

## LangSmith

LangSmith 用于追踪模型调用、Agent 执行、工具调用和错误信息。



**配置**

```
LANGSMITH_TRACING=true
LANGSMITH_API_KEY=你的 API Key
LANGSMITH_PROJECT=langchain-demo
```



**可以观察**

- 模型输入输出
- 工具调用参数和结果
- Agent 执行步骤
- 错误堆栈和耗时
- Token 使用情况



## 常见错误

开发 LangChain 应用时，常见错误主要来自模型、工具、结构化输出、RAG 和配置。



**错误类型**

| 类型 | 说明 |
| :-- | :-- |
| 模型调用错误 | 超时、限流、密钥错误、模型不存在 |
| 工具调用错误 | 参数错误、业务异常、外部接口失败 |
| 结构化输出错误 | JSON 不合法、字段缺失、类型不匹配 |
| RAG 错误 | 文档加载失败、向量库为空、召回结果差 |
| 配置错误 | 缺少 API Key、thread_id 或运行参数 |



**调试建议**

- 开发期打开 LangSmith 或详细日志。
- 生产环境必须设置超时和重试。
- 外部工具调用要做错误包装。
- 结构化输出后仍要做业务校验。
- 使用 `tags` 和 `metadata` 标记业务来源。



# 参考链接

## 教程来源

- https://www.runoob.com/langchain/langchain-langsmith.html
- https://www.runoob.com/langchain/langchain-error-handling.html
- https://www.runoob.com/langchain/langchain-chat-model-api.html
- https://www.runoob.com/langchain/langchain-agent-api.html
- https://www.runoob.com/langchain/langchain-messages-api.html
- https://www.runoob.com/langchain/langchain-tools-api.html
- https://www.runoob.com/langchain/langchain-middleware-api.html
- https://www.runoob.com/langchain/langchain-config-errors.html
