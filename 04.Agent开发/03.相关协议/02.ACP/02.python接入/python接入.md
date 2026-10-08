# ACP Python 接入

Python 侧最推荐的框架：**agent-client-protocol**。社区维护、被 ACP 官网列为推荐 Python SDK（kimi-cli 等项目在用），把协议两侧都做成可直接实现的基类。

| 链接 | 地址 |
| --- | --- |
| 仓库 | https://github.com/agentclientprotocol/python-sdk |
| 文档 | https://agentclientprotocol.github.io/python-sdk/ |
| 协议官网 | https://agentclientprotocol.com/ |
| PyPI | https://pypi.org/project/agent-client-protocol/ |

# 快速上手

**安装**

```bash
pip install agent-client-protocol        # 或 uv add agent-client-protocol
# 可选: pip install "agent-client-protocol[http]"  
```

`agent-client-protocol[http]` 里的 `http` extra，作用是安装**通过 HTTP 或 WebSocket 进行远程通信所需的一整套可选依赖**。它让你能把 ACP Agent 部署在远程服务器上，让客户端通过网络连接，而不只是局限于本地标准输入输出（stdio）。



**最小 Echo Agent（完整可运行）**

```python
# echo_agent.py
import asyncio
import uuid
from typing import Any

from acp import (
    PROTOCOL_VERSION, Agent, InitializeResponse, NewSessionResponse,
    PromptResponse, run_agent, update_agent_message_text,
)
from acp.core import AgentSideConnection          # 顶层导入已弃用，从 acp.core 拿
from acp.schema import Implementation

class EchoAgent(Agent):
    def __init__(self) -> None:
        self.conn: AgentSideConnection | None = None

    def on_connect(self, conn: AgentSideConnection) -> None:
        self.conn = conn                          # 反向调用客户端的句柄

    async def initialize(self, protocol_version: int, **kwargs: Any) -> InitializeResponse:
        return InitializeResponse(
            protocol_version=PROTOCOL_VERSION,
            agent_info=Implementation(name="echo-agent", version="0.1.0"))

    async def new_session(self, cwd: str, **kwargs: Any) -> NewSessionResponse:
        return NewSessionResponse(session_id=uuid.uuid4().hex)

    async def prompt(self, session_id: str, prompt: list[Any], **kwargs: Any) -> PromptResponse:
        text = "".join(b.text for b in prompt if b.type == "text")
        await self.conn.session_update(session_id, update_agent_message_text(text))  # 流式回显
        return PromptResponse(stop_reason="end_turn")

if __name__ == "__main__":
    asyncio.run(run_agent(EchoAgent()))           # 在 stdin/stdout 上运行，阻塞直至断连
```

三个必须实现的方法对应协议三个请求：`initialize` / `session/new` / `session/prompt`。

一次最小交互流程：

```text
Client 启动 Agent 子进程
    -> initialize（协商协议版本）
    -> session/new（创建会话）
    -> session/prompt（发送消息）
    <- session/update（Agent 流式返回消息）
    <- PromptResponse(stop_reason="end_turn")
```





**三种方式验证**

**① 手工喂一行 JSON-RPC**（agent 本质是「读 stdin、写 stdout」的 JSON-RPC 进程）：

```bash
echo '{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"protocolVersion":1,"clientCapabilities":{}}}' | python echo_agent.py
```

stdout 返回一行 JSON 响应即正常（进程会继续等输入，Ctrl+C 退出）。

**② 用官方示例 client 驱动**（SDK 仓库自带，不需要 API Key）：

```powershell
python python-sdk/examples/client.py .\.venv\Scripts\python.exe echo_agent.py
```

进入交互界面，输入消息收到原样回显即跑通。Windows 下必须显式传 Python 解释器（直接传 `.py` 脚本报 `WinError 193`）。

**③ 接入 Zed**：把 agent 写进 `agents.json`（Linux/macOS：`~/.config/zed/agents.json`；Windows：`%APPDATA%\Zed\agents.json`），重启 Zed → Agent Panel → 选择 Echo → 发消息：

```json
[
  {
    "id": "echo",
    "name": "Echo",
    "command": { "command": "python", "args": ["/abs/path/to/echo_agent.py"] }
  }
]
```





# 生命周期

两条独立的生命周期：**进程生命周期由 `initialize` 标记（每进程一次），会话生命周期由 `session/new` 标记（每对话一次）**。

一个进程可承载多个会话，靠 `session_id` 区分；进程退出/崩溃时内存会话全部丢失，能否找回上下文见下面的恢复策略。

```text
Client ──spawn──▶ Agent 子进程
        initialize()      ← 握手：协商协议版本、互换能力声明（每进程一次）
        new_session()     ← 每个对话一次，得到 session_id
        prompt() …        ← 每轮消息一次；同进程新开对话只发 new_session，不再 initialize
 进程退出 / 崩溃
        ▼ 下次使用重新 spawn + initialize（内存会话全丢）→ 走会话恢复 ↓
```



**会话恢复**

优先复用 Agent 原有的 resume 能力，没有再 load session。

进程还活着时不存在"恢复"：切走再切回，thread 里 session_id 仍有效，直接继续 `prompt`（历史 UI 由客户端本地记录渲染，不打扰 agent）。真正要恢复的是**跨进程**场景（客户端重启过、进程崩溃/被关）：

| 优先级 | 条件 | 客户端动作 | 说明 |
| --- | --- | --- | --- |
| ① `session/resume`（首选） | Agent 自带会话存储/恢复能力，声明 `sessionCapabilities.resume` | 发 `session/resume(session_id, cwd, …)` | **复用 Agent 原有能力**：agent 自己找回上下文，客户端无需回放任何历史（Claude Code / Codex / pi 这类 adapter 底层 CLI 自带会话存储，典型场景） |
| ② `session/load`（兜底） | 无原生 resume，但 `initialize` 声明 `capabilities.loadSession = true` | 发 `session/load(session_id, cwd, …)` | 会话持久化责任在客户端：transcript 由客户端（如 Zed）存本地；load 时 agent 恢复自身状态，并把历史对话经 `session/update` 回放给客户端渲染 |
| ③ `session/new`（失忆） | 两者都没有（如最小 EchoAgent） | 只能开全新会话 | 历史只是客户端本地的 UI 记录，agent 侧完全不知道之前聊了什么 |

