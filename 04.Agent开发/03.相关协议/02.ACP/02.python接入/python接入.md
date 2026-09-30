# 概述

python中最推荐的框架是agent-client-protocol。

由社区维护、被 ACP 官网列为推荐 Python SDK（kimi-cli 等项目在用）。



**仓库**

https://github.com/agentclientprotocol/python-sdk 



**文档**

https://agentclientprotocol.github.io/python-sdk/ ；



它把协议两侧都做成了可直接继承的基类，两个方向都能写：

| 我要做什么 | 继承谁 | 入口 |
| --- | --- | --- |
| 写一个 Agent，被 Zed 等客户端使用 | `acp.Agent` | `asyncio.run(run_agent(agent))` |
| 写一个 Client，程序化驱动任意 ACP Agent | `acp.Client` | `spawn_agent_process(client, cmd, *args)` |

# 快速上手

**安装**

```bash
pip install agent-client-protocol
# 或
uv add agent-client-protocol
```

可选附加依赖：`pip install "agent-client-protocol[http]"`（httpx + websockets，启用 HTTP/WebSocket 传输）。



**最小 Agent**

```python
# echo_agent.py
import asyncio
from typing import Any

from acp import (
    PROTOCOL_VERSION, Agent, InitializeResponse,
    NewSessionResponse, PromptResponse, run_agent,
    update_agent_message_text, text_block,
)
from acp.schema import Implementation

class EchoAgent(Agent):
    async def initialize(self, protocol_version: int, **kwargs: Any) -> InitializeResponse:
        return InitializeResponse(
            protocol_version=PROTOCOL_VERSION,
            agent_info=Implementation(name="echo-agent", version="0.1.0"),
        )

    async def new_session(self, cwd: str, **kwargs: Any) -> NewSessionResponse:
        return NewSessionResponse(session_id="s1")   # 真实项目用 uuid

    async def prompt(self, session_id: str, prompt: list[Any], **kwargs: Any) -> PromptResponse:
        text = "".join(b.text for b in prompt if b.type == "text")
        from acp import session_notification  # (示意) 实际通过 conn 发送, 见下文
        return PromptResponse(stop_reason="end_turn")

asyncio.run(run_agent(EchoAgent()))
```

三个核心方法对应协议三个请求：`initialize` / `session/new` / `session/prompt`。`Agent` 是 `typing.Protocol`，鸭子类型即可，不强制继承。



**接入 Zed 验证**

把 agent 注册到 Zed 的 `agents.json`（Linux/macOS：`~/.config/zed/agents.json`；Windows：`%APPDATA%\Zed\agents.json`）：

```json
[
  {
    "id": "echo",
    "name": "Echo",
    "command": {
      "command": "python",
      "args": ["/abs/path/to/echo_agent.py"]
    }
  }
]
```

重启 Zed → 打开 Agent Panel → 选择 Echo → 发消息，能收到回显即跑通。



**命令验证**

agent 就是「读 stdin、写 stdout」的 JSON-RPC 进程，可以手工喂一行请求：

```bash
echo '{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"protocolVersion":1,"clientCapabilities":{}}}' | python echo_agent.py
```

stdout 返回一行 JSON 响应即正常（进程会继续等输入，Ctrl+C 退出）。



# 生命周期

进程、会话与历史恢复（以 Zed 为例）。

连接（进程）与 会话是两个独立的生命周期，initialize` 跟着进程走，`session/new跟着对话走。

## 时间线

```text
Zed 启动 ──(不启动任何 agent 进程)
   │
   ├─ 在 Agent Panel 选中 Echo、创建新对话
   │     ▼
   │  spawn `python echo_agent.py` 子进程      ← 进程诞生
   │     ▼
   │  initialize()        ← 每个进程只调一次（握手）
   │     ▼
   │  new_session()       ← 每个对话调一次，得到 session_id
   │     ▼
   │  prompt()            ← 每轮消息调一次
   │
   ├─ 又开了第 2、3 个 Echo 对话
   │     → 不再 spawn 新进程、不再 initialize
   │     → 只对同一进程发 new_session()（复用进程，靠 session_id 区分）
   │
   └─ Zed 退出 / 进程崩溃
         → 下次使用时重新 spawn → 重新 initialize
```

要点：

- `initialize` 是**每进程一次**，不是每条消息、也不是每个对话一次；
- Zed 对 `agents.json` 里每个条目维持**一个**运行中的进程实例，多个对话共享它——这正是最小 Agent 里 `NewSessionResponse(session_id="s1")` 注释"真实项目用 uuid"的原因：同一进程里多个会话都返回 `s1`，`prompt(session_id, ...)` 会路由错乱。

