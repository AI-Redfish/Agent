# API 速查

## Model API

| 方法 | 说明 |
| :-- | :-- |
| `invoke()` | 同步调用 |
| `ainvoke()` | 异步调用 |
| `stream()` | 同步流式 |
| `astream()` | 异步流式 |
| `batch()` | 批量调用 |
| `bind_tools()` | 绑定工具 |
| `with_structured_output()` | 结构化输出 |


## Agent API

| 方法 | 说明 |
| :-- | :-- |
| `invoke()` | 执行完整 Agent |
| `ainvoke()` | 异步执行 |
| `stream()` | 流式执行 |
| `astream()` | 异步流式 |
| `get_state()` | 获取状态 |
| `update_state()` | 更新状态 |


## Messages API

| 类型 | 说明 |
| :-- | :-- |
| `SystemMessage` | 系统规则 |
| `HumanMessage` | 用户消息 |
| `AIMessage` | AI 回复 |
| `ToolMessage` | 工具结果 |


## Tools API

| 能力 | 说明 |
| :-- | :-- |
| `@tool` | 定义工具 |
| `args_schema` | 参数 schema |
| `return_direct` | 直接返回结果 |
| `InjectedState` | 注入状态 |
| `InjectedStore` | 注入长期存储 |


## Middleware API

> 详细说明与案例见 `05.Middleware/01.中间件Middleware.md`。

| 装饰器 | 说明 |
| :-- | :-- |
| `@before_agent` | Agent 前置处理 |
| `@after_agent` | Agent 后置处理 |
| `@before_model` | 模型前置处理 |
| `@after_model` | 模型后置处理 |
| `@wrap_model_call` | 包装模型调用 |
| `@wrap_tool_call` | 包装工具调用 |
| `@dynamic_prompt` | 动态提示词 |


# 配置

## RunnableConfig

`RunnableConfig` 常用来传线程 ID、标签和元数据。


**使用**

```python
config = {
    "configurable": {"thread_id": "user-001"},
    "tags": ["demo"],
    "metadata": {"source": "notebook"},
}
```


# 调试

## LangSmith Observability

官方可观测性页主要关注：

- 启用 tracing
- 选择性追踪
- 记录到项目
- 给 trace 增加 metadata


**配置**

```bash
export LANGSMITH_TRACING="true"
export LANGSMITH_API_KEY="your-api-key"
export LANGSMITH_PROJECT="langchain-demo"
```


## Studio

`studio` 页面用于本地调试 Agent，核心流程是：

1. 准备 Agent
2. 配环境变量
3. 准备 LangGraph 配置
4. 启动本地 Agent 服务
5. 在 Studio 里查看和调试


## Deploy

`deploy` 页面主线是把 Agent 部署到 LangSmith，并获取可调用 API。

适合：

- 先在本地调通
- 再部署
- 再用 Studio / API 验证


# 测试

## 测试分类

测试页把 Agent 测试拆成三类：

- 单元测试
- 集成测试
- 评估


## 单元测试

重点：

- mock 聊天模型
- 用 `InMemorySaver` 做检查点测试


## 集成测试

重点：

- 区分单元测试和真实集成测试
- 管理 API Key
- 断言结构，不硬断言具体文案
- 降低成本和延迟
- 必要时录制 / 回放 HTTP


## Agent Evals

评估页重点包括：

- 轨迹匹配评估器
- LLM-as-a-judge 评估器
- 异步评估
- 在 LangSmith 中跑评估


# 常见调试点

## 错误来源

| 类型 | 说明 |
| :-- | :-- |
| 模型调用错误 | 超时、限流、密钥问题 |
| 工具错误 | 参数错误、业务异常、外部接口失败 |
| 结构化输出错误 | JSON 不合法、字段缺失 |
| 检索错误 | 向量库为空、召回差 |
| 配置错误 | 缺少 API Key、thread_id、metadata |


## 调试建议

- 开发期默认开启 LangSmith
- 外部工具必须加超时和错误包装
- 结构化输出后仍要做业务校验
- 用 `tags` 和 `metadata` 标记业务来源
- 复杂 Agent 尽量补单元测试、集成测试和评估
