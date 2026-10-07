# ACP 基本定义

ACP（Agent Client Protocol，智能体客户端协议）是 Zed 编辑器团队（Zed Industries）于 2025 年发布的开放协议，用于规范 **编辑器 / **

**客户端 / UI 组件与 AI Agent 进程之间**的发现与通信。

类比 LSP（Language Server Protocol）最好理解：

- LSP：统一了「编辑器 ↔ 语言服务器」的通信，任何编辑器接入任何语言服务器；
- ACP：统一了「编辑器 ↔ 编码 Agent」的通信，任何客户端接入任何 Agent。

在 ACP 中，Agent 是一个**由客户端启动的子进程**，双方通过 stdio 上的 JSON-RPC 消息通信。

协议官网：agentclientprotocol.com。



**与同名协议的区分**

业界还有一个 ACP：IBM 发起的 **Agent Communication Protocol**（Agent ↔ Agent 协作协议，已入 Linux Foundation）。

- 本文的 ACP：Agent Client Protocol，解决**客户端（编辑器/UI）如何发现并驱动 Agent 进程**；
- IBM 的 ACP：Agent Communication Protocol，解决 **Agent 之间互相协作**。后来并入A2A协议。

两者名字相同、定位完全不同，阅读资料时需注意区分。

# 为什么需要 ACP

在没有 ACP 之前，每个编辑器想集成一个编码 Agent，都要单独做适配：

- Zed 集成 Claude Code 是一套；
- IDE 集成 Gemini CLI 又是一套；
- 每个 Agent 的交互都很复杂：流式输出、工具调用审批、文件读写、终端执行、会话恢复……每家自定义一遍。

这就是典型的 **M×N 集成问题**：M 个客户端 × N 个 Agent，需要 M×N 份适配代码。



把 M×N 降为 **M+N**：

- Agent 只实现一次 ACP，就能接入所有支持 ACP 的客户端；
- 客户端只实现一次 ACP，就能运行所有支持 ACP 的 Agent；
- 对 Agent 交互中最难的部分（权限审批、文件访问、终端执行）给出统一方案。

# 核心架构

## 两个角色

- **Client（客户端）**：编辑器 / IDE / UI 组件，比如 Zed。
  - 负责启动 Agent 子进程；
  - 负责渲染对话、工具调用、计划等 UI；
  - 负责代管文件系统与终端访问、弹权限审批框。
- **Agent**：AI 编码智能体，比如 Gemini CLI、Claude Code、Goose。
  - 作为 Client 的**子进程**运行；
  - 接收用户请求，流式返回结果；
  - 需要敏感操作时向 Client 发起请求。

## 通信方式

- 传输层：**stdio**（标准输入 / 标准输出）；
- 消息格式：**JSON-RPC 2.0**，UTF-8 编码，**每行一条消息**（newline-delimited）；
- 通信是**双向**的：Client 可以请求 Agent，Agent 也可以反过来请求 Client。

```text
┌──────────────┐   JSON-RPC (stdio)   ┌──────────────┐
│    Client    │ ◄──────────────────► │    Agent     │
│  (Zed 等UI)  │   每行一条JSON消息    │  (子进程)     │
└──────────────┘                      └──────────────┘
```

# 消息类型

JSON-RPC 之上，ACP 的消息分三类：

1. **请求 / 响应**：Client ↔ Agent 双向 RPC。
2. **通知**：无响应的单向消息，最典型的是 Agent 的 `session/update` 流式更新。
3. **错误**：JSON-RPC 标准错误结构。属于响应的一种，有特殊结构。

Client → Agent 的主要方法：

| 方法 | 作用 |
| --- | --- |
| `initialize` | 握手：协商协议版本、交换能力 |
| `authenticate` | 认证（Agent 声明了 authMethods 时） |
| `session/new` | 创建会话 |
| `session/load` | 恢复历史会话 |
| `session/prompt` | 发送用户输入，驱动 Agent 执行 |
| `session/cancel` | 取消当前执行 |
| `session/set_mode` | 切换会话模式（如 plan / code） |

Agent → Client 的主要方法：