一句话总结：initialize 跟进程走（每进程一次），session 跟对话走（每对话一次）。

进程活着就复用、死了就重启；重启后恢复会话，优先复用 Agent 原有 resume 能力，没有就退到 load session，再没有就只能 new。





注：`session/load` 是稳定方法；`session/resume` 与配套的 `list_sessions` / `fork_session` / `close_session` 仍是 unstable，需 `use_unstable_protocol=True`。

# 案例

## 案例一：完整 Agent（思考流 + 工具调用 + 审批 + fs 代管）

实测可用（0.12.1）。演示一轮 prompt 里的完整动作序列：思考 → 工具调用生命周期 → 权限审批 → 请客户端代写文件 → 流式回复。

```python
# demo_agent.py —— Agent 侧：实现 acp.Agent 协议基类，被客户端当子进程拉起
import asyncio
import itertools
from typing import Any

from acp import (
    PROTOCOL_VERSION,            # 当前协议版本常量 = 1
    Agent,                       # Agent 侧 Protocol：实现 initialize/new_session/prompt/... 即为一个 ACP Agent
    InitializeResponse, NewSessionResponse, PromptResponse,
    run_agent,                   # 入口：把 agent 挂到 stdin/stdout 上跑 JSON-RPC，阻塞直至断连
    start_tool_call, start_edit_tool_call,                  # 工具调用"开始"通知的构造器
    update_agent_message_text, update_agent_thought_text,   # 回复流 / 思考流 chunk 构造器
    update_tool_call,                                       # 工具调用"进度"通知的构造器
)
from acp.core import AgentSideConnection   # agent 眼中"客户端的代理"，反向调客户端全靠它（从 acp 顶层导入已弃用）
from acp.schema import (
    AllowedOutcome,              # 审批结果之一：用户选了某个允许项（另一个是 DeniedOutcome）
    Implementation,              # name/version 元信息（握手里互报身份）
    PermissionOption,            # 审批选项（kind: allow_once / reject_once / ...）
    ToolCallUpdate,              # schema 模型：request_permission 的 tool_call 参数要用它
)

_ids = itertools.count(1)        # 全局自增 ID：session_id / tool_call_id 都从这里取，保证唯一

class DemoAgent(Agent):
    """最小可用的 ACP Agent：一轮 prompt 里演示思考流 → 工具调用 → 审批 → fs 代管 → 流式回复。"""

    def __init__(self) -> None:
        self.conn: AgentSideConnection | None = None   # 反向调用客户端的句柄（on_connect 时注入）
        self.turns: dict[str, int] = {}                # 每个会话的轮数（会话状态只在内存，进程死了就丢）

    # 连接建立时由 SDK 自动回调；保存 conn 后才能反向调用客户端
    def on_connect(self, conn: AgentSideConnection) -> None:
        self.conn = conn

    # ---- 生命周期：每个进程只调一次（握手）----
    async def initialize(self, protocol_version: int, **kwargs: Any) -> InitializeResponse:
        # 入参还有 client_capabilities / client_info（客户端是谁、能代做什么）
        # 这里回应：我支持的协议版本 + 我是谁。要支持 load session，需在此声明 agent_capabilities.load_session=True
        return InitializeResponse(
            protocol_version=PROTOCOL_VERSION,
            agent_info=Implementation(name="demo-agent", version="0.1.0"),
        )

    # ---- 生命周期：每个对话调一次；此后客户端所有请求都带着返回的 session_id ----
    async def new_session(self, cwd: str, **kwargs: Any) -> NewSessionResponse:
        sid = f"s{next(_ids)}"
        self.turns[sid] = 0                            # 初始化该会话的业务状态
        return NewSessionResponse(session_id=sid)

    # ---- 核心业务：客户端每发一条消息调一次 ----
    async def prompt(self, session_id: str, prompt: list[Any], **kwargs: Any) -> PromptResponse:
        conn = self.conn
        # prompt 是 ContentBlock 列表（text/image/audio/...），这里只取文本块拼接
        text = "".join(b.text for b in prompt if b.type == "text")
        self.turns[session_id] += 1

        # 1) 思考流（agent_thought_chunk）：客户端渲染成"思考中"区域，区别于正式回复
        await conn.session_update(session_id, update_agent_thought_text(f"分析输入: {text}"))

        # 2) 工具调用生命周期：pending -> in_progress -> completed（客户端渲染成工具卡片）
        tc = f"tc{next(_ids)}"
        await conn.session_update(
            session_id, start_tool_call(tc, "检索相关代码", kind="search", status="pending"))  # kind 决定图标
        await conn.session_update(session_id, update_tool_call(tc, status="in_progress"))
        # ...这里做真实的检索/LLM 调用...
        await conn.session_update(session_id,
            update_tool_call(tc, status="completed", raw_output={"matches": 3}))   # raw_output 供 UI 展开查看

        # 3) 敏感操作（写文件）：先声明 tool_call 给 UI 一个"载体"，再发审批请求
        edit_tc = f"tc{next(_ids)}"
        # start_edit_tool_call：kind=edit 快捷版，自动填 locations(path) + raw_input
        await conn.session_update(session_id,
            start_edit_tool_call(edit_tc, "写入笔记 note.txt", "note.txt", text))
        # request_permission 是反向请求：await 挂起，直到用户在客户端 UI 里做出选择
        decision = await conn.request_permission(
            session_id,
            ToolCallUpdate(tool_call_id=edit_tc, title="写入笔记", kind="edit"),   # 注意：这里用 schema 的 ToolCallUpdate
            options=[
                PermissionOption(option_id="allow_once", name="允许一次", kind="allow_once"),
                PermissionOption(option_id="reject_once", name="拒绝",   kind="reject_once"),
            ],
        )
        # 判别联合：AllowedOutcome(outcome="selected", option_id=...) / DeniedOutcome(outcome="cancelled")
        if isinstance(decision.outcome, AllowedOutcome):
            # 4) 审批通过 -> 请客户端代写文件（fs/write_text_file）：agent 进程不碰磁盘，落盘发生在客户端侧
            await conn.write_text_file(session_id, "note.txt", f"note: {text}\n")
            await conn.session_update(session_id, update_tool_call(edit_tc, status="completed"))
            note = "已写入"
        else:
            await conn.session_update(session_id, update_tool_call(edit_tc, status="failed"))
            note = "被拒绝"

        # 5) 正式回复：agent_message_chunk 逐字推送，客户端边收边渲染（打字机效果）
        reply = f"echo: {text} | {note} | 第 {self.turns[session_id]} 轮"
        for ch in reply:
            await conn.session_update(session_id, update_agent_message_text(ch))
            await asyncio.sleep(0.005)                 # 仅为演示流式效果

        # 返回值就是 session/prompt 的响应；客户端 SDK 保证处理完全部 in-flight 通知后才收这个响应
        return PromptResponse(stop_reason="end_turn")

    # 通知（无响应）：用户点了"停止"按钮；真实项目应在这里取消 in-flight 的 LLM/工具任务
    async def cancel(self, session_id: str, **kwargs: Any) -> None:
        pass

if __name__ == "__main__":
    # 在 stdin/stdout 上跑 JSON-RPC；进程退出 = 内存里的会话全部消失（见"生命周期"）
    asyncio.run(run_agent(DemoAgent()))
```