## 重载历史会话会重启进程吗

分两种情况：

| 场景 | 是否重启进程 | 行为 |
| --- | --- | --- |
| Echo 进程还活着（切走再切回、Zed 未关） | ❌ | 不重启、不重新 initialize；Zed 从本地数据库渲染 UI 历史；thread 在当前进程里还有活的 session_id 就继续复用，后续 `prompt` 直接发过去 |
| 进程已不在（Zed 重启过、进程崩溃/被关闭） | ✅ | 重新打开该历史会话并继续交互时，重新 spawn 新进程 → 重新 `initialize`；新进程内存里没有任何旧会话状态 |

## 历史上下文去哪了：loadSession 能力

ACP 里**会话的持久化责任在客户端**：Zed 把对话记录存在自己本地（UI 层 transcript），agent 进程里的会话只是内存态。进程重启后，旧上下文能否"恢复进 agent"，取决于 `initialize` 响应中声明的能力：

| agent 声明 | Zed 打开历史会话时的行为 |
| --- | --- |
| `capabilities.loadSession = true` | 调用 `session/load`，把 Zed 保存的完整 transcript（历史 user/assistant 消息、工具调用记录）**回放给 agent**，agent 在新进程里重建上下文，后续对话无缝继续 |
| 未声明（如最小 EchoAgent） | 只能调用 `session/new` 开**全新会话**：历史消息只是 Zed 本地存的 UI 记录，agent 侧完全不知道之前聊了什么 |

SDK 侧对应 `Agent.load_session()`（可选方法）：

```python
async def load_session(self, cwd: str, session_id: str, *,
                       transcript: Any, **kwargs: Any) -> NewSessionResponse:
    """恢复历史会话：transcript 是客户端存的历史记录，灌回自己的对话状态"""
    ...
```

注：`session/load` 是稳定方法；配套的 `list_sessions` / `fork_session` / `resume_session` / `close_session` 仍是 unstable，需 `use_unstable_protocol=True`。实测（案例四）claude-code-acp / codex-acp / pi-acp 三家都声明 `loadSession=true`。

## 自行验证（三个实验）

给 EchoAgent 加 stderr 日志（**别用 stdout**，那是 JSON-RPC 通道）：

```python
import sys, datetime

def log(*a):
    print(datetime.datetime.now().strftime("%H:%M:%S"), *a, file=sys.stderr, flush=True)

class EchoAgent(Agent):
    async def initialize(self, protocol_version, **kwargs):
        log("initialize called")          # 观察进程握手时机
        ...

    async def new_session(self, cwd, **kwargs):
        log("new_session called")
        ...
```

1. 选 Echo 发消息 → 一次 `initialize` + `new_session`（任务管理器里同时能看到 python.exe 出现）；
2. 再开第二个 Echo 对话 → 只有 `new_session`，没有新的 `initialize`（进程数不变）；
3. 重启 Zed 后打开历史对话继续发消息 → 又出现一次 `initialize`（新进程），且回显只针对新消息——证明旧上下文没恢复。

一句话总结：**initialize 跟进程走（每进程一次），session 跟对话走（每对话一次）；重载历史时进程活着就复用、死了就重启；历史能否"喂回"新进程，取决于 agent 是否声明 `loadSession` 能力并实现 `session/load`**——EchoAgent 两者都没有，重载后它是个"失忆"的全新实例。



# SDK 核心模型

## 类目总览

| 类/函数 | 模块 | 作用 |
| --- | --- | --- |
| `Agent` | `acp` | Agent 侧协议基类（Protocol），实现 `initialize/new_session/prompt/...` |
| `Client` | `acp` | Client 侧协议基类（Protocol），实现 `session_update/request_permission/fs/*/terminal/*` |
| `run_agent(agent)` | `acp` | Agent 入口：在 stdio 上运行 Agent，阻塞直至断连 |
| `connect_to_agent(client, in, out)` | `acp` | 用已有流构造 ClientSideConnection（较少直接用） |
| `spawn_agent_process(client, cmd, *args)` | `acp` | **Client 入口**：拉起 Agent 子进程，返回 `ClientSideConnection`（async 上下文管理器） |
| `AgentSideConnection` | `acp.core` | Agent 眼中的"客户端代理”：`session_update()`、`request_permission()`、`read_text_file()`、`write_text_file()`、`create_terminal()`… |
| `ClientSideConnection` | `acp.client.connection` | Client 眼中的"agent 代理"：`initialize()`、`new_session()`、`prompt()`、`cancel()`… |
| `acp.schema` | — | 全部 Pydantic 模型（从上游 JSON Schema 生成） |
| `acp.helpers` | — | 构造 content block / update 的便捷函数 |
| `acp.contrib` | — | 会话累积器、工具调用跟踪、权限代理等实用件 |