| 方法 | 作用 |
| --- | --- |
| `session/request_permission` | 请求用户审批（工具调用等敏感操作） |
| `fs/read_text_file` | 请客户端读文件（支持 line/limit 局部读取） |
| `fs/write_text_file` | 请客户端写文件 |
| `terminal/create` | 请客户端创建终端并执行命令 |
| `terminal/output` | 终端输出通知 |
| `terminal/wait_for_exit` / `terminal/kill` / `terminal/release` | 等待退出 / 终止 / 释放终端 |

# 协议流程

## 完整生命周期

```text
启动子进程
   │
   ▼
initialize          ← 版本与能力协商
   │
   ▼
authenticate        ← 可选，Agent 需要登录时
   │
   ▼
session/new         ← 创建会话（cwd、mcpServers）
   │
   ▼
session/prompt      ← 用户输入（可循环多轮）
   │
   ├─ session/update 通知（流式：消息块/思考/工具调用/计划）
   ├─ session/request_permission（需要审批时）
   └─ fs/*、terminal/*（需要客户端代管操作时）
   │
   ▼
返回结果，等待下一轮 session/prompt
   │
   ▼
session/load        ← 下次可恢复会话（Agent 支持 loadSession 时）
```

## 1. 握手：initialize

Client 启动 Agent 子进程后发送：

```json
{ "jsonrpc": "2.0", "id": 0, "method": "initialize",
  "params": { "protocolVersion": 1, "clientCapabilities": { "fs": true, "terminal": true } } }
```

Agent 返回自己的版本与能力：

- `protocolVersion`：协议版本（当前为 1）；
- `loadSession`：是否支持会话恢复；
- `promptCapabilities`：支持哪些输入内容（图片、音频、内嵌上下文等）；
- `mcpCapabilities`：支持哪些 MCP 连接方式（http、sse）；
- `authMethods`：需要哪些认证方式。

## 2. 创建会话：session/new

```json
{ "jsonrpc": "2.0", "id": 1, "method": "session/new",
  "params": { "cwd": "/home/user/project", "mcpServers": [] } }
```

- `cwd`：Agent 工作目录；
- `mcpServers`：客户端可以把自己的 MCP 服务器配置传给 Agent 复用。

## 3. 发送用户输入：session/prompt

```json
{ "jsonrpc": "2.0", "id": 2, "method": "session/prompt",
  "params": { "sessionId": "s1",
              "prompt": [ { "type": "text", "text": "修复这个 bug" } ] } }
```

`prompt` 是内容块数组，类型借鉴自 MCP：`text`、`image`、`audio`、`resource_link`、`resource`。

注意：`session/prompt` 的响应要等 Agent 执行完才返回，过程中的进展靠下面的通知流式推送。

## 4. Agent 流式更新：session/update 通知

Agent 执行过程中，通过 `session/update` 通知持续推送状态，客户端据此渲染 UI：

| update 类型 | 内容 |
| --- | --- |
| `agent_message_chunk` | 回复文本的流式片段 |
| `agent_thought_chunk` | 思考过程（thinking）的流式片段 |
| `tool_call` | 声明一次工具调用 |
| `tool_call_update` | 更新工具调用状态 / 输出 |
| `plan` | 任务计划（todo 列表）更新 |

工具调用的展示信息：

- `kind`：`read` / `edit` / `delete` / `move` / `search` / `execute` / `think` / `fetch` / `other`；
- `status`：`pending` → `in_progress` → `completed` / `failed`。

示例（示意）：

```json
{ "jsonrpc": "2.0", "method": "session/update",
  "params": { "sessionId": "s1",
              "update": { "sessionUpdate": "tool_call",
                          "toolCallId": "t1",
                          "title": "读取 src/main.py",
                          "kind": "read", "status": "in_progress" } } }
```

## 5. 权限审批：session/request_permission

Agent 要做敏感操作（如写文件、执行命令）时，主动请求客户端审批：

- 请求中带 `options`，如 `allow_once`、`allow_always`、`reject_once`、`reject_always`；
- 客户端把 options 渲染成 UI 按钮，用户选择后把 outcome 返回给 Agent。

