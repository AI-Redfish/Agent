# MCP

MCP 是 `Model Context Protocol`，即模型上下文协议。

它的目标是把外部能力用统一协议暴露给模型或 Agent，让不同应用都能按同一种方式接：

- tools
- resources
- prompts


# MCP 是什么

**一句话理解**

MCP 解决的是“外部能力怎么标准化接给模型”。


# MCP 解决什么问题

如果没有 MCP，不同系统接工具通常会出现：

- 每家 API 格式不一样
- 工具描述格式不一样
- 资源读取方式不一样
- 不同 Agent 框架难复用


MCP 的价值就是把这些接入方式统一起来。


# MCP 的核心能力

## Tools

可执行能力，比如：

- 查数据库
- 调接口
- 访问文件系统
- 执行搜索


## Resources

静态或半静态资源，比如：

- 文档
- 配置
- 数据文件
- 页面内容


## Prompts

可复用提示模板，用统一方式提供给 Agent。


# 在 LangChain 里的作用

LangChain 可以通过 `langchain-mcp-adapters` 接入 MCP Server，把 MCP 的 tools / resources / prompts 接入 Agent 或工作流。


**理解**

- MCP 负责标准化暴露能力
- LangChain 负责把这些能力接进 Agent 工作流


# 安装

## 客户端适配器

```bash
pip install langchain-mcp-adapters
```

这个包的作用是：

- 连接 MCP Server
- 发现服务暴露出来的能力
- 转换成 LangChain 可用对象


## 创建服务端

如果你要自己写 MCP Server，官方推荐使用 `FastMCP`：

```bash
pip install fastmcp
```


# 如何加载 MCP

## 1. 创建 MCP Client

LangChain 常见写法是先创建 `MultiServerMCPClient`。

```python
from langchain_mcp_adapters.client import MultiServerMCPClient

client = MultiServerMCPClient({
    "math": {
        "transport": "stdio",
        "command": "python",
        "args": ["math_server.py"]
    }
})
```

这里的“加载”本质上是两步：

1. 连接 MCP Server
2. 发现并取回该服务暴露出来的 tools / resources / prompts


## 2. 加载 tools

最常见的是加载工具。

```python
from langchain_mcp_adapters.client import MultiServerMCPClient
from langchain.agents import create_agent

client = MultiServerMCPClient({
    "math": {
        "transport": "stdio",
        "command": "python",
        "args": ["/path/to/math_server.py"],
    },
    "weather": {
        "transport": "http",
        "url": "http://localhost:8000/mcp",
    }
})

tools = await client.get_tools()
agent = create_agent("claude-sonnet-4-6", tools)
```


**说明**

- `client.get_tools()` 会从一个或多个 MCP Server 拉取工具
- 返回的工具已经是 LangChain tools，可以直接给 Agent


## 3. 加载 resources

```python
from langchain_mcp_adapters.client import MultiServerMCPClient

client = MultiServerMCPClient({...})

# 加载某个 server 的全部资源
blobs = await client.get_resources("server_name")

# 或按 URI 加载指定资源
blobs = await client.get_resources(
    "server_name",
    uris=["file:///path/to/file.txt"]
)

for blob in blobs:
    print(blob.metadata["uri"])
    print(blob.as_string())
```


**说明**

- `resources` 更适合读内容
- LangChain 会把它们转成统一的 `Blob` 对象


## 4. 加载 prompts

```python
from langchain_mcp_adapters.client import MultiServerMCPClient

client = MultiServerMCPClient({...})

messages = await client.get_prompt("server_name", "summarize")

messages = await client.get_prompt(
    "server_name",
    "code_review",
    arguments={"language": "python", "focus": "security"}
)
```


**说明**

- `prompts` 适合封装模板化提示
- 返回的是可直接用于聊天工作流的 messages


## 5. 加载时用什么 transport

官方常见两种方式：

- `stdio`
- `http`


## stdio

适合本地启动的 MCP Server。

```python
{
  "transport": "stdio",
  "command": "python",
  "args": ["server.py"]
}
```


**适合**

- 本地脚本
- 本地开发
- 单机工具集成


## http

适合远程 MCP 服务。

```python
{
  "transport": "http",
  "url": "http://localhost:8000/mcp"
}
```


**适合**

- 团队共享服务
- 远程部署工具能力
- 多应用复用同一个 MCP Server


## 6. HTTP 方式传 headers / auth

如果服务需要认证，可以在连接配置里传请求头或认证对象。

```python
client = MultiServerMCPClient(
    {
        "weather": {
            "transport": "http",
            "url": "http://localhost:8000/mcp",
            "headers": {
                "Authorization": "Bearer YOUR_TOKEN",
                "X-Custom-Header": "custom-value"
            },
        }
    }
)
```

也可以传 `auth`：

```python
client = MultiServerMCPClient(
    {
        "weather": {
            "transport": "http",
            "url": "http://localhost:8000/mcp",
            "auth": auth,
        }
    }
)
```


# 如何使用 MCP

## 最常见：把 MCP Tools 交给 Agent

```python
from langchain_mcp_adapters.client import MultiServerMCPClient
from langchain.agents import create_agent

client = MultiServerMCPClient({...})
tools = await client.get_tools()

agent = create_agent(
    "openai:gpt-5.4",
    tools
)

result = await agent.ainvoke({
    "messages": [
        {"role": "user", "content": "帮我计算 (3 + 5) * 12"}
    ]
})
```


**本质**

- MCP 暴露工具
- LangChain 取回工具
- Agent 决定什么时候调用这些工具


## 使用 Resources

`resources` 更像“统一读取数据源”，而不是让模型直接执行动作。


**适合**