## 双向调用关系

```text
                 ┌────────── Client 进程 ──────────┐
                 │  ClientSideConnection           │
                 │   .initialize() .new_session()  │
                 │   .prompt() .cancel()           │
                 └───────┬──────────────▲──────────┘
      stdin (JSON-RPC)   │              │  stdout (JSON-RPC)
                 ┌───────▼──────────────┴──────────┐
                 │  AgentSideConnection            │
                 │   .session_update()  (通知)      │
                 │   .request_permission()         │
                 │   .read/write_text_file()       │
                 │   .create_terminal() 等         │
                 └────────── Agent 进程 ───────────┘
```

- Client → Agent：请求-响应（`initialize`、`session/new`、`session/prompt`…）+ 通知（`session/cancel`）；
- Agent → Client：请求-响应（`session/request_permission`、`fs/*`、`terminal/*`）+ 通知（`session/update`）；
- SDK 里两个方向的"连接对象"互为镜像：拿到 `AgentSideConnection`（通过 `on_connect` 回调）就能反向调用客户端。

## Agent 接口全貌（`acp.Agent`）

| 方法 | 类型 | 必须实现 | 说明 |
| --- | --- | --- | --- |
| `initialize(protocol_version, client_capabilities, client_info)` | 请求 | ✅ | 返回 `InitializeResponse`（声明能力、authMethods、agentInfo） |
| `new_session(cwd, mcp_servers, ...)` | 请求 | ✅ | 返回 `NewSessionResponse(session_id, modes, config_options)` |
| `prompt(session_id, prompt)` | 请求 | ✅ | 执行一轮任务，返回 `PromptResponse(stop_reason, usage)` |
| `cancel(session_id)` | 通知 | 建议 | 用户点停止时触发 |
| `load_session(cwd, session_id, ...)` | 请求 | 可选 | 恢复历史会话（`loadSession` 能力） |
| `set_session_mode(session_id, mode_id)` | 请求 | 可选 | 切换 plan/code 等模式 |
| `authenticate(method_id)` | 请求 | 可选 | OAuth/终端登录流程 |
| `list_sessions / fork_session / resume_session / close_session` | 请求 | 可选 | **unstable**，需 `use_unstable_protocol=True` |
| `ext_method / ext_notification` | 扩展 | 可选 | 处理 `_*` 前缀的自定义方法 |
| `on_connect(conn: AgentSideConnection)` | 回调 | — | 保存 conn，供反向调用客户端 |

`stop_reason` 取值：`end_turn` / `max_tokens` / `max_turn_requests` / `refusal` / `cancelled`。

## Client 接口全貌（`acp.Client`）

| 方法 | 触发来源 | 说明 |
| --- | --- | --- |
| `session_update(session_id, update)` | `session/update` 通知 | **渲染 UI 的数据源**，收到各类流式更新 |
| `request_permission(session_id, tool_call, options)` | `session/request_permission` | 弹审批 UI，返回用户选择 |
| `read_text_file(session_id, path, line, limit)` | `fs/read_text_file` | 代 agent 读文件 |
| `write_text_file(session_id, path, content)` | `fs/write_text_file` | 代 agent 写文件 |
| `create_terminal(session_id, command, args, env, cwd, ...)` | `terminal/create` | 建终端并执行命令 |
| `terminal_output / wait_for_terminal_exit / kill_terminal / release_terminal` | `terminal/*` | 终端的生命周期管理 |
| `create_elicitation / complete_elicitation` | `elicitation/*` | 新的表单/URL 引导流程 |
| `ext_method / ext_notification` | 扩展方法 | 自定义 `_*` 方法 |

# helpers 速查（`acp.helpers`，镜像 Go/TS SDK 的 API）

```python
from acp import (
    # 内容块
    text_block, image_block, audio_block,
    resource_link_block, embedded_text_resource, embedded_blob_resource, resource_block,
    # session/update 的载体
    update_agent_message_text, update_agent_thought_text,      # 最常用
    update_user_message_text,
    update_plan, plan_entry,                                    # 计划/todo
    session_notification,
    # 工具调用展示
    start_tool_call, start_read_tool_call, start_edit_tool_call,
    update_tool_call,
    # 工具调用内容
    tool_content, tool_diff_content, tool_terminal_ref,
)
```

常用组合：