这样「要不要放行」的决定权统一收在客户端 UI 手里，Agent 本身不弹窗、不持有审批逻辑。

## 6. 会话模式与恢复

- `session/set_mode`：切换 Agent 的会话模式，例如 plan（只读规划）与 code（可改代码），模式由 Agent 在 `availableModes` 中声明；
- `session/load`：客户端重启后恢复之前的会话，Agent 返回历史上下文（前提是握手时声明支持 `loadSession`）。

# 关键设计：为什么文件和终端走客户端

Agent 需要读写文件、执行终端命令时，不是自己直接做，而是**请求客户端代为执行**：

- 统一权限入口：所有敏感操作都经过客户端，天然有审批点；
- 统一 UI 展示：diff、终端输出直接渲染在编辑器里；
- 客户端可以不支持：`clientCapabilities` 中没声明 fs / terminal 时，Agent 要回退为自己直接操作。

这是 ACP 与"Agent 自己带一套 CLI 工具"方案最大的差别：**Agent 负责智能，客户端负责信任边界与 UI**。

# Tool、Skill、MCP 的提供方与执行方

ACP 本身只定义"客户端 ↔ Agent"的通信，不重新发明工具体系。一次会话中的能力来自三个层次，各自的提供方和执行方不同。

## Tool：三种来源，两个执行方

| Tool 来源 | 提供方 | 执行方 | 通信机制 |
| --- | --- | --- | --- |
| Agent 内置工具 | Agent | **Agent** | 内部执行，经 `session/update` 的 `tool_call` / `tool_call_update` 向客户端展示 |
| 客户端代管工具（文件、终端） | Client（提供执行环境与信任边界） | **Client** | `fs/read_text_file`、`fs/write_text_file`、`terminal/create` 等请求-响应 |
| MCP 工具 | MCP Server（工具本体） | **MCP Server** | Agent 充当 MCP Client，走 MCP 协议调用 |

要点：

- **Agent 内置工具**：读代码、检索、分析等，Agent 自己完成，客户端只把 `tool_call` 渲染成 UI；敏感动作前可经 `session/request_permission` 审批。
- **客户端代管工具**：文件与终端的"手和脚"由客户端提供——Agent 只发起请求，实际执行发生在客户端进程 / 客户端创建的终端里，结果回传给 Agent。
- **MCP 工具**：`mcpServers` 配置在 `session/new` 时由 **Client 下发**给 Agent（Agent 也可以用自己加载的配置）；调用阶段客户端不参与，Agent 直接与 MCP Server 通信，执行方是 **MCP Server**。

## Skill：Agent 提供，Agent 执行

ACP 协议没有定义独立的 skill 对象。Agent 侧的技能 / 自定义命令（如 Claude 的 SKILL.md、Gemini CLI 的自定义命令）通过命令广播机制接入：

- **提供方**：Agent。通过 `session/update` 的 `available_commands_update` 通知，把可用命令（名称、描述）广播给客户端；
- **客户端**：只负责把命令渲染成斜杠菜单（`/xxx`），不执行任何逻辑；
- **执行方**：Agent。用户在 UI 选中后，客户端把命令文本随 `session/prompt` 发回，仍由 Agent 解释并执行。

## MCP：Client 下发配置，Server 执行工具

| 环节 | 谁负责 |
| --- | --- |
| mcpServers 配置 | Client 在 `session/new` 时下发（也可来自 Agent 自身配置） |
| 与 MCP Server 建连 | Agent（Agent 充当 MCP Client） |
| 工具发现 `tools/list` | Agent → MCP Server |
| 工具调用 `tools/call` | Agent 发起，**MCP Server 真正执行** |
| 调用展示 / 审批 | Agent 经 `tool_call` + `request_permission` 上报，Client 渲染与审批 |

## 职责总览

| 环节 | Client | Agent | MCP Server |
| --- | --- | --- | --- |
| 提供能力 | UI、审批、fs / terminal 执行环境、下发 MCP 配置 | 决策编排、内置工具、skills | MCP 工具本体 |
| 执行 | 代管文件与终端操作 | 内置工具、技能、MCP 调用发起 | 真正执行 MCP 工具 |
| 审批 | 弹窗并记录用户决策 | 发起 `request_permission` | — |
| 展示 | 渲染消息 / 工具调用 / 计划 | 流式上报 `session/update` | — |

