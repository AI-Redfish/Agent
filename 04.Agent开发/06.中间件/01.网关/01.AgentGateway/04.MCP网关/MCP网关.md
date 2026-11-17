> 适用范围：Windows 本地 Standalone MCP 网关。使用时阅读本章；安装见 ../01.快速上手/AgentGateway 快速上手.md（该篇含最小 MCP 聚合示例），传统 HTTP 路由见 ../02.传统HTTP网关routes/传统HTTP网关routes.md。
> 依据：官方文档（来源页见文末）与本地实测。实测二进制：`E:\redfish\AgentGateway\agentgateway.exe`（commit `18f83707`）。实测日期：2026-11-16。

# MCP 网关的作用

把一个或多个 MCP 服务聚合到网关的一个入口。客户端只连网关，按工具名调用；网关负责连接上游、管理会话、执行策略。

两种上游形态：

- 本地进程：stdio 传输（网关替你 spawn 子进程）。
- 远程服务：Streamable HTTP 传输（`mcp.host` 指向 URL）。

# 两种配置写法与两种拓扑

配置写法（与 LLM 网关的双配置模式同理）：

| 写法 | 位置 | 适用 |
| :-- | :-- | :-- |
| 简化 MCP | 顶层 `mcp` 段 | 只服务 MCP，不需要自定义 HTTP 路由 |
| 路由式 | `routes[].backends[].mcp` | 按路径分流、MCP 与其他后端混用、多端口 |

两种写法产出同一种 MCP backend，策略能力相同。`mcp` 段省略 `gateways` 时挂到 default 网关；整个配置没有 `gateways` 段时，隐式 default 网关在 3000 端口服务 MCP。

拓扑选择（与写法无关）：

| 拓扑 | 配置方式 | 客户端看到 |
| :-- | :-- | :-- |
| 单端点多路复用（federation） | 多个 target 放进同一个 backend | 一个 MCP 服务，`tools/list` 聚合全部工具 |
| 分路径 | 每条 route 一个 backend | 每个路径一个 MCP 服务 |

同一 target 列表内 `name` 必须唯一，重复会校验失败：`duplicate mcp target name "<name>"`。

# 四种 target 类型

| 类型 | 写法 | 用途 |
| :-- | :-- | :-- |
| stdio | `stdio: {cmd, args}` | 本地命令行 MCP 服务 |
| Streamable HTTP | `mcp: {host: <url>}` | 远程 MCP 服务（如 mcp.atlassian.com） |
| OpenAPI | `openapi: {host, schema}` | 把 OpenAPI 描述的 REST 服务转成 MCP 工具 |
| virtual | 多 target + CEL 条件 | 聚合+federation，详见官方 virtual MCP 页 |

**stdio 示例**（本机实测通过的 Windows 写法）：

```yaml
gateways:
  mcp-lab:
    bindAddress: 127.0.0.1
    port: 4200
mcp:
  gateways: [mcp-lab]
  targets:
  - name: everything
    stdio:
      cmd: npx.cmd
      args: ["-y", "@modelcontextprotocol/server-everything"]
```

**远程 HTTP 示例**：

```yaml
mcp:
  targets:
  - name: atlassian
    mcp:
      host: https://mcp.atlassian.com/v1/mcp
```

# 会话管理

Streamable HTTP 模式下，网关自动管理 MCP 会话：

1. 客户端 `initialize` 后，网关返回 `Mcp-Session-Id` 响应头。
2. 会话状态加密（AES-256-GCM）编码进 session ID，后续请求自动路由到同一上游 target。
3. 客户端关闭会话发 `DELETE /mcp`。

会话加密密钥来源优先级：`SESSION_KEY` 环境变量 → `config.session.key` 字段 → 启动时自动生成并写回配置文件（file 存储模式）。无密钥可写时会话 ID 不加密（仅 base64，客户端可读出 target 名），并输出启动警告。故意不加密可把 `SESSION_KEY` 设为 `disabled`。