```python
update_agent_thought_text("正在分析...")            # AgentThoughtChunk
update_agent_message_text("答案是 42")              # AgentMessageChunk
update_plan([plan_entry("读代码", status="completed"),
             plan_entry("写修复", status="in_progress")])   # AgentPlanUpdate
start_tool_call("tc1", "搜索代码", kind="search", status="pending")   # ToolCallStart
update_tool_call("tc1", status="in_progress")       # ToolCallProgress
tool_diff_content("src/main.py", new_text, old_text)          # 工具调用内容里的 diff
```

枚举取值（schema Literal）：

- `ToolKind`：`read / edit / delete / move / search / execute / think / fetch / switch_mode / other`
- `ToolCallStatus`：`pending / in_progress / completed / failed`
- `PlanEntryStatus`：`pending / in_progress / completed`
- `PermissionOptionKind`：`allow_once / allow_always / reject_once / reject_always`

# 案例一：完整 Agent（思考流 + 工具调用 + 审批 + fs 代管）

以下代码实测可用（agent-client-protocol 0.12.1）。演示一轮 prompt 里的完整动作序列：思考 → 工具调用生命周期 → 权限审批 → 请客户端代写文件 → 流式回复。

```python
# demo_agent.py
import asyncio
import itertools
from typing import Any

from acp import (
    PROTOCOL_VERSION, Agent, InitializeResponse, NewSessionResponse, PromptResponse,
    run_agent, start_tool_call, start_edit_tool_call,
    update_agent_message_text, update_agent_thought_text, update_tool_call,
)
from acp.core import AgentSideConnection
from acp.schema import (
    AllowedOutcome, Implementation, PermissionOption, ToolCallUpdate,
)

_ids = itertools.count(1)

class DemoAgent(Agent):
    def __init__(self) -> None:
        self.conn: AgentSideConnection | None = None   # 反向调用客户端的句柄
        self.turns: dict[str, int] = {}

    def on_connect(self, conn: AgentSideConnection) -> None:
        self.conn = conn

    # ---- 生命周期 ----
    async def initialize(self, protocol_version: int, **kwargs: Any) -> InitializeResponse:
        return InitializeResponse(
            protocol_version=PROTOCOL_VERSION,
            agent_info=Implementation(name="demo-agent", version="0.1.0"),
        )

    async def new_session(self, cwd: str, **kwargs: Any) -> NewSessionResponse:
        sid = f"s{next(_ids)}"
        self.turns[sid] = 0
        return NewSessionResponse(session_id=sid)

    # ---- 核心业务 ----
    async def prompt(self, session_id: str, prompt: list[Any], **kwargs: Any) -> PromptResponse:
        conn = self.conn
        text = "".join(b.text for b in prompt if b.type == "text")
        self.turns[session_id] += 1

        # 1) 思考流（agent_thought_chunk）
        await conn.session_update(session_id, update_agent_thought_text(f"分析输入: {text}"))

        # 2) 工具调用：pending -> in_progress -> completed
        tc = f"tc{next(_ids)}"
        await conn.session_update(
            session_id, start_tool_call(tc, "检索相关代码", kind="search", status="pending"))
        await conn.session_update(session_id, update_tool_call(tc, status="in_progress"))
        # ...这里做真实的检索/LLM 调用...
        await conn.session_update(session_id,
            update_tool_call(tc, status="completed", raw_output={"matches": 3}))

        # 3) 敏感操作：先声明 tool_call，再请求审批
        edit_tc = f"tc{next(_ids)}"
        await conn.session_update(session_id,
            start_edit_tool_call(edit_tc, "写入笔记 note.txt", "note.txt", text))
        decision = await conn.request_permission(
            session_id,
            ToolCallUpdate(tool_call_id=edit_tc, title="写入笔记", kind="edit"),
            options=[
                PermissionOption(option_id="allow_once", name="允许一次", kind="allow_once"),
                PermissionOption(option_id="reject_once", name="拒绝",   kind="reject_once"),
            ],
        )
        if isinstance(decision.outcome, AllowedOutcome):
            # 4) 审批通过 -> 请客户端代写文件（fs/write_text_file）
            await conn.write_text_file(session_id, "note.txt", f"note: {text}\n")
            await conn.session_update(session_id, update_tool_call(edit_tc, status="completed"))
            note = "已写入"
        else:
            await conn.session_update(session_id, update_tool_call(edit_tc, status="failed"))
            note = "被拒绝"

        # 5) 消息流式输出（agent_message_chunk，逐字推送）
        reply = f"echo: {text} | {note} | 第 {self.turns[session_id]} 轮"
        for ch in reply:
            await conn.session_update(session_id, update_agent_message_text(ch))
            await asyncio.sleep(0.005)

        return PromptResponse(stop_reason="end_turn")

    async def cancel(self, session_id: str, **kwargs: Any) -> None:
        # 真实项目：取消 in-flight 的 LLM/工具任务
        pass

if __name__ == "__main__":
    asyncio.run(run_agent(DemoAgent()))
```