- 读取文件
- 读取配置
- 读取 API 响应
- 做 RAG 前的数据接入


## 使用 Prompts

`prompts` 更像远程可复用模板。


**适合**

- 统一团队 Prompt 模板
- 让多个 Agent 共享提示词
- 在服务端集中维护提示逻辑


## Stateful Session

默认情况下，`MultiServerMCPClient` 是无状态的：

- 每次工具调用都会创建新的 `ClientSession`
- 执行完后再清理


如果服务本身需要会话状态，可以显式创建 session。

```python
from langchain_mcp_adapters.client import MultiServerMCPClient
from langchain_mcp_adapters.tools import load_mcp_tools
from langchain.agents import create_agent

client = MultiServerMCPClient({...})

async with client.session("server_name") as session:
    tools = await load_mcp_tools(session)
    agent = create_agent("google_genai:gemini-3.6-flash", tools)
```


**适合**

- 服务端需要跨多次调用保留状态
- 你想手动控制连接生命周期


## 工具错误处理

默认情况下，MCP 工具执行失败时，错误通常会以 `ToolMessage` 返回给模型，而不是直接抛异常。


**好处**

- Agent 能看到错误
- Agent 可能基于错误自动重试或改参数


如果你想改成直接抛异常，可以设置：

```python
handle_tool_errors=False
```


## 高级用法：Interceptors

官方还支持 `tool_interceptors`，类似 MCP 层的中间件。

```python
from langchain_mcp_adapters.client import MultiServerMCPClient
from langchain_mcp_adapters.interceptors import MCPToolCallRequest

async def logging_interceptor(request: MCPToolCallRequest, handler):
    print(f"Calling tool: {request.name} with args: {request.args}")
    result = await handler(request)
    print(f"Tool {request.name} returned: {result}")
    return result

client = MultiServerMCPClient(
    {
        "math": {
            "transport": "stdio",
            "command": "python",
            "args": ["/path/to/server.py"]
        }
    },
    tool_interceptors=[logging_interceptor],
)
```


**适合**

- 打日志
- 改请求参数
- 动态加 headers
- 做重试、限流、权限控制


# 如何用 LangChain 创建 MCP 服务

严格说，LangChain 主要负责“接入和消费 MCP”，而不是直接提供 MCP 服务端框架。

创建 MCP 服务时，官方推荐使用 `FastMCP`。


## 最简单的 stdio 服务

```python
from fastmcp import FastMCP

mcp = FastMCP("Math")

@mcp.tool()
def add(a: int, b: int) -> int:
    """Add two numbers"""
    return a + b

@mcp.tool()
def multiply(a: int, b: int) -> int:
    """Multiply two numbers"""
    return a * b

if __name__ == "__main__":
    mcp.run(transport="stdio")
```


这个服务暴露了两个 MCP tools：

- `add`
- `multiply`


LangChain 客户端就可以通过 `stdio` 方式把它加载进 Agent。


## 最简单的 HTTP 服务

```python
from fastmcp import FastMCP

mcp = FastMCP("Weather")

@mcp.tool()
async def get_weather(location: str) -> str:
    """Get weather for location."""
    return "It's always sunny in New York"

if __name__ == "__main__":
    mcp.run(transport="streamable-http")
```


然后 LangChain 侧通过：

```python
client = MultiServerMCPClient({
    "weather": {
        "transport": "http",
        "url": "http://localhost:8000/mcp",
    }
})
```

接入即可。


## 创建 MCP 服务的流程

1. 用 `FastMCP` 定义 server
2. 用 `@mcp.tool()` 暴露工具
3. 启动为 `stdio` 或 `http` 服务
4. 用 LangChain `MultiServerMCPClient` 连接并加载
5. 把加载出的 tools/resources/prompts 交给 Agent


## 什么时候自己创建 MCP 服务

### 适合

- 你有一批内部 API 想标准化给多个 Agent 复用
- 你希望工具能力独立部署
- 你希望 tools / resources / prompts 统一对外暴露


### 不太适合

- 项目里只有几个简单函数
- 只在当前代码库内部使用
- 没有跨项目复用需求


这种情况下，直接用 LangChain 的 `@tool` 更轻。


# MCP 和普通 Tool 的区别

| 对比项 | MCP | 普通 `@tool` |
| :-- | :-- | :-- |
| 本质 | 协议化能力暴露 | 本地函数封装 |
| 来源 | MCP Server | 当前代码库 |
| 能力发现 | 运行时发现 | 代码里显式注册 |
| 复用性 | 高 | 中 |
| 接入成本 | 更高 | 更低 |


**理解**

- `@tool` 更适合项目内快速开发
- MCP 更适合跨系统标准化集成


# MCP 和 Skills 的区别

| 对比项 | Skills | MCP |
| :-- | :-- | :-- |
| 重点 | 按需加载专业知识/流程 | 标准化暴露外部能力 |
| 主要内容 | prompt、文档、模板、脚本 | tools、resources、prompts |
| 作用方向 | 强化 Agent 的“认知” | 强化 Agent 的“接入能力” |
| 适合问题 | 该怎么做 | 能调用什么 |


**一句话区分**

- Skills 更像“经验包”
- MCP 更像“统一接口层”


# 使用建议

1. 项目内简单工具，优先 `@tool`。
2. 需要跨项目、跨平台复用时，再考虑 MCP。
3. MCP 最适合标准化外部能力接入，不适合替代所有本地工具。
4. 如果一个能力主要是长提示词和专业知识，优先考虑 Skills。
5. 如果一个能力主要是外部系统调用，优先考虑 MCP。
6. 如果服务端需要长期状态，再考虑显式 session，而不是默认无状态调用。