tool,mcp,skill具体放在哪一段决定于架构,ACP都支持,无非就是加载来源不同.

决策层都在agent侧.

# 整体链路

以"修复 bug 并跑测试"为例，一次完整交互：

```text
用户
 │ ① 输入「修复这个 bug 并跑测试」
 ▼
Client (Zed)
 │ session/prompt 下发用户输入
 ▼
Agent (子进程)
 │ ② 流式上报：agent_thought_chunk（思考）、plan（计划）
 │ ③ 内置工具：读代码、检索 —— Agent 自己执行
 │    └─ 客户端只做展示：tool_call / tool_call_update
 │ ④ 写修复：request_permission 请求审批
 │    ├─ 用户在 Client 点击「允许」
 │    └─ Client 代为执行 fs/write_text_file，结果回传 Agent
 │ ⑤ 跑测试：Client 代为执行 terminal/create
 │ ⑥ 查外部文档：Agent 以 MCP Client 身份 tools/call
 │    └─ MCP Server 真正执行，结果返回 Agent
 │ ⑦ 汇总生成回复：agent_message_chunk 流式输出
 ▼
Client 渲染最终结果 → 用户
```

链路分六步：

1. **下发输入**：用户在客户端输入，Client 经 `session/prompt` 交给 Agent；
2. **Agent 编排**：Agent 思考、出计划、决定调用哪些能力，全程经 `session/update` 流式上报；
3. **内置工具**：Agent 自己执行，客户端只展示 tool_call 的进度与结果；
4. **代管操作**：写文件、跑终端命令时，Agent 先 `request_permission` 请求审批，通过后由 **Client 执行** `fs/*`、`terminal/*`，结果回传；
5. **MCP 工具**：需要外部能力（查文档、调内部系统）时，Agent 以 MCP Client 身份调用 MCP Server，**Server 执行**并返回；
6. **返回结果**：Agent 汇总生成回复，经 `agent_message_chunk` 流式输出，本轮结束，等待下一次 `session/prompt`。

一句话总结：**决策与编排永远在 Agent；执行分散在 Agent（内置工具、MCP 调用）、Client（fs / terminal 代管）、MCP Server（工具本体）三处；审批与展示永远在 Client。**

# 配置文件方式接入

客户端通过声明的配置文件，说明可以接入哪些Agent。



**协议不管"发现"，客户端自己管**

ACP协议本身没有服务发现方法，不存在 `agents/list` 这样的 功能。

Agent 进程启动之前对客户端不可见，必须先有人告诉客户端："用什么命令、什么参数、什么环境，把这个 Agent 拉起来"。

这个职责的通行解法就是配置文件驱动的 Agent 注册表（Agent Registry）。



"通过配置文件定义接入了哪些 Agent，然后加载连接"的代表实现就是 **Zed 编辑器**：`agents.json`（或 `settings.json` 的 `agent_servers`）声明接入哪些 Agent，Zed 启动时读文件列出清单，用户选中某个 Agent 时再按配置拉起子进程并建立 ACP 连接。



## 配置文件

**Zed 的两种配置写法**



**写法一：独立的 `agents.json`**

（Linux/macOS：`~/.config/zed/agents.json`；Windows：`%APPDATA%\Zed\agents.json`），数组形式：

```json
[
  {
    "id": "claude-code",
    "name": "Claude Code",
    "command": { "command": "claude-code-acp", "args": [], "env": {} }
  },
  {
    "id": "codex",
    "name": "Codex",
    "command": { "command": "cmd", "args": ["/c", "codex-acp"], "env": {} }
  },
  {
    "id": "echo",
    "name": "Echo (Python)",
    "command": {
      "command": "python",
      "args": ["D:/develop/agents/echo_agent.py"],
      "env": { "MY_FLAG": "1" }
    }
  }
]
```

**写法二：`settings.json` 的 `agent_servers`**（编辑器主配置里的 map 形式）：