要点：

- **所有流式更新都通过 `conn.session_update(session_id, update)` 发通知**，`update` 是 helpers 构造的对象（内部带 `session_update` 判别字段）；
- `request_permission` 的 `tool_call` 参数用 **schema 的 `ToolCallUpdate`** 模型；`helpers.update_tool_call()` 返回的 `ToolCallProgress` 是给 `session_update` 用的，两者不要混用；
- 审批结果是 `AllowedOutcome(outcome="selected", option_id=...)` 或 `DeniedOutcome(outcome="cancelled")`，用 `isinstance` 判别；
- `prompt()` 的返回值就是 `session/prompt` 的响应；过程中已经发了多少通知，客户端 SDK 会保证先处理完再返回。

# 案例二：程序化 Client（把任意 ACP Agent 当库调用）

不打开编辑器，用自己的代码驱动 agent 子进程——适合做自动化、测试、桥接服务。

```python
# driver.py
import asyncio
import sys
from pathlib import Path
from typing import Any

from acp import Client, RequestPermissionResponse, spawn_agent_process, text_block
from acp.schema import (
    AllowedOutcome, ClientCapabilities, FileSystemCapabilities,
    Implementation, PermissionOption, ReadTextFileResponse, ToolCallProgress,
)

class HeadlessClient(Client):
    """打印所有更新；权限自动放行；fs 真实执行。"""

    async def session_update(self, session_id: str, update: Any, **kwargs: Any) -> None:
        tag = update.session_update          # 判别字段
        if tag == "agent_message_chunk":
            print(update.content.text, end="", flush=True)
        elif tag == "agent_thought_chunk":
            print(f"[think] {update.content.text}")
        elif tag in ("tool_call", "tool_call_update"):
            print(f"[tool] {update.tool_call_id} {update.status}")
        else:
            print(f"[{tag}] {update}")

    async def request_permission(self, session_id: str, tool_call: Any,
                                 options: list[PermissionOption], **kwargs: Any
                                 ) -> RequestPermissionResponse:
        allow = next(o for o in options if o.kind.startswith("allow"))
        return RequestPermissionResponse(
            outcome=AllowedOutcome(outcome="selected", option_id=allow.option_id))

    async def read_text_file(self, session_id: str, path: str,
                             line: int | None = None, limit: int | None = None,
                             **kwargs: Any) -> ReadTextFileResponse:
        lines = Path(path).read_text(encoding="utf-8").splitlines(keepends=True)
        if line is not None:
            lines = lines[line - 1: line - 1 + (limit or len(lines))]
        return ReadTextFileResponse(content="".join(lines))

    async def write_text_file(self, session_id: str, path: str,
                              content: str, **kwargs: Any) -> None:
        Path(path).write_text(content, encoding="utf-8")

    # terminal/*、elicitation、ext_* 按需实现；不支持的直接 raise 即可
    # （agent 握手时会看 clientCapabilities, 未声明的能力不会被请求）

async def main() -> None:
    async with spawn_agent_process(
        HeadlessClient(),
        sys.executable, "demo_agent.py",
        env={},                       # 注意: 默认环境是裁剪过的, 见下文坑点
    ) as (agent, process):
        # 1) 握手
        info = await agent.initialize(
            protocol_version=1,
            client_capabilities=ClientCapabilities(
                fs=FileSystemCapabilities(read_text_file=True, write_text_file=True),
                terminal=False,
            ),
            client_info=Implementation(name="my-client", version="0.1.0"),
        )
        print(f"agent={info.agent_info.name} protocol=v{info.protocol_version}")

        # 2) 开会话
        session = await agent.new_session(cwd=".")
        sid = session.session_id

        # 3) 多轮对话
        for user_input in ["你好，ACP", "第二轮对话"]:
            resp = await agent.prompt(sid, [text_block(user_input)])
            print(f"\n-> stop_reason={resp.stop_reason}")

asyncio.run(main())
```

实测输出（节选）：

```text
agent=demo-agent protocol=v1
[think] 分析输入: 你好，ACP
[tool] tc2 pending
[tool] tc2 in_progress
[tool] tc2 completed
[tool] tc3 pending
[tool] tc3 completed
echo: 你好，ACP | 已写入 | 第 1 轮
-> stop_reason=end_turn
```

要点：

