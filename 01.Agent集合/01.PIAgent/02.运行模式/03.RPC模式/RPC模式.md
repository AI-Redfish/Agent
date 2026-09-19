# 概述

RPC 模式通过 stdin/stdout 的 JSONL 协议实现进程间通信。

它允许另一个程序通过标准输入发送命令，并从标准输出读取响应。

RPC 模式支持扩展 UI 协议，使远程客户端能够呈现 confirm 对话框、选择列表等交互元素。

这种模式适合以下场景：

| 场景       | 说明                                   |
| :--------- | :------------------------------------- |
| 编辑器插件 | 在 VS Code 等编辑器扩展中集成 Pi Agent |
| 自定义前端 | 基于 RPC 协议构建自己的 Pi Agent 界面  |
| 后台服务   | 把 Pi Agent 作为子进程嵌入更大的系统   |

与 Print 模式（一次性问答）不同，RPC 模式是**长驻的双向通道**：客户端可以持续发指令、实时收事件流，适合需要多轮交互的嵌入式场景。

# 启动方式

```bash
pi --mode rpc [options]
```

常用启动参数：

| 参数                 | 说明                                       |
| :------------------- | :----------------------------------------- |
| `--provider <name>`  | 指定 LLM 提供商（anthropic、openai 等）    |
| `--model <pattern>`  | 模型名，支持 `provider/id` 和 `:thinking`  |
| `--name <name>`      | 设置会话显示名                             |
| `--no-session`       | 禁用会话持久化                             |
| `--session-dir <path>` | 自定义会话存储目录                       |

# 协议总览

通信基于三类 JSON 行（JSONL）：

| 类型      | 方向         | 说明                             |
| :-------- | :----------- | :------------------------------- |
| Command   | 客户端 → Pi  | 发送到 stdin，每行一个 JSON 对象 |
| Response  | Pi → 客户端  | `type: "response"`，命令执行结果 |
| Event     | Pi → 客户端  | Agent 运行事件，持续流式输出     |

所有命令支持可选的 `id` 字段用于请求/响应关联，响应会原样带回这个 `id`。

**分帧规则（重要）**：严格 JSONL，只以 LF（`\n`) 作为记录分隔符，客户端要容忍 `\r\n` 并去掉尾部 `\r`。注意 Node 的 `readline` 不合规——它会把 `U+2028/U+2029` 也当换行，而这些字符可以合法出现在 JSON 字符串里。

# 核心命令

## prompt：发送提示

```json
{"id": "req-1", "type": "prompt", "message": "Hello, world!"}
```

带图片：

```json
{"type": "prompt", "message": "这张图里有什么？", "images": [{"type": "image", "data": "base64数据", "mimeType": "image/png"}]}
```

如果 Agent 正在流式输出中，必须指定 `streamingBehavior`，否则命令报错：

| 取值          | 行为                                                     |
| :------------ | :------------------------------------------------------- |
| `"steer"`     | 当前助手回合执行完工具调用后、下次 LLM 调用前插入         |
| `"followUp"`  | 等 Agent 完全结束后才投递                                |

消息若是扩展命令（如 `/mycommand`），即使在流式中也会立即执行。Skill 命令和提示词模板会先展开再发送。

## steer 与 follow_up：消息注入

- `steer`：运行中途改方向，在当前回合工具调用结束后、下一次 LLM 调用前投递；
- `follow_up`：排队追问，等 Agent 结束后投递。

```json
{"type": "steer", "message": "停下，先做这个"}
{"type": "follow_up", "message": "做完后再顺便检查一下"}
```

投递节奏可用 `set_steering_mode` / `set_follow_up_mode` 控制：`"all"`（全部投递）或 `"one-at-a-time"`（每回合一条，默认）。

## abort 与 clear_queue：中断控制

```json
{"type": "abort"}
```

`abort` 中断当前操作并等会话空闲后响应。要实现类似交互模式的 Esc 行为：先发 `clear_queue` 取回排队消息，再发 `abort`，把取回的文本放回客户端输入框。