要点：

- **所有流式更新都通过 `conn.session_update(session_id, update)` 发通知**，`update` 用 helpers 构造；
- `request_permission` 的 `tool_call` 参数用 **schema 的 `ToolCallUpdate`**；helpers 的 `update_tool_call()` 返回的 `ToolCallProgress` 是给 `session_update` 用的，两者不要混用；
- 审批结果是 `AllowedOutcome(outcome="selected", option_id=...)` 或 `DeniedOutcome(outcome="cancelled")`，用 `isinstance` 判别；
- `prompt()` 的返回值就是 `session/prompt` 的响应；客户端 SDK 会保证先处理完所有 in-flight 通知再返回。

## 案例二：程序化 Client（把任意 ACP Agent 当库调用）

不打开编辑器，用自己的代码驱动 agent 子进程——适合自动化、测试、桥接服务。

```python
# driver.py —— Client 侧：把任意 ACP Agent 当子进程"当库调用"
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
    """无界面客户端：下面的方法都是被 agent"反向调用"的——
    session_update 收流式更新，request_permission 响应审批，fs/* 代 agent 读写文件。"""

    # agent 发来的所有 session/update 通知都进这里；update 用判别字段区分 13 种类型
    async def session_update(self, session_id: str, update: Any, **kwargs: Any) -> None:
        tag = update.session_update          # 判别字段："agent_message_chunk" / "tool_call" / ...
        if tag == "agent_message_chunk":     # 正式回复流
            print(update.content.text, end="", flush=True)
        elif tag == "agent_thought_chunk":   # 思考流
            print(f"[think] {update.content.text}")
        elif tag in ("tool_call", "tool_call_update"):   # 工具调用生命周期
            print(f"[tool] {update.tool_call_id} {update.status}")
        else:
            print(f"[{tag}] {update}")       # plan / available_commands / usage_update 等其余类型

    # agent 请求权限审批（反向请求）。headless 场景：自动选第一个 allow 项放行
    async def request_permission(self, session_id: str, tool_call: Any,
                                 options: list[PermissionOption], **kwargs: Any
                                 ) -> RequestPermissionResponse:
        allow = next(o for o in options if o.kind.startswith("allow"))
        return RequestPermissionResponse(
            outcome=AllowedOutcome(outcome="selected", option_id=allow.option_id))  # 拒绝则 DeniedOutcome("cancelled")

    # agent 反向请求读文件（fs/read_text_file）：真实实现；line 从 1 计、limit 限行数
    async def read_text_file(self, session_id: str, path: str,
                             line: int | None = None, limit: int | None = None,
                             **kwargs: Any) -> ReadTextFileResponse:
        lines = Path(path).read_text(encoding="utf-8").splitlines(keepends=True)
        if line is not None:
            lines = lines[line - 1: line - 1 + (limit or len(lines))]
        return ReadTextFileResponse(content="".join(lines))

    # agent 反向请求写文件（fs/write_text_file）：真实落盘（文件读写都在客户端进程发生）
    async def write_text_file(self, session_id: str, path: str,
                              content: str, **kwargs: Any) -> None:
        Path(path).write_text(content, encoding="utf-8")

    # terminal/*、elicitation、ext_* 按需实现；不支持的直接 raise 即可
    # （agent 握手时会看 clientCapabilities，未声明的能力不会被请求）

async def main() -> None:
    # 拉起 agent 子进程并把 stdio 接上；退出时自动优雅关停（conn.close → 关 stdin → 等待 → terminate → kill）
    async with spawn_agent_process(
        HeadlessClient(),
        sys.executable, "demo_agent.py",     # Windows 下显式传解释器，直接传 .py 脚本报 WinError 193
        env={},                              # 注意: 默认环境是裁剪过的白名单（default_environment），{} 表示不额外追加
    ) as (agent, process):
        # agent 是 ClientSideConnection：方法名与协议方法一一对应，像调本地库一样调远程子进程
        # 1) 握手：报协议版本 + 我（客户端）有哪些能力
        info = await agent.initialize(
            protocol_version=1,
            client_capabilities=ClientCapabilities(
                fs=FileSystemCapabilities(read_text_file=True, write_text_file=True),  # 声明 fs 能力，agent 才会反向调
                terminal=False,              # 不支持终端 → agent 不应发 terminal/create
            ),
            client_info=Implementation(name="my-client", version="0.1.0"),
        )
        print(f"agent={info.agent_info.name} protocol=v{info.protocol_version}")

        # 2) 开会话：拿 session_id；响应里还带 modes / config_options 可供后续切换
        session = await agent.new_session(cwd=".")
        sid = session.session_id

        # 3) 多轮对话：同一个 session_id 反复 prompt；prompt 返回时所有流式通知已处理完
        for user_input in ["你好，ACP", "第二轮对话"]:
            resp = await agent.prompt(sid, [text_block(user_input)])
            print(f"\n-> stop_reason={resp.stop_reason}")   # end_turn / max_tokens / refusal / ...

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

- `spawn_agent_process` 是 async 上下文管理器，退出时自动优雅关停（关 stdin → 等待 → terminate → kill）；
- `ClientSideConnection.prompt()` 会等本轮所有 in-flight 的 `session/update` 处理完才返回，不丢尾部通知；
- `ClientCapabilities`（schema v1.19 起）：`fs` 是 **`FileSystemCapabilities` 对象**（`read_text_file` / `write_text_file` 两个布尔），`terminal` 是布尔；agent 侧据此决定能不能发对应反向请求；
- 换成现成 agent 只需换 `spawn_agent_process` 的命令，见案例四；
- 不用 `spawn_agent_process` 时，可自己拉起子进程再用 `connect_to_agent(client, proc.stdin, proc.stdout)` 包装（官方 `examples/client.py` 即这种写法，较少直接用）。

## 案例三：接入真实 LLM（骨架）

把案例一的"假动作"换成真 LLM 调用，推荐结构：

```python
async def prompt(self, session_id, prompt, **kwargs):
    # 单轮 prompt = 一次 LLM 流式调用 + 一串 session_update 推流
    conn = self.conn
    text = "".join(b.text for b in prompt if b.type == "text")   # 提取文本块（多模态块自行扩展）

    # 两种流式输出的分派：
    #   思考流: LLM 的 reasoning 增量 -> agent_thought_chunk（UI 渲染为"思考中"区域）
    #   回复流: 正文增量            -> agent_message_chunk（打字机效果）
    async for delta in llm.stream(text):          # 伪代码: 任何异步生成器（OpenAI/Anthropic SDK 皆可）
        if delta.is_reasoning:
            await conn.session_update(session_id, update_agent_thought_text(delta.text))
        else:
            await conn.session_update(session_id, update_agent_message_text(delta.text))

        # 工具调用: LLM 请求调用工具时
        if delta.tool_call:
            tc = delta.tool_call.id
            # 先发 start 让 UI 有载体（工具卡片）；kind 按语义选 read/edit/search/execute...
            await conn.session_update(session_id,
                start_tool_call(tc, delta.tool_call.name, kind="other", status="pending"))
            result = await self._run_tool(delta.tool_call)     # 内置只读工具自己执行；写操作应先走 request_permission
            await conn.session_update(session_id,
                update_tool_call(tc, status="completed", raw_output=result))   # raw_output 给 UI 展示

    return PromptResponse(stop_reason="end_turn")   # 取值还有 max_tokens / refusal / cancelled ...