```json
{
  "agent_servers": {
    "Echo Agent (Python)": {
      "type": "custom",
      "command": "python",
      "args": ["D:/develop/agents/echo_agent.py"],
      "env": {}
    }
  }
}
```



两种写法抽象出的通用 schema 是一样的，任何 ACP 客户端的注册表都长这样：

| 字段 | 作用 | 备注 |
| --- | --- | --- |
| `id` / map 的 key | 条目唯一标识 | 客户端内部索引 |
| `name` | UI 展示名 | Agent Panel 下拉框里看到的就是它 |
| `command` | 可执行程序 | 会在 PATH 中查找；Windows 下 npm 装的 `.cmd` 需 `cmd /c` 包装 |
| `args` | 命令行参数 | 脚本路径、开关（如旧版 `--experimental-acp`）等 |
| `env` | 注入子进程的环境变量 | API Key 等凭据的标准注入点 |
| `cwd`（可选） | 子进程工作目录 | 影响 Agent 读到的相对路径与项目上下文 |

**配置里只有"怎么启动进程"；进程起来之后怎么说话，由 ACP 协议接管。** 所以配置驱动的本质 = **进程启动模板的注册表**。



## 加载与连接流程（实现原理）

```text
客户端启动（Zed / 任何 ACP 客户端）
   │
   ▼
① 读 agents.json / agent_servers      ← 纯文件解析，此时不 spawn 任何进程
   │
   ▼
② 构建内存注册表 AgentRegistry         ← [{id, name, command, args, env, cwd}, ...]
   │
   ▼
③ UI 下拉框列出所有 name              ← 用户看到"接入了哪些 Agent"
   │
   ▼（懒加载：用户选中某 Agent、发第一条消息时才发生）
④ spawn 子进程(command + args + env + cwd)
   │
   ▼
⑤ initialize 握手（声明 clientCapabilities、读 authMethods）
   │     └─ Agent 未登录时先引导认证（authenticate），再继续
   ▼
⑥ session/new → prompt                ← 进入协议层生命周期（见前文）
   │
   ▼
⑦ 该条目的进程实例被缓存复用           ← 一个条目一个进程，多会话共享
```

设计要点：

- **声明式 + 懒加载**：启动时只解析文件，不预拉全部 Agent；首次使用某条目才 spawn。配置错误（命令不存在等）要到使用时才暴露。
- **一个条目 = 一个进程实例**：同一条目的多个对话共享同一子进程，靠 session_id 区分（详见生命周期一节）。
- **env 是凭据注入点**：API key 写在条目的 env 里，不进代码；子进程默认环境是被裁剪的，env 是标准补齐通道。
- **adapter 对客户端透明**：非 ACP 原生的 Agent（Claude Code / Codex / pi）在条目里填 adapter 命令（`claude-code-acp`、`codex-acp`、`pi-acp`）即可，客户端完全无感——这正是配置模式的价值：**换 Agent 只改配置文件，不改客户端代码**。



## Python 自实现

现状一句话：**协议层有现成 SDK，"配置 → 注册表 → 懒加载"这一层没有标准化的现成 Python 框架，基于 SDK 自写薄层约百行。**

| 层 | 现成方案 | 说明 |
| --- | --- | --- |
| 协议层（拉起、握手、会话、反向请求） | ✅ `agent-client-protocol`（`import acp`） | `spawn_agent_process(client, *command, env=..., cwd=...)` 就是"按模板拉起并连接"的全部地基 |
| 注册表层（读配置、管理多 Agent 条目、懒加载缓存） | ❌ 无标准现成框架 | 参考实现是 Zed（Rust，编辑器内）；Python 侧自己组合，逻辑很薄 |
| 接入非原生 Agent | ✅ npm adapter | claude-code-acp / codex-acp / pi-acp，配置条目里直接填命令 |

**配置文件 `agents.json`**（自定义 schema，字段与 Zed 对齐）：