## new_session：开启新会话

```json
{"type": "new_session"}
```

扩展可以通过 `session_before_switch` 事件取消切换，响应中 `data.cancelled` 会标记结果。

# 状态与模型管理

## 查询状态与消息

```json
{"type": "get_state"}
```

返回当前模型、思考等级、是否流式中、会话文件路径、消息数等快照：

```json
{
  "type": "response", "command": "get_state", "success": true,
  "data": {
    "model": {...}, "thinkingLevel": "medium", "isStreaming": false,
    "sessionFile": "/path/to/session.jsonl", "messageCount": 5
  }
}
```

`get_messages` 返回完整对话消息列表。

## 模型与思考等级

```json
{"type": "set_model", "provider": "anthropic", "modelId": "claude-sonnet-4-20250514"}
{"type": "cycle_model"}
{"type": "get_available_models"}
{"type": "set_thinking_level", "level": "high"}
```

思考等级：`off` / `minimal` / `low` / `medium` / `high`（部分模型支持 `xhigh` / `max`）。`get_available_thinking_levels` 可查询当前模型支持的等级。

# 上下文压缩

```json
{"type": "compact"}
{"type": "compact", "customInstructions": "重点关注代码改动"}
{"type": "set_auto_compaction", "enabled": true}
```

`compact` 手动压缩上下文，响应返回摘要、压缩前后 token 数和开销；`set_auto_compaction` 控制接近上下文上限时是否自动压缩。

# 会话管理

| 命令                   | 说明                                       |
| :--------------------- | :----------------------------------------- |
| `get_session_stats`    | token 用量、成本、上下文占用百分比         |
| `export_html`          | 导出会话为 HTML 文件                       |
| `switch_session`       | 切换到指定会话文件                         |
| `fork`                 | 从历史用户消息分叉出新分支                 |
| `clone`                | 复制当前分支为新会话                       |
| `get_entries`          | 获取全部会话条目，支持 `since` 游标增量拉取 |
| `get_last_assistant_text` | 取最后一条助手回复文本                  |
| `set_session_name`     | 设置会话显示名                             |

`get_entries` 的 `since` 游标机制值得注意：会话是只追加的条目树，entry id 可作为持久游标，客户端重启后也能只拉取增量。

# 事件流

Pi 向 stdout 持续输出 JSON 事件，主要类型：

| 事件                     | 说明                                       |
| :----------------------- | :----------------------------------------- |
| `agent_start` / `agent_end` | Agent 开始 / 一轮底层运行结束           |
| `agent_settled`          | 完全落定：不再有重试、压缩或排队消息        |
| `turn_start` / `turn_end` | 一个回合（助手响应 + 工具调用）开始/结束   |
| `message_update`         | 流式增量（文本/思考/工具调用 delta）        |
| `tool_execution_start` / `update` / `end` | 工具执行生命周期           |
| `bash_execution_update`  | 直接 `bash` 命令的输出块（带原命令 `id`）   |
| `queue_update`           | 排队的 steer/follow_up 队列变化             |
| `compaction_start` / `end` | 上下文压缩开始/结束                       |
| `auto_retry_start` / `end` | 瞬时错误（过载、限流）自动重试             |

流式文本的关键是处理 `message_update` 中的 `assistantMessageEvent`：

```json
{"type":"message_update","assistantMessageEvent":{"type":"text_delta","contentIndex":0,"delta":"Hello "}}
```

delta 类型包括 `text_delta`、`thinking_delta`、`toolcall_start/delta/end` 等。客户端需根据 `contentIndex` 自行拼装实时部分消息，`message_end` 里的完整消息才是权威版本。判断"整个任务结束"应监听 `agent_settled` 而不是 `agent_end`——后者之后还可能有自动重试或排队续跑。

# 扩展 UI 协议

扩展中的 `ctx.ui.select()`、`ctx.ui.confirm()` 等交互调用，在 RPC 模式下转换为 stdout 上的 `extension_ui_request`，由客户端代为呈现。