```

现成参考：SDK 仓库 `examples/` 有流式、权限、Gemini 桥接等可运行示例；`acp.contrib` 提供：

- `SessionAccumulator`：客户端侧把流式 update 累积成可读的会话快照（消息历史、工具调用状态机合并）；
- `tool_calls` / `permissions`：工具调用跟踪与权限代理，避免手写状态合并。

## 案例四：接入现成 Agent（Claude Code / Codex / pi）

写好 Client 后最有价值的用法：把成熟的编码 Agent 当库调用。以下全部实测（Windows 11 + Python 3.13 + 0.12.1，2026-01，codex 0.153.4 / claude 2.1.280 / pi 0.85.1）。

### 都要走 npm adapter

| Agent | 原生 ACP？ | 接入命令（npm adapter） | 实测 agentInfo |
| --- | --- | --- | --- |
| Claude Code | ❌ `--experimental-acp` 已不存在 | `claude-code-acp`（`@zed-industries/claude-code-acp`） | name=@zed-industries/claude-code-acp, title=Claude Code |
| Codex | ❌ 早期 `codex acp` 子命令已移除 | `codex-acp`（`@agentclientprotocol/codex-acp`） | title=Codex, v2.0.0 |
| pi | ❌ 无 acp 子命令（`pi acp` 会被当作消息挂起） | `pi-acp`（社区包，deepstereo） | title=pi ACP adapter, v0.0.34 |

```bash
npm install -g @zed-industries/claude-code-acp @agentclientprotocol/codex-acp pi-acp
```

adapter = 在 CLI 和 ACP 客户端之间做协议翻译，底层还是调 `claude` / `codex` / `pi` 本体，所以**登录凭据、配置文件、skills 全部复用**。认证必须先在终端里准备好（`claude /login`、`codex login`、`pi auth`），否则 initialize 会返回 authMethods 要求先登录。

⚠️ 网上旧教程里的 `claude --experimental-acp`、`codex acp`、`pi acp` 已全部失效，统一走 npm adapter。

### 三家的模式映射（session modes）

`new_session` 返回的 modes 是各家"权限/沙箱/思考档位"的 ACP 映射，可用 `session/set_mode` 切换：

| Agent | available modes | 语义 |
| --- | --- | --- |
| Claude Code | `default` / `acceptEdits` / `plan` / `dontAsk` / `bypassPermissions` | Claude 的权限模式 |
| Codex | `read-only` / `workspace-write` / `agent` / `agent-full-access` | Codex 的沙箱级别 |
| pi | `low` / `high` / `max` | pi 的 thinking level |

### 通用驱动脚本（同一客户端代码，零修改切换三家）

```python
# drive_any_agent.py —— 复用案例二的 HeadlessClient，换命令即可切换 Agent
import asyncio, sys
from acp import spawn_agent_process, text_block
# from acp.schema import ...   # 同案例二的 HeadlessClient 定义

AGENTS = {
    # Windows: npm 全局安装的是 .cmd 批处理，不能直接 exec，必须 cmd /c 包装
    "claude": ["cmd", "/c", "claude-code-acp"],
    "codex":  ["cmd", "/c", "codex-acp"],
    "pi":     ["cmd", "/c", "pi-acp"],
    # Linux/macOS 直接写可执行文件名: ["claude-code-acp"]
}

async def main():
    cmd = AGENTS[sys.argv[1]]
    # 同一套客户端代码接任何 agent：spawn → initialize → new_session → prompt，四步走
    async with spawn_agent_process(HeadlessClient(), *cmd, cwd=".") as (agent, _):
        info = await agent.initialize(protocol_version=1)   # 不传 capabilities = 最简能力集
        print(f"agent={info.agent_info.title}")

        # new_session 响应里的 modes：各家"权限/沙箱/思考档位"的 ACP 映射，可用 set_session_mode 切换
        session = await agent.new_session(cwd=".")
        print(f"modes={[m.id for m in session.modes.available_modes]}")

        # prompt 返回前已收完全部流式更新（思考流/消息流都打印完了）
        resp = await agent.prompt(session.session_id, [text_block("Reply with exactly one word: pong")])
        print(f"stop_reason={resp.stop_reason}")