- `spawn_agent_process` 是 async 上下文管理器，退出时自动做优雅关停（先关 stdin → 等待 → terminate → kill）；
- `ClientSideConnection.prompt()` 会等待本轮所有 in-flight 的 `session/update` 处理完才返回，不会丢尾部通知；
- `ClientCapabilities`（schema v1.19 起）：`fs` 是 **`FileSystemCapabilities` 对象**（`read_text_file` / `write_text_file` 两个布尔），`terminal` 是布尔；agent 侧据此决定能不能发对应反向请求；
- 换成 Gemini CLI / Claude Code / Goose 等现成 agent 时，代码几乎不变，只换 `spawn_agent_process` 的命令：
  ```python
  async with spawn_agent_process(HeadlessClient(), "gemini", "--experimental-acp") as (agent, _):
      ...
  ```

# 案例三：接入真实 LLM 的骨架

把案例一中的"假动作"换成真 LLM 调用即可，推荐结构：

```python
async def prompt(self, session_id, prompt, **kwargs):
    conn = self.conn
    text = "".join(b.text for b in prompt if b.type == "text")

    # 思考流: LLM 的 reasoning 增量 -> update_agent_thought_text
    async for delta in llm.stream(text):          # 伪代码: 任何异步生成器
        if delta.is_reasoning:
            await conn.session_update(session_id, update_agent_thought_text(delta.text))
        else:
            await conn.session_update(session_id, update_agent_message_text(delta.text))

        # 工具调用: LLM 请求调用工具时
        if delta.tool_call:
            tc = delta.tool_call.id
            await conn.session_update(session_id,
                start_tool_call(tc, delta.tool_call.name, kind="other", status="pending"))
            result = await self._run_tool(delta.tool_call)     # 内置工具自己执行
            await conn.session_update(session_id,
                update_tool_call(tc, status="completed", raw_output=result))

    return PromptResponse(stop_reason="end_turn")
```

真实参考：SDK 仓库 `examples/` 目录有流式、权限、Gemini 桥接等可运行示例；`acp.contrib` 提供：

- `SessionAccumulator`：客户端侧把流式 update 累积成可读的会话快照（消息历史、工具调用状态机合并）；
- `tool_calls` / `permissions`：工具调用跟踪与权限代理，避免手写状态合并。

# 案例四：接入现成 Agent（Codex / Claude Code / pi）

写好 Client 之后最有价值的用法：把成熟的编码 Agent 当库调用。以下内容全部实测（Windows 11 + Python 3.13 + agent-client-protocol 0.12.1）。

## 接入方式总览：当前都要走 adapter

实测本机三个 CLI 的现状（2026-01，codex 0.153.4 / claude 2.1.280 / pi 0.85.1）：

| Agent | 原生 ACP？ | 接入命令（npm adapter） | 实测 agentInfo |
| --- | --- | --- | --- |
| Claude Code | ❌ `--experimental-acp` 已不存在 | `claude-code-acp`（`@zed-industries/claude-code-acp`） | name=@zed-industries/claude-code-acp, title=Claude Code |
| Codex | ❌ 早期有 `codex acp` 实验子命令，已移除（二进制里搜不到任何 ACP 痕迹） | `codex-acp`（`@agentclientprotocol/codex-acp`，另有 `@zed-industries/codex-acp`） | title=Codex, v2.0.0 |
| pi | ❌ 无 acp 子命令（`pi acp` 会被当作消息进入 TUI 导致挂起） | `pi-acp`（社区包，deepstereo） | title=pi ACP adapter, v0.0.34 |

```bash
npm install -g @zed-industries/claude-code-acp @agentclientprotocol/codex-acp pi-acp
```

adapter 的定位：在 CLI 和 ACP 客户端之间做协议翻译（把 CLI 的流式输出、权限模式、slash 命令映射成 ACP 消息），底层还是调 `claude` / `codex` / `pi` 本体，所以**登录凭据、配置文件、skills 全部复用**，认证状态必须先在终端里准备好（`claude /login`、`codex login`、`pi auth`），否则 initialize 会返回 authMethods 让你先去登录。

## 三家的模式映射（session modes）

`new_session` 返回的 modes 是各家“权限/沙箱/思考档位”的 ACP 映射，可用 `session/set_mode` 切换：

| Agent | available modes | 语义 |
| --- | --- | --- |
| Claude Code | `default` / `acceptEdits` / `plan` / `dontAsk` / `bypassPermissions` | Claude 的权限模式 |
| Codex | `read-only` / `workspace-write` / `agent` / `agent-full-access` | Codex 的沙箱级别 |
| pi | `low` / `high` / `max` | pi 的 thinking level |

## 通用驱动脚本（实测可跑）

