# 相关教程

Agent Client Protocol 官网

https://agentclientprotocol.com/



Python SDK 官方文档

https://agentclientprotocol.github.io/python-sdk/



Python SDK GitHub 仓库

https://github.com/agentclientprotocol/python-sdk



PyPI

https://pypi.org/project/agent-client-protocol/



# ACP 简介

ACP（Agent Client Protocol）用于连接代码编辑器、IDE 等客户端与 AI Agent。

在本文的 `echo_agent` 联调中：

| 角色 | 实现 | 作用 |
| :--- | :--- | :--- |
| Client | `examples/client.py` | 启动 Agent、创建会话、发送 Prompt、接收更新 |
| Agent | `examples/echo_agent.py` | 接收 Prompt，并将内容原样流式返回 |
| Transport | stdin/stdout | 传输 JSON-RPC 消息 |

一次最小交互流程如下：

```text
Client 启动 Agent 子进程
    -> initialize（协商协议版本）
    -> session/new（创建会话）
    -> session/prompt（发送消息）
    <- session/update（Agent 流式返回消息）
    <- PromptResponse(stop_reason="end_turn")
```

`echo_agent` 不会调用大模型，也不需要 API Key，适合验证 ACP 环境、进程通信和协议调用是否正常。



# 环境搭建

本文联调环境：

```text
Windows
Python 3.13.5
agent-client-protocol 0.12.1
```

SDK 支持 Python 3.10 至 3.14。



## 下载示例代码

示例文件位于官方 Python SDK 仓库的 `examples` 目录。

本文固定使用 `0.12.1` 标签，使示例代码与 PyPI 包版本一致：

```powershell
git clone --depth 1 --branch 0.12.1 https://github.com/agentclientprotocol/python-sdk.git
cd python-sdk
```

版本必须保持一致。不要将 PyPI 的旧版本与 GitHub `main` 分支的最新示例混用，否则生成模型或辅助 API 可能不兼容。



## Python venv 安装-推荐

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1

python -m pip install --upgrade pip
python -m pip install agent-client-protocol==0.12.1
```

验证安装版本：

```powershell
python -c "from importlib.metadata import version; print(version('agent-client-protocol'))"
```

预期输出：

```text
0.12.1
```



## Conda 安装

```powershell
conda create -n acp_dev python=3.13 -y
conda activate acp_dev

python -m pip install agent-client-protocol==0.12.1
```



# echo_agent 实现

官方示例路径：

```text
examples/echo_agent.py
```

`EchoAgent` 继承 `acp.Agent`，主要实现以下方法：

| 方法 | 作用 |
| :--- | :--- |
| `on_connect()` | 保存与 Client 的连接，用于发送 `session/update` |
| `initialize()` | 返回双方协商后的协议版本 |
| `new_session()` | 创建并返回新的会话 ID |
| `prompt()` | 读取用户消息，并将消息原样发送回 Client |

核心逻辑：

```python
class EchoAgent(Agent):
    _conn: Client

    def on_connect(self, conn: Client) -> None:
        self._conn = conn

    async def initialize(
        self,
        protocol_version: int,
        client_capabilities=None,
        client_info=None,
        **kwargs,
    ) -> InitializeResponse:
        return InitializeResponse(protocol_version=protocol_version)

    async def new_session(
        self,
        cwd: str,
        additional_directories=None,
        mcp_servers=None,
        **kwargs,
    ) -> NewSessionResponse:
        return NewSessionResponse(session_id=uuid4().hex)

    async def prompt(self, session_id: str, prompt: list, **kwargs) -> PromptResponse:
        for block in prompt:
            text = block.get("text", "") if isinstance(block, dict) else getattr(block, "text", "")
            chunk = update_agent_message(text_block(text))

            await self._conn.session_update(
                session_id=session_id,
                update=chunk,
                source="echo_agent",
            )

        return PromptResponse(stop_reason="end_turn")
```

程序入口使用 `run_agent()` 在 stdin/stdout 上运行 Agent：

```python
async def main() -> None:
    await run_agent(EchoAgent())


if __name__ == "__main__":
    asyncio.run(main())
```

注意：`run_agent()` 的标准输出用于 ACP JSON-RPC 通信，不要在 Agent 中随意使用 `print()` 向 stdout 输出调试信息。需要记录日志时应输出到 stderr 或日志文件，否则可能破坏协议消息流。



# echo_agent 联调测试

## 单独启动 Agent

```powershell
python examples/echo_agent.py
```

启动后终端没有普通聊天界面是正常现象。Agent 正在等待 ACP Client 通过 stdin 发送 JSON-RPC 消息，不能直接在终端中输入自然语言进行测试。

按 `Ctrl+C` 可以停止进程。



## 使用官方 Client 联调

官方客户端路径：

```text
examples/client.py
```

Windows 下建议显式传入 Agent 使用的 Python 解释器：

```powershell
.\.venv\Scripts\python.exe examples\client.py .\.venv\Scripts\python.exe examples\echo_agent.py
```

如果使用 Conda：

```powershell
$python = (Get-Command python).Source
python examples\client.py $python examples\echo_agent.py
```

命令参数含义：

```text
python examples/client.py AGENT_PROGRAM [ARGS...]