```json
{
  "agents": [
    { "id": "echo",   "name": "Echo (Python)", "command": ["python", "echo_agent.py"] },
    { "id": "claude", "name": "Claude Code",   "command": ["cmd", "/c", "claude-code-acp"] },
    { "id": "codex",  "name": "Codex",         "command": ["cmd", "/c", "codex-acp"],
      "env": { "OPENAI_API_KEY": "sk-..." } }
  ]
}
```

**加载器 `registry.py`**：

```python
import json
from dataclasses import dataclass, field
from typing import Any

from acp import Client, ClientSideConnection, spawn_agent_process
from acp.schema import ClientCapabilities, FileSystemCapabilities, Implementation

@dataclass
class AgentEntry:
    id: str
    name: str
    command: list[str]
    env: dict[str, str] = field(default_factory=dict)
    cwd: str = "."

class AgentRegistry:
    """agents.json -> 按需 spawn -> 缓存连接（一个条目一个进程）"""

    def __init__(self, client: Client) -> None:
        self._client = client
        self._entries: dict[str, AgentEntry] = {}
        self._ctxs: dict[str, Any] = {}                      # agent_id -> async ctx
        self._ready: dict[str, ClientSideConnection] = {}    # agent_id -> 已握手连接

    # ---- ① 启动时：纯文件解析，不拉任何进程（对齐 Zed 行为） ----
    def load(self, path: str = "agents.json") -> list[AgentEntry]:
        with open(path, encoding="utf-8") as f:
            raw = json.load(f)["agents"]
        self._entries = {
            e["id"]: AgentEntry(id=e["id"], name=e.get("name", e["id"]),
                                command=e["command"], env=e.get("env", {}),
                                cwd=e.get("cwd", "."))
            for e in raw
        }
        return list(self._entries.values())

    def list_agents(self) -> list[dict]:                     # 供 UI 渲染下拉框
        return [{"id": e.id, "name": e.name, "running": e.id in self._ready}
                for e in self._entries.values()]

    # ---- ② 首次使用：spawn + initialize（懒加载，之后复用同一进程） ----
    async def connect(self, agent_id: str) -> ClientSideConnection:
        if agent_id in self._ready:
            return self._ready[agent_id]
        entry = self._entries[agent_id]
        ctx = spawn_agent_process(self._client, *entry.command,
                                  env=entry.env, cwd=entry.cwd)
        agent, _proc = await ctx.__aenter__()
        await agent.initialize(
            protocol_version=1,
            client_capabilities=ClientCapabilities(
                fs=FileSystemCapabilities(read_text_file=True, write_text_file=True),
                terminal=False),
            client_info=Implementation(name="my-acp-client", version="0.1.0"))
        self._ctxs[agent_id] = ctx
        self._ready[agent_id] = agent
        return agent

    # ---- ③ 退出：优雅关停全部子进程（关 stdin -> 等待 -> kill） ----
    async def close(self) -> None:
        for ctx in self._ctxs.values():
            await ctx.__aexit__(None, None, None)
```

**使用**（`HeadlessClient` 见 `02.python接入` 案例二）：

```python
import asyncio
from acp import text_block

async def main() -> None:
    registry = AgentRegistry(HeadlessClient())

    for e in registry.load("agents.json"):        # ① 只解析文件
        print(f"discovered: {e.id} ({e.name})")
    print(registry.list_agents())                 # ② 渲染 UI 清单

    agent = await registry.connect("echo")        # ③ 此刻才 spawn + initialize
    session = await agent.new_session(cwd=".")
    resp = await agent.prompt(session.session_id, [text_block("你好")])
    print(f"stop_reason={resp.stop_reason}")

    await registry.close()                        # ④ 统一关停

asyncio.run(main())
```

与 Zed 行为对齐的三个实现细节：

1. **`load()` 不 spawn**——启动快、无副作用；`connect()` 才拉起并握手（懒加载），和 Zed"选中才起进程"一致；
2. **`_ready` 缓存**——一个条目一个进程，第二次 `connect("echo")` 直接复用连接，只开新 session（对齐生命周期一节：多对话共享进程）；
3. **凭据走条目 `env`**——SDK spawn 默认裁剪子进程环境（见 `02.python接入` 坑点 4），API Key 等必须经 `env=` 显式传入，条目的 env 字段就是为此设计的注入点。