```python
# drive_any_agent.py —— 复用案例二的 HeadlessClient，换命令即可切换 Agent
import asyncio, sys
from acp import spawn_agent_process, text_block
# from acp.schema import ...   # 同案例二的 HeadlessClient 定义

AGENTS = {
    "claude": ["cmd", "/c", "claude-code-acp"],   # Windows: npm 的 .cmd 必须 cmd /c 包装
    "codex":  ["cmd", "/c", "codex-acp"],
    "pi":     ["cmd", "/c", "pi-acp"],
    # Linux/macOS 直接写可执行文件名: ["claude-code-acp"]
}

async def main():
    cmd = AGENTS[sys.argv[1]]
    async with spawn_agent_process(HeadlessClient(), *cmd, cwd=".") as (agent, _):
        info = await agent.initialize(protocol_version=1)
        print(f"agent={info.agent_info.title}")

        session = await agent.new_session(cwd=".")
        print(f"modes={[m.id for m in session.modes.available_modes]}")

        resp = await agent.prompt(session.session_id, [text_block("Reply with exactly one word: pong")])
        print(f"stop_reason={resp.stop_reason}")

asyncio.run(main())
```

三家的实测输出（同一客户端代码，零修改）：

```text
# python drive_any_agent.py claude
agent=Claude Code
modes=['default', 'acceptEdits', 'plan', 'dontAsk', 'bypassPermissions']
  [think] pong
  [msg] pong
stop_reason=end_turn

# python drive_any_agent.py codex
agent=Codex
modes=['read-only', 'workspace-write', 'agent', 'agent-full-access']
  [think] The user has asked me to reply with exactly one word: "pong"...   (逐词思考流)
  [msg] pong
stop_reason=end_turn

# python drive_any_agent.py pi
agent=pi ACP adapter
modes=['low', 'high', 'max']
  [msg] pong
stop_reason=end_turn
```

## 值得关注的实测细节

- **slash 命令/技能透传**：三家都会在 prompt 开始时发 `available_commands_update`，把 CLI 本体的命令广播出来——实测 pi-acp 把用户安装的 skill（如 `/skill:dws`）、codex-acp 把 `$review-agent`、`$openai-docs` 等技能全部列了出来。客户端可以直接渲染成 `/` 菜单，选中后把命令文本随 `session/prompt` 发回；
- **usage_update**：pi 和 codex 会推送 token 用量（`used`/`size`），可用来渲染上下文水位条；
- **session_info_update**：codex 用它报线程状态（active/idle），pi 报队列深度；
- **思考流**：claude 和 codex 有 `agent_thought_chunk`，pi 默认没有（除非高 thinking 档）；
- **能力声明**：三家都声明 `loadSession=true`，可以配合 `session/load` / `list_sessions` 做会话恢复（后两者是 unstable 方法，需 `use_unstable_protocol=True`）。

## 同一套配置接入 Zed（agents.json）

程序化验证通过后，把同样的命令写进 Zed 就能在编辑器里用：

```json
[
  {
    "id": "claude-code",
    "name": "Claude Code",
    "command": { "command": "claude-code-acp", "args": [] }
  },
  {
    "id": "codex",
    "name": "Codex",
    "command": { "command": "codex-acp", "args": [] }
  },
  {
    "id": "pi",
    "name": "Pi",
    "command": { "command": "pi-acp", "args": [] }
  }
]
```

Windows 上如果 Zed 找不到命令，写成 `"command": "cmd", "args": ["/c", "claude-code-acp"]`，或直接用绝对路径指向 `claude-code-acp.cmd`。

# 坑点与注意事项（实测踩过）

1. **导入名是 `acp`**：`pip install agent-client-protocol`，但 `import acp`。
2. **顶层导出不全**：`Implementation`、`ClientCapabilities`、`FileSystemCapabilities`、`PermissionOption`、`ToolCallUpdate`、`AllowedOutcome` 等在 **`acp.schema`** 里；顶层 `acp` 只导出核心类、入口函数、helpers 和请求/响应模型。找不到就 `from acp.schema import ...`。
3. **`AgentSideConnection` 顶层导入已弃用**（DeprecationWarning），用 `from acp.core import AgentSideConnection`。
4. **Agent 子进程环境被裁剪**：SDK spawn 子进程时默认只保留白名单环境变量（Windows: `PATH/APPDATA/TEMP/...`；POSIX: `HOME/PATH/...`，遵循 MCP 最佳实践）。`PYTHONPATH`、`API_KEY` 等都**不会继承**，必须显式传：
   ```python
   spawn_agent_process(client, "python", "agent.py",
                       env={"ANTHROPIC_API_KEY": "sk-...", "PYTHONPATH": "..."})
   ```
   症状：子进程秒退、客户端报 `ConnectionError: Connection closed`。