asyncio.run(main())
```

实测输出：

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

### 值得关注的实测细节

- **slash 命令/技能透传**：三家都在 prompt 开始时发 `available_commands_update`，把 CLI 本体的命令广播出来（pi-acp 列出用户安装的 skill 如 `/skill:dws`，codex-acp 列出 `$review-agent` 等）。客户端渲染成 `/` 菜单，选中后把命令文本随 `session/prompt` 发回；
- **usage_update**：pi 和 codex 推送 token 用量（`used`/`size`），可渲染上下文水位条；
- **session_info_update**：codex 报线程状态（active/idle），pi 报队列深度；
- **思考流**：claude 和 codex 有 `agent_thought_chunk`，pi 默认没有（除非高 thinking 档）；
- **能力声明**：三家都声明 `loadSession=true`，可配合 `session/load` / `list_sessions` 做会话恢复（后两者 unstable）。

### 同一套配置接入 Zed（agents.json）

程序化验证通过后，把同样的命令写进 Zed 就能在编辑器里用（配置驱动的加载原理详见 `01.概述/ACP协议.md`「配置文件接入」）：

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



# API

> 基于 `agent-client-protocol` **0.12.1**（schema v1.19.0）整理。包结构镜像官方 Rust/TS SDK；全部模型为 Pydantic v2，字段 snake_case、自动 alias 协议的 camelCase，业务代码一般只从 `acp` 顶层导入。

## 模块地图

| 模块 | 内容 |
| --- | --- |
| `acp` | 顶层门面：常量（`PROTOCOL_VERSION`）、入口函数、helpers、schema 全量 re-export |
| `acp.core` | `run_agent` / `connect_to_agent` / `Connection` / `RequestError`；也是 `AgentSideConnection`、`ClientSideConnection` 的规范导出口（**从 `acp` 顶层直接导入这两个类已弃用**，触发 DeprecationWarning） |
| `acp.interfaces` | `Agent` / `Client` 两个 Protocol 类型定义本体 |
| `acp.agent.connection` / `acp.client.connection` | 两侧连接实现：JSON-RPC 编解码 + 方法分发（`AgentSideConnection` / `ClientSideConnection`） |
| `acp.agent.router` / `acp.client.router` | `build_agent_router` / `build_client_router`：把你的类方法注册成 JSON-RPC handler |
| `acp.schema` | 全部 Pydantic 模型（从上游 JSON Schema 生成）；带容错校验器——坏字段降级为默认值/收进 `_meta`，不会让整条消息解析失败 |
| `acp.helpers` | 构造 content block / session update 的便捷函数 |
| `acp.contrib` | 实验性实用件：会话累积器、工具调用跟踪、权限代理（API 可能变） |
| `acp.stdio` / `acp.transports` | stdio 流（Windows 专用线程喂入）、子进程 spawn、裁剪环境 `default_environment()` |
| `acp.http` / `acp.ws` | 实验性远程传输：Streamable HTTP / WebSocket（需 `[http]` extra） |
| `acp.meta` | `PROTOCOL_VERSION=1`、`AGENT_METHODS` / `CLIENT_METHODS`（SDK 方法名 → JSON-RPC 方法名） |
| `acp.exceptions` | `RequestError`：JSON-RPC 2.0 错误，工厂方法 `parse_error / invalid_request / method_not_found / invalid_params / internal_error / auth_required / resource_not_found` |

## 协议方法全景（`acp.meta`）

| Client → Agent（`AGENT_METHODS`） | Agent → Client（`CLIENT_METHODS`） |
| --- | --- |
| `initialize`、`authenticate` | `session/request_permission` |
| `session/new`、`session/prompt`、`session/cancel`（通知） | `session/update`（通知） |
| `session/load`、`session/set_mode`、`session/set_config_option` | `fs/read_text_file`、`fs/write_text_file` |
| `session/list`*、`session/delete`*、`session/fork`*、`session/resume`*、`session/close`* | `terminal/create`、`terminal/output`、`terminal/wait_for_exit`、`terminal/kill`、`terminal/release` |
| `logout`*、`providers/list`*、`providers/set`*、`providers/disable`* | `elicitation/create`、`elicitation/complete`（通知） |
| `nes/*`*、`document/*`*（代码补全内嵌场景，编辑器向） | `mcp/connect`、`mcp/message`、`mcp/disconnect` |
| 双向扩展：`ext_method` / `ext_notification`（`_<method>` 前缀） | |

`*` = unstable：两侧都要 `use_unstable_protocol=True` 才会注册/放行，否则按 method_not_found 处理。

## 入口函数

### Agent 侧：`run_agent()`

```python
async def run_agent(
    agent,                        # 你的 Agent 实现
    input_stream=None,            # 默认 sys.stdin  → asyncio.StreamReader
    output_stream=None,           # 默认 sys.stdout → asyncio.StreamWriter
    *,
    use_unstable_protocol=False,  # 打开 session/list、session/resume 等 unstable 方法
    stdio_buffer_limit_bytes=DEFAULT_STDIO_BUFFER_LIMIT_BYTES,   # 50MB（asyncio 默认 64KB 撑不住多模态大块）
)
```

- 默认 `stdio_streams()` 把 `sys.stdin/sys.stdout` 包成 asyncio 流（Windows 下用后台线程喂 stdin + 自定义 stdout transport），构造 `AgentSideConnection` 后 `listen()` 阻塞直至对端断连，`finally` 里 `close()`；
- 自管连接时等价写法：`conn = AgentSideConnection(agent, w, r)` → `await conn.listen()`。

### Client 侧：`spawn_agent_process()`

```python
async with spawn_agent_process(
    client,                 # 你的 Client 实现
    command, *args,         # 子进程命令
    *, env=None,            # None = default_environment() 裁剪白名单环境；要完整继承需显式 env=dict(os.environ)
    cwd=None,
    transport_kwargs=None,  # 透传 spawn_stdio_transport：stderr=PIPE、limit、shutdown_timeout=2.0
) as (conn, process):
    ...
```

- async 上下文管理器，`yield (ClientSideConnection, Process)`；
- 退出链（镜像 MCP Python SDK 的防御式关停）：`conn.close()` → stdin `write_eof()` → 等 `shutdown_timeout` 秒 → `terminate()` → 仍超时 `kill()`；
- `default_environment()` 只继承白名单变量（Windows：`PATH/APPDATA/USERPROFILE/...`；POSIX：`HOME/PATH/SHELL/TERM/USER/...`），并跳过 `()` 开头的 shell 函数定义——agent 需要 PATH 之外的工具时必须显式传 `env`；
- 对称 API：`spawn_client_process()`（自己当 Agent 侧去驱动 Client 子进程）、`spawn_stdio_connection()`（直接拿低层 `Connection`）、`stdio_streams(limit)`。

### 已有流 / 远程：`connect_to_agent()`

```python
conn = connect_to_agent(client, input_stream, output_stream=None, *,
                        use_unstable_protocol=False)
```

两种形态：**stdio**（`input_stream=StreamWriter, output_stream=StreamReader`）或 **Transport**（`input_stream=create_http_stream(url)` / `await create_websocket_stream(url)`，此时 `output_stream` 必须为 `None`）。官方 `examples/client.py` 是"自己 `create_subprocess_exec` + `connect_to_agent`"的手动写法，较少直接用。

## Agent 接口（`acp.Agent`，Protocol）

所有方法由路由器以**关键字参数**调用，并接受任意 `**kwargs`（透传 `_meta`）。

| 方法 | 签名 | 类型 | 必须 | 返回 | 说明 |
| --- | --- | --- | --- | --- | --- |
| `initialize` | `(protocol_version, client_capabilities=None, client_info=None)` | 请求 | ✅ | `InitializeResponse(protocol_version, agent_capabilities, auth_methods, agent_info)` | 握手。声明 `agentCapabilities.loadSession`、`promptCapabilities{image,audio,embeddedContext}`、`mcpCapabilities{http,sse,acp}`、`sessionCapabilities{list,delete,fork,resume,close,…}`；需要登录时返回 `authMethods`，客户端随后调 `authenticate` |
| `new_session` | `(cwd, additional_directories=None, mcp_servers=None)` | 请求 | ✅ | `NewSessionResponse(session_id, modes, config_options)` | 建会话。`mcp_servers` 接受 `McpServerStdio / HttpMcpServer / SseMcpServer / AcpMcpServer` |
| `prompt` | `(session_id, prompt: list[ContentBlock])` | 请求 | ✅ | `PromptResponse(stop_reason, usage)` | 执行一轮。过程中用 `conn.session_update()` 推流；返回即本轮结束 |
| `cancel` | `(session_id)` | 通知 | 建议 | — | 用户点停止；应中止 in-flight 的 LLM/工具任务 |
| `load_session` | `(cwd, session_id, mcp_servers=None, additional_directories=None)` | 请求 | 可选 | `LoadSessionResponse(modes, config_options)` | 仅当声明 `loadSession=true` 才会被调。恢复自身状态，并把历史经 `session/update` 回放给客户端 |
| `set_session_mode` | `(session_id, mode_id)` | 请求 | 可选 | `SetSessionModeResponse` | 切换会话模式（权限档/沙箱档/思考档），对应 `modes.available_modes` |
| `set_config_option` | `(config_id, session_id, value: str\|bool)` | 请求 | 可选 | `SetSessionConfigOptionResponse` | 切换配置项（模型/思考等级等）；`value=bool` 自动走 boolean 请求体，否则 select |
| `authenticate` | `(method_id)` | 请求 | 可选 | `AuthenticateResponse` | OAuth/终端/env-var 三类登录方式之一 |
| `list_sessions`* | `(cwd=None, cursor=None)` | 请求 | 可选 | `ListSessionsResponse(sessions: list[SessionInfo], next_cursor)` | agent 自管会话的分页列表 |
| `fork_session`* | `(session_id, cwd, additional_directories=None, mcp_servers=None)` | 请求 | 可选 | `ForkSessionResponse(session_id, modes, config_options)` | 从现有会话分叉出新会话（原会话不动） |
| `resume_session`* | `(session_id, cwd, additional_directories=None, mcp_servers=None)` | 请求 | 可选 | `ResumeSessionResponse(modes, config_options)` | **会话恢复首选**：恢复 agent 自己持久化的会话 |
| `close_session`* | `(session_id)` | 请求 | 可选 | `CloseSessionResponse` | 关闭并（视实现）清理会话 |
| `ext_method` / `ext_notification` | `(method, params)` | 扩展 | 可选 | `dict` / — | 处理 `_<method>` 自定义方法/通知 |
| `on_connect` | `(conn: AgentSideConnection)` | 回调 | — | — | 连接建立即回调；保存 conn 供反向调用客户端 |

`stop_reason`（`Literal`）：`end_turn` / `max_tokens` / `max_turn_requests` / `refusal` / `cancelled`。

路由细节：SDK 优先找 snake_case 方法名（推荐，关键字传参）；旧式驼峰方法名（`sessionUpdate`）或"单 Request 参数"签名仍被识别，但发 DeprecationWarning。

## Client 接口（`acp.Client`，Protocol）

由 Agent 经 `AgentSideConnection` 反向调用。未实现的方法收到请求返回 method_not_found；握手时按 `clientCapabilities` 如实声明，未声明的能力 agent 不应发起。

| 方法 | 触发来源 | 签名要点 | 返回 |
| --- | --- | --- | --- |
| `session_update` | `session/update` 通知 | `(session_id, update)`；update 是 13 种 union，按 `update.session_update` 判别 | — |
| `request_permission` | `session/request_permission` | `(session_id, tool_call: ToolCallUpdate, options: list[PermissionOption])` | `RequestPermissionResponse`；outcome 为 `AllowedOutcome(outcome="selected", option_id)` 或 `DeniedOutcome(outcome="cancelled")` |
| `read_text_file` | `fs/read_text_file` | `(session_id, path, line=None, limit=None)`；line 从 1 计 | `ReadTextFileResponse(content)` |
| `write_text_file` | `fs/write_text_file` | `(session_id, path, content)` | — |
| `create_terminal` | `terminal/create` | `(session_id, command, args=None, env=None, cwd=None, output_byte_limit=None)` | `CreateTerminalResponse(terminal_id)` |
| `terminal_output` | `terminal/output` | `(session_id, terminal_id)` | `TerminalOutputResponse(output, truncated, exit_status?)` |
| `wait_for_terminal_exit` | `terminal/wait_for_exit` | `(session_id, terminal_id)` | `WaitForTerminalExitResponse(exit_code?, signal?)` |
| `kill_terminal` / `release_terminal` | `terminal/kill`、`terminal/release` | `(session_id, terminal_id)` | — |
| `create_elicitation` | `elicitation/create` | `(message, mode)`；mode 为 `ElicitationMode` 四选一（form 带 JSON Schema / url 带跳转链接 × session/request 两种作用域） | `Accept / Decline / Cancel` 三种响应 |
| `complete_elicitation` | `elicitation/complete` 通知 | `(elicitation_id)` | — |
| `ext_method` / `ext_notification` | `_<method>` | 同 Agent 侧 | `dict` |
| `on_connect` | — | `(conn: ClientSideConnection)` | — |

**`session/update` 的 13 种 update**：

| `session_update` 判别值 | 模型 | 用途 |
| --- | --- | --- |
| `user_message_chunk` / `agent_message_chunk` / `agent_thought_chunk` | `ContentChunk(content: ContentBlock)` | 用户消息回显 / 回复流 / 思考流 |
| `tool_call` / `tool_call_update` | `ToolCallStart` / `ToolCallProgress` | 工具调用生命周期 |
| `plan` / `plan_update` / `plan_removed` | `AgentPlanUpdate` / `AgentPlanContentUpdate` / `AgentPlanRemovedUpdate` | 计划（todo）列表及增量 |
| `available_commands_update` | `AvailableCommandsUpdate` | 广播 slash 命令/技能（`AvailableCommand(name, description, input?)`） |
| `current_mode_update` / `config_option_update` | `CurrentModeUpdate` / `ConfigOptionUpdate` | 模式/配置切换回执 |
| `session_info_update` | `SessionInfoUpdate` | 会话元信息（标题、状态、队列深度） |
| `usage_update` | `UsageUpdate` | token 用量水位（`used` / `size`） |

## 两个连接对象（互为镜像的反向代理）

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
- 类方法名与 JSON-RPC 方法一一对应（见 `acp.meta`）；handler 未实现即 `method_not_found`。

### `AgentSideConnection`（agent → client，`acp.agent.connection`）

构造：`AgentSideConnection(agent, input_stream, output_stream, listening=..., use_unstable_protocol=...)`，构造完即回调 `agent.on_connect(conn)`。

| 方法 | 对应 JSON-RPC | 说明 |
| --- | --- | --- |
| `session_update(session_id, update)` | `session/update`（通知） | 推流唯一入口，update 用 helpers 构造 |
| `request_permission(session_id, tool_call, options)` | `session/request_permission` | await 用户选择才返回；`tool_call` 用 **schema 的 `ToolCallUpdate`**（helpers 的 `update_tool_call()` 返回 `ToolCallProgress`，是给 `session_update` 用的，两者别混） |
| `read_text_file` / `write_text_file` | `fs/*` | 请客户端代读写文件 |
| `create_terminal` / `terminal_output` / `wait_for_terminal_exit` / `kill_terminal` / `release_terminal` | `terminal/*` | 命令执行交给客户端终端 |
| `create_elicitation` / `complete_elicitation` | `elicitation/*` | 表单 / URL 引导 |
| `ext_method` / `ext_notification` | `_<method>` | 扩展方法 |
| `listen()` / `close()` / `__aenter__` / `__aexit__` | — | `run_agent` 内部使用；自管连接时手动调 |

### `ClientSideConnection`（client → agent，`acp.client.connection`）

| 方法 | 对应 JSON-RPC | 说明 |
| --- | --- | --- |
| `initialize(protocol_version, client_capabilities=None, client_info=None)` | `initialize` | `client_capabilities.fs = FileSystemCapabilities(read_text_file, write_text_file)`、`terminal: bool`、`auth.terminal`、`elicitation`、`session`、`plan` |
| `new_session(cwd, additional_directories=None, mcp_servers=None)` | `session/new` | 返回 `session_id`、`modes`、`config_options` |
| `load_session(cwd, session_id, …)` | `session/load` | agent 声明 `loadSession=true` 时用 |
| `prompt(session_id, prompt)` | `session/prompt` | **返回前会等本会话所有 in-flight update 处理完**（异常路径同样 wait 后再抛），不丢尾部通知 |
| `cancel(session_id)` | `session/cancel`（通知） | 不等响应 |
| `set_session_mode(session_id, mode_id)` | `session/set_mode` | 切模式 |
| `set_config_option(config_id, session_id, value)` | `session/set_config_option` | value 传 bool 或 str，自动选 boolean/select 请求体 |
| `authenticate(method_id)` | `authenticate` | 登录 |
| `list_sessions` / `fork_session` / `resume_session` / `close_session`* | `session/*` | unstable |
| `ext_method` / `ext_notification` | `_<method>` | 扩展 |
| `close()` / `__aenter__` / `__aexit__` | — | `spawn_agent_process` 退出时自动 close |

`spawn_agent_process` ≈ `spawn_stdio_transport(...)` + `ClientSideConnection(client, writer, reader)`；内部用 `_SessionUpdateTracker` 实现"prompt 尾部通知不丢"。

## schema 关键模型速查

字段一律 snake_case（Pydantic alias 到协议 camelCase）；上游未识别字段收进 `field_meta`（`_meta`），个别坏值按默认值容错（`salvage_on_error`）。

**能力协商**

- `InitializeResponse`：`protocol_version`、`agent_capabilities`、`auth_methods`（`AuthMethodAgent(id,name,description)` / `EnvVarAuthMethod` / `TerminalAuthMethod` 三类）、`agent_info: Implementation(name, title, version)`；
- `AgentCapabilities`：`load_session`、`prompt_capabilities(image/audio/embedded_context)`、`mcp_capabilities(http/sse/acp)`、`session_capabilities(list/delete/additional_directories/fork/resume/close)`、`auth.logout`、`providers`、`nes`、`position_encoding`；
- `ClientCapabilities`：`fs(read_text_file/write_text_file)`、`terminal`、`session`、`plan`、`auth(terminal)`、`elicitation`、`position_encodings`。

**会话、模式与配置**

- `NewSessionResponse`：`session_id`；`modes: SessionModeState(current_mode_id, available_modes: list[SessionMode(id, name, description?)])`；`config_options: list[SessionConfigOptionSelect | SessionConfigOptionBoolean]`（`category ∈ mode / model / model_config / thought_level`；select 选项为 `SessionConfigSelectOption(value, name, description?)`）；
- `LoadSessionResponse` / `ResumeSessionResponse`：只含 `modes` + `config_options`（session_id 沿用请求里的）；
- `ForkSessionResponse`：多返回一个新 `session_id`。

**prompt 内容块（`ContentBlock` 五种）**：`TextContentBlock(text)`、`ImageContentBlock(data, mime_type, uri?)`、`AudioContentBlock(data, mime_type)`、`ResourceContentBlock(resource_link: name/uri/mime_type?/size?/…)`、`EmbeddedResourceContentBlock(resource: TextResourceContents | BlobResourceContents)`。

**`PromptResponse.usage: Usage`**：`total_tokens`、`input_tokens`、`output_tokens`、`thought_tokens?`、`cached_read_tokens?`、`cached_write_tokens?`。

**工具调用**：`ToolCallUpdate` 为基类，`ToolCallStart` / `ToolCallProgress` 是"基类 + `session_update` 判别值"的子类。字段：`tool_call_id`、`title`、`kind`、`status`、`content`（三选一：`ContentToolCallContent(type="content")` 文本块 / `FileEditToolCallContent(type="diff", path, new_text, old_text?)` / `TerminalToolCallContent(type="terminal", terminal_id)`）、`locations: list[ToolCallLocation(path, line?)]`、`raw_input`、`raw_output`。

**MCP 服务器**：`McpServerStdio(name, command, args, env: list[EnvVariable])`、`HttpMcpServer(type="http")`、`SseMcpServer(type="sse")`、`AcpMcpServer(type="acp")`——agent 也能把客户端当 MCP host。

**枚举（`Literal`）**：

```python
StopReason           = "end_turn" | "max_tokens" | "max_turn_requests" | "refusal" | "cancelled"
ToolKind             = "read" | "edit" | "delete" | "move" | "search" | "execute" | "think" | "fetch" | "switch_mode" | "other"
ToolCallStatus       = "pending" | "in_progress" | "completed" | "failed"
PlanEntryStatus      = "pending" | "in_progress" | "completed"
PlanEntryPriority    = "high" | "medium" | "low"
PermissionOptionKind = "allow_once" | "allow_always" | "reject_once" | "reject_always"
```

## helpers 速查（`acp.helpers`，镜像 Go/TS SDK 的 API）

```python
from acp import (
    # 内容块
    text_block, image_block, audio_block,
    resource_link_block, embedded_text_resource, embedded_blob_resource, resource_block,
    # session/update 的载体
    update_agent_message_text, update_agent_thought_text,      # 最常用
    update_agent_message, update_agent_thought,                # 任意 content block 版
    update_user_message_text, update_user_message,
    update_plan, plan_entry,                                   # 计划/todo
    session_notification,                                      # 打包 (session_id, update) 为 SessionNotification
    # 工具调用展示
    start_tool_call, start_read_tool_call, start_edit_tool_call,
    update_tool_call,
    # 工具调用内容
    tool_content, tool_diff_content, tool_terminal_ref,
)
from acp.helpers import update_available_commands, update_current_mode   # 仅此两层有
```

常用组合：

```python
update_agent_thought_text("正在分析...")                # AgentThoughtChunk
update_agent_message_text("答案是 42")                  # AgentMessageChunk
update_plan([plan_entry("读代码", status="completed"),
             plan_entry("写修复", status="in_progress")])       # AgentPlanUpdate
start_tool_call("tc1", "搜索代码", kind="search", status="pending")     # ToolCallStart
start_read_tool_call("tc2", "读配置", "config.toml")    # kind=read + locations + raw_input 自动填好
start_edit_tool_call("tc3", "改代码", "src/main.py", new_text)          # kind=edit 版
update_tool_call("tc1", status="in_progress")           # ToolCallProgress
update_tool_call("tc1", status="completed", raw_output={"n": 3})
tool_diff_content("src/main.py", new_text, old_text)    # 工具调用内容里的 diff
session_notification(sid, update_agent_message_text("hi"))
```

`start_tool_call / update_tool_call` 全参数：`(tool_call_id, title?, kind?, status?, content?, locations?, raw_input?, raw_output?)`。

## contrib（`acp.contrib`，实验性，API 可能变）

| 组件 | 作用 | 核心 API |
| --- | --- | --- |
| `SessionAccumulator` | 客户端侧把流式 update 累积成可读快照 | `apply(notification) -> SessionSnapshot`、`subscribe(cb)`（返回退订函数）、`snapshot()`、`reset()`；默认切会话自动重置 |
| `SessionSnapshot` / `ToolCallView` | 快照模型：消息历史 + 工具调用状态机合并结果 | `.messages`、`.tool_calls` |
| `ToolCallTracker` | agent 侧工具调用登记与更新 | `start(...)`、`progress(...)`、`append_stream_text(...)`；`to_start_model()` / `to_tool_call_model()` 直接产出可发的 update，省去手写状态合并 |
| `PermissionBroker` | 权限代理：封装 request_permission 样板 | `request_for(...)`、`default_permission_options()`（生成 allow/reject 三选项） |

## 远程传输（实验性，`pip install "agent-client-protocol[http]"`）

```python
# HTTP：Streamable HTTP + SSE（默认 HTTP/2、无读超时长连接、自带 cookie jar）
from acp.http import create_http_stream
transport = create_http_stream("https://host/acp", headers={...})
conn = connect_to_agent(HeadlessClient(), transport)   # 只传 Transport，流参数留空

# WebSocket：单条长连接多路复用；cookie 亲和可传自管 cookie_store（跨重连复用）
from acp.ws import create_websocket_stream
transport = await create_websocket_stream("wss://host/acp")

# 服务端：框架无关核心，配 ASGI 适配（acp.http.asgi）挂到 FastAPI/Starlette
from acp.http import AcpServer
server = AcpServer(lambda conn: MyAgent())   # 每个连接回调一次工厂；registry 管理多连接
```

## 兼容性与坑

- `from acp import AgentSideConnection` 触发 DeprecationWarning（提示改用 `run_agent`/`connect_to_agent`）；规范写法 `from acp.core import AgentSideConnection`；
- 旧式 handler（方法名驼峰 `sessionUpdate`、或单 Request 参数签名）路由器仍识别，但发 DeprecationWarning，应改成 snake_case + 关键字参数；
- `spawn_agent_process` 默认环境是 `default_environment()` 白名单（不含完整 `os.environ`），需要 PATH 之外的工具时显式传 `env=dict(os.environ)`；
- Windows 下 spawn npm 的 `.cmd` 必须 `["cmd", "/c", ...]` 包装（见案例四）。