AGENT_PROGRAM = Python 解释器
ARGS          = examples/echo_agent.py
```

进入交互界面后输入消息：

```text
> 你好 ACP
| Agent: 你好 ACP
> second message
| Agent: second message
```

结束测试：

```text
Ctrl+C
```



## 本机联调结果

实际执行命令：

```powershell
.\.venv\Scripts\python.exe examples\client.py .\.venv\Scripts\python.exe examples\echo_agent.py
```

连续发送两条消息，实际输出：

```text
> | Agent: 你好 ACP
> | Agent: second message
>
```

测试结论：

| 检查项 | 结果 |
| :--- | :--- |
| Client 启动 Agent 子进程 | 通过 |
| `initialize` 协议初始化 | 通过 |
| `new_session` 创建会话 | 通过 |
| `prompt` 发送文本 | 通过 |
| `session/update` 返回消息 | 通过 |
| 同一会话连续发送消息 | 通过 |



# Client 关键代码

Client 使用 `connect_to_agent()` 将子进程 stdin/stdout 包装成 ACP 连接：

```python
proc = await asyncio.create_subprocess_exec(
    spawn_program,
    *spawn_args,
    stdin=asyncio.subprocess.PIPE,
    stdout=asyncio.subprocess.PIPE,
)

client_impl = ExampleClient()
conn = connect_to_agent(client_impl, proc.stdin, proc.stdout)
```

初始化协议并创建会话：

```python
await conn.initialize(
    protocol_version=PROTOCOL_VERSION,
    client_capabilities=ClientCapabilities(),
    client_info=Implementation(
        name="example-client",
        title="Example Client",
        version="0.1.0",
    ),
)

session = await conn.new_session(
    mcp_servers=[],
    cwd=os.getcwd(),
)
```

发送 Prompt：

```python
await conn.prompt(
    session_id=session.session_id,
    prompt=[text_block("你好 ACP")],
)
```

Client 在 `session_update()` 中接收 Agent 推送的消息：

```python
async def session_update(self, session_id, update, **kwargs) -> None:
    if not isinstance(update, AgentMessageChunk):
        return

    if isinstance(update.content, TextContentBlock):
        print(f"| Agent: {update.content.text}")
```



# 接入 Zed

在 Zed 的 `settings.json` 中增加 Agent Server 配置。

Windows 示例：

```json
{
  "agent_servers": {
    "Echo Agent (Python)": {
      "type": "custom",
      "command": "D:\\develop\\agentclientprotocol\\python-sdk\\.venv\\Scripts\\python.exe",
      "args": [
        "D:\\develop\\agentclientprotocol\\python-sdk\\examples\\echo_agent.py"
      ]
    }
  }
}
```

打开 Zed 的 Agents 面板并选择 `Echo Agent (Python)`。发送消息后，应收到相同内容的流式回显。

路径需要替换为本机 Python SDK 仓库的实际绝对路径。



# 常见问题

## WinError 193

错误示例：

```text
OSError: [WinError 193] %1 不是有效的 Win32 应用程序
```

原因：Client 尝试将 `echo_agent.py` 当作 Windows 可执行程序直接启动。

不要使用：

```powershell
python examples\client.py examples\echo_agent.py
```

改为显式传入 Python 解释器：

```powershell
.\.venv\Scripts\python.exe examples\client.py .\.venv\Scripts\python.exe examples\echo_agent.py
```



## TextContentBlock 的 type 字段缺失

错误示例：

```text
1 validation error for TextContentBlock
type
  Field required
```

原因通常是安装的 PyPI 包与 GitHub 示例代码版本不一致。例如安装 `0.12.1`，却直接运行更新后的 `main` 分支示例。

解决方式是同时固定 SDK 和示例版本：

```powershell
git clone --depth 1 --branch 0.12.1 https://github.com/agentclientprotocol/python-sdk.git
python -m pip install agent-client-protocol==0.12.1
```

在 `0.12.1` 中应优先使用辅助函数创建内容块：

```python
from acp import text_block

content = text_block("你好 ACP")
```



## Agent 启动后没有输出

`echo_agent.py` 是协议服务进程，不是命令行聊天程序。必须由 ACP Client 启动或连接，并通过 stdin/stdout 发送合法的 ACP JSON-RPC 消息。



## stdout 出现非协议文本

Agent 的 stdout 是 ACP 传输通道。普通调试输出会与 JSON-RPC 消息混在一起，导致 Client 解析失败。

调试信息应写入 stderr：

```python
import sys

print("debug message", file=sys.stderr)
```