5. **Agent 进程里不要往 stdout print 调试信息**：stdout 是 JSON-RPC 通道，混入普通文本直接破坏协议。调试一律走 stderr（`print(..., file=sys.stderr)`）或日志文件。
6. **`request_permission` 的参数类型**：`tool_call` 要传 `acp.schema.ToolCallUpdate`；helpers 的 `update_tool_call()` 返回 `ToolCallProgress`（session_update 载体），传过去会被当多余字段拒绝。
7. **Windows 支持没问题**：SDK 内部对 Windows 用"stdin 线程 feeder + 自定义 stdout transport"绕开了 ProactorEventLoop 的管道限制，无需特殊处理。
8. **stdio 缓冲默认 50MB**（`DEFAULT_STDIO_BUFFER_LIMIT_BYTES`），多模态大 payload也够用；`run_agent()` 可用 `stdio_buffer_limit_bytes=` 调整。
9. **unstable 特性要显式开启**：`fork/resume/close/list_sessions` 等 `session/*` 新方法、elicitations 等，构造连接时传 `use_unstable_protocol=True`，否则路由不注册这些方法（返回 method not found）。
10. **版本敏感**：SDK 跟随上游 schema 快速演进（本笔记锁定 0.12.1 / schema v1.19.0）。升级后先跑 `pip show agent-client-protocol` 对照，重点看 `ClientCapabilities` 这类结构变化。
11. **Windows 上 spawn npm CLI 必须 `cmd /c` 包装**：npm 装的命令是 `.cmd` shim，`asyncio.create_subprocess_exec` 直接执行会报 `FileNotFoundError [WinError 2]`。写法：`spawn_agent_process(client, "cmd", "/c", "claude-code-acp")`；Linux/macOS 不需要。
12. **别再用已失效的原生入口**：`claude --experimental-acp`（unknown option）、`codex acp`（子命令已移除）、`pi acp`（不存在，会当作消息挂起）——网上旧教程里这些写法已失效，统一走 npm adapter（见案例四）。

# 调试技巧

- **看原始报文**：`spawn_agent_process(..., observers=[...])` 可挂流观察者；或临时包一层脚本把子进程 stdout tee 到文件；
- **最小复现**：先用本文 Echo Agent 验证链路，再逐步加业务，出问题时能区分是协议层还是业务层；
- **常见错误对照**：

| 现象 | 原因 |
| --- | --- |
| `ConnectionError: Connection closed` | 子进程启动即崩：环境变量被裁剪 / import 报错 / 脚本路径错 |
| `FileNotFoundError [WinError 2]` | Windows 上直接 spawn `.cmd` shim，需要 `cmd /c` 包装 |
| method not found | unstable 方法未开 `use_unstable_protocol` |
| agent 发的反向请求收不到 | 客户端 `clientCapabilities` 没声明 fs/terminal |
| 消息出现乱码 | 终端 GBK 显示问题，协议层是 UTF-8，写入文件验证即可 |
| spawn 后永久挂起无输出 | 把不存在的子命令当消息传入了 TUI（如 `pi acp`），或进程把日志写进了 stdout 破坏协议 |

# 简化记忆

```text
包名 agent-client-protocol, 导入名 acp

写 Agent:  继承 acp.Agent
           initialize / new_session / prompt 三个必须
           asyncio.run(run_agent(MyAgent()))          # stdio 入口

写 Client: 继承 acp.Client
           session_update / request_permission / fs / terminal
           spawn_agent_process(...) 拉起 agent 子进程

反向通道:  Agent.on_connect(conn) 拿到 AgentSideConnection
           conn.session_update(...)   流式上报(通知)
           conn.request_permission(...) 审批
           conn.read/write_text_file(...)  fs 代管
           conn.create_terminal(...)      终端代管

helpers:   update_agent_message_text / update_agent_thought_text
           start_tool_call -> update_tool_call
           update_plan + plan_entry

铁律:      stdout 只走协议, 调试用 stderr
           子进程环境默认裁剪, API KEY 用 env= 显式传

生命周期:  initialize 跟进程走(每进程一次), session 跟对话走(每对话一次)
           同一 agent 的多个对话共享一个进程, session_id 必须唯一(uuid)
           重载历史: 进程活着就复用, 死了就重启(重新 initialize)
           历史恢复: 声明 loadSession + 实现 load_session, 否则 agent "失忆"

接现成 Agent (都走 npm adapter, 实测 2026-01):
           Claude Code -> claude-code-acp  (@zed-industries/claude-code-acp)
           Codex       -> codex-acp        (@agentclientprotocol/codex-acp)
           pi          -> pi-acp           (社区包)
           Windows 加 cmd /c 包装; 先在终端完成各家登录
           modes 映射: claude=权限模式, codex=沙箱级别, pi=thinking 档位
```
