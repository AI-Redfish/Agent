# MCP

## MCP 是什么

MCP 是 `Model Context Protocol`，即模型上下文协议。

它的目标是把外部能力用统一协议暴露给模型或 Agent，让不同应用都能按同一种方式接：

- tools
- resources
- prompts



**一句话理解**

MCP 解决的是“外部能力怎么标准化接给模型”。



## MCP 解决什么问题

如果没有 MCP，不同系统接工具通常会出现：

- 每家 API 格式不一样
- 工具描述格式不一样
- 资源读取方式不一样
- 不同 Agent 框架难复用



MCP 的价值就是把这些接入方式统一起来。



## MCP 的核心能力

### Tools

可执行能力，比如：

- 查数据库
- 调接口
- 访问文件系统
- 执行搜索



### Resources

静态或半静态资源，比如：

- 文档
- 配置
- 数据文件
- 页面内容



### Prompts

可复用提示模板，用统一方式提供给 Agent。



## 在 LangChain 里的作用

LangChain 可以通过 `langchain-mcp-adapters` 接入 MCP Server，把 MCP 工具转换成 LangChain tools，直接给 Agent 使用。



**理解**

- MCP 负责标准化暴露能力
- LangChain 负责把这些能力接进 Agent 工作流



## 安装

```bash
pip install langchain-mcp-adapters
```



## 加载 MCP 工具

LangChain 常见写法是先创建 `MultiServerMCPClient`，再拉取工具。

```python
from langchain_mcp_adapters.client import MultiServerMCPClient
from langchain.agents import create_agent

client = MultiServerMCPClient({
    "math": {
        "transport": "stdio",
        "command": "python",
        "args": ["math_server.py"]
    }
})

tools = await client.get_tools()
agent = create_agent("claude-sonnet-4-6", tools)
```



## 什么叫“加载”

MCP 里的“加载”通常包括两层：

1. 连接 MCP Server
2. 发现并取回该服务暴露出来的 tools / resources / prompts



所以它不是把函数直接写进代码，而是运行时从 MCP Server 动态发现能力。



## transport

官方常见两种传输方式：

- `stdio`
- `http`



### stdio

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
- 命令行方式集成



### http

适合远程 MCP 服务。



**适合**

- 团队共享服务
- 远程部署工具能力
- 多应用复用同一个 MCP Server



## MCP 适合什么时候用

### 适合

- 希望把外部能力协议化、标准化
- 一个工具系统要被多个 Agent / 多个平台复用
- 想把工具、资源、提示统一暴露
- 接第三方 MCP Server



**典型场景**

- 文档服务器
- 文件系统服务器
- 数据库查询服务器
- 企业内部 API 服务器



### 不太适合

- 只有 1~2 个非常简单的本地函数
- 项目只需要几个 `@tool` 就够了
- 完全不需要协议化复用



这种场景下，直接写 LangChain `@tool` 更简单。



## MCP 和普通 Tool 的区别

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



## MCP 和 Skills 的区别

| 对比项 | Skills | MCP |
| :-- | :-- | :-- |
| 重点 | 按需加载专业知识/流程 | 标准化暴露外部能力 |
| 主要内容 | prompt、文档、模板、脚本 | tools、resources、prompts |
| 作用方向 | 强化 Agent 的“认知” | 强化 Agent 的“接入能力” |
| 适合问题 | 该怎么做 | 能调用什么 |



**一句话区分**

- Skills 更像“经验包”
- MCP 更像“统一接口层”



## 使用建议

1. 项目内简单工具，优先 `@tool`。
2. 需要跨项目、跨平台复用时，再考虑 MCP。
3. MCP 适合标准化能力接入，不适合替代所有本地工具。
4. 如果一个能力主要是长提示词和专业知识，优先考虑 Skills。
5. 如果一个能力主要是外部系统调用，优先考虑 MCP。