无状态模式：顶层或 backend 级 `statefulMode: stateless`，不返回 session ID，每请求独立，适合无状态客户端。

# 客户端调用要求

POST 到网关 MCP 端点（简化模式挂显式网关后为 `/mcp` 路径）必须带两种媒体类型的 Accept：

```text
Accept: application/json, text/event-stream
```

缺任一种返回 HTTP 406。

**最小调用序列**（PowerShell curl.exe 或任意 HTTP 客户端）：

```text
1. POST /mcp  initialize        → 响应头取 Mcp-Session-Id
2. POST /mcp  tools/list        → 带上 session ID，返回聚合工具列表
3. POST /mcp  tools/call        → 带上 session ID 调用工具
```

# 本机实测记录

**实验配置**：上文 stdio 示例（`mcp-lab` 网关 4200，`everything` target）。

**关键对照实验：Windows 下 stdio 的 cmd 写法**

| `cmd` 写法 | 结果 |
| :-- | :-- |
| `npx` | 网关 504 `upstream call timeout`（手动 stdio 调用同一命令正常） |
| `npx.cmd` | 全链路成功 |

结论：Windows 上 stdio 的 `cmd` 必须写可执行文件全名（`npx.cmd`、`node.exe` 等）。Rust 进程 spawn 不解析 `.cmd` shim。此结果证实《AgentGateway 快速上手》的推断，并给出失败特征。

**全链路验证**（`npx.cmd` 写法）：

| 步骤 | 请求 | 结果 |
| :-- | :-- | :-- |
| 配置校验 | `--validate-only` | Configuration is valid |
| initialize | POST `/mcp`，Accept 双媒体类型 | SSE 响应 + `Mcp-Session-Id` 头 |
| tools/list | 带 session ID | 返回 echo、get-env、get-tiny-image 等工具列表 |
| tools/call | `echo` 工具，`{"message":"hello from gateway"}` | `"Echo: hello from gateway"` |

启动前置条件：本机已有实例占用默认管理端口时，需设置 `ADMIN_ADDR`、`STATS_ADDR`、`READINESS_ADDR`（见 ../02.传统HTTP网关routes/传统HTTP网关routes.md 已知坑第 2 条）。

# 已知坑

**1. Windows stdio 写 `npx` 超时**

症状：调用返回 504，日志含 `upstream call timeout` 与 `mcp.method.name=initialize`。原因与解法见上表。

**2. Accept 头不全返回 406**

客户端 SDK 一般自动带；手写 HTTP 调用时易漏。

**3. 会话 ID 解不开返回 404**

以下情况客户端需重新 initialize：网关换了 `SESSION_KEY` 重启；负载均衡后端实例密钥不一致；session ID 属于另一个 MCP backend。多实例共享会话时统一用 `SESSION_KEY`。

**4. UI 保存依赖存储模式**

UI 增删 target 是否可保存取决于当前配置来源是否可写，不要假定所有部署模式都写本地文件。

# 官方来源与版本

- MCP 概览：https://agentgateway.dev/docs/standalone/latest/documentation/mcp/about.md
- MCP 配置模式：https://agentgateway.dev/docs/standalone/latest/documentation/mcp/configuration-modes.md
- stdio 服务：https://agentgateway.dev/docs/standalone/latest/integrations/mcp/servers/stdio.md
- Streamable HTTP 与会话：https://agentgateway.dev/docs/standalone/latest/integrations/mcp/servers/http.md
- virtual MCP（federation）：https://agentgateway.dev/docs/standalone/latest/integrations/mcp/servers/virtual/
- 抓取与实测日期：2026-11-16；二进制 commit `18f83707`

# 验证范围与未验证项

**已实测**：stdio target（npx.cmd 与 npx 对照）、initialize/tools/list/tools/call 全链路、简化模式挂显式网关、会话 ID 分配。

**未验证**：远程 Streamable HTTP target、多 target federation、stateless 模式、openapi/virtual target、MCP 认证与授权策略、DELETE 关闭会话。