分两类：

| 类别             | 方法                                       | 是否需要回应           |
| :--------------- | :----------------------------------------- | :--------------------- |
| 对话框方法       | `select`、`confirm`、`input`、`editor`     | 必须回 `extension_ui_response` |
| 即发即忘方法     | `notify`、`setStatus`、`setWidget`、`setTitle`、`set_editor_text` | 无需回应 |

对话框请求可带 `timeout` 字段（毫秒），超时后 Pi 侧自动用默认值解析，客户端无需自己管理超时。

以 confirm 为例，Pi 发出请求：

```json
{"type": "extension_ui_request", "id": "uuid-2", "method": "confirm", "title": "清空会话？", "message": "所有消息将丢失。", "timeout": 5000}
```

客户端回应用答：

```json
{"type": "extension_ui_response", "id": "uuid-2", "confirmed": true}
```

取消任意对话框则回 `{"type": "extension_ui_response", "id": "...", "cancelled": true}`。

注意：TUI 专属能力（如 `custom()` 自定义组件）在 RPC 模式下不可用，扩展代码中应使用 `ctx.mode === "tui"` 做守卫；RPC 模式下 `ctx.mode` 为 `"rpc"`、`ctx.hasUI` 为 `true`。

# 客户端示例

## Python

```python
import subprocess
import json

proc = subprocess.Popen(
    ["pi", "--mode", "rpc", "--no-session"],
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    text=True
)

def send(cmd):
    proc.stdin.write(json.dumps(cmd) + "\n")
    proc.stdin.flush()

# 发送提示
send({"type": "prompt", "message": "你好！"})

# 处理事件流：拼接流式文本，直到本轮结束
for line in proc.stdout:
    event = json.loads(line)
    if event.get("type") == "message_update":
        delta = event.get("assistantMessageEvent", {})
        if delta.get("type") == "text_delta":
            print(delta["delta"], end="", flush=True)
    if event.get("type") == "agent_end":
        print()
        break
```

## Node.js

```javascript
const { spawn } = require("child_process");

const agent = spawn("pi", ["--mode", "rpc", "--no-session"]);

agent.stdout.on("data", (chunk) => {
    // 按 \n 分帧解析每行 JSON（略，需自行缓冲）
});

// 发送提示
agent.stdin.write(JSON.stringify({ type: "prompt", message: "Hello" }) + "\n");

// Ctrl+C 时中断 Agent
process.on("SIGINT", () => {
    agent.stdin.write(JSON.stringify({ type: "abort" }) + "\n");
});
```

**Node.js/TypeScript 用户的替代方案**：不必起子进程，可直接使用 `@earendil-works/pi-coding-agent` 包里的 `AgentSession` 类，类型更友好，省去协议编解码。

# 错误处理

失败的命令返回 `success: false` 和错误信息：

```json
{"type": "response", "command": "set_model", "success": false, "error": "Model not found: invalid/model"}
```

JSON 解析失败同样返回 `command: "parse"` 的错误响应，不会中断进程。

# 简化记忆

```text
RPC 模式 = pi --mode rpc，stdin 进命令 / stdout 出响应和事件

协议     ->  JSONL over stdio，只认 \n 分帧
三类消息 ->  Command（入）、Response（出，type=response）、Event（出，流式）
关联     ->  命令带可选 id，响应原样带回
发提示   ->  prompt（流式中需 streamingBehavior: steer | followUp）
中途插话 ->  steer（下轮 LLM 调用前），follow_up（结束后）
中断     ->  clear_queue 取回排队消息 + abort
查状态   ->  get_state / get_messages / get_session_stats
换模型   ->  set_model / set_thinking_level
压缩     ->  compact / set_auto_compaction
事件收尾 ->  监听 agent_settled 才算真正结束
扩展 UI  ->  extension_ui_request/response 子协议，对话框需回应，通知类即发即忘
```
