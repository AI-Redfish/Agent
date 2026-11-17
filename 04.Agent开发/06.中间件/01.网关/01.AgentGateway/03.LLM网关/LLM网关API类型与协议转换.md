> 适用范围：Windows 本地 Standalone LLM 网关的 API 类型与协议转换。使用时阅读本章；LLM 网关基础配置与密钥见 LLM网关使用.md。
> 依据：官方文档（来源页见文末）。API 端点实测未由 AI 完成，验证命令供使用时执行；记录日期：2026-11-16。

# API 类型全景

llm 段模式（llm.gateways 挂载）下，以下端点全部自动暴露，按客户端请求路径自动映射路由类型，无需显式配置。Routing-based 模式需在 policies.ai.routes 中显式映射。

| # | API 类型 | 端点 | 用途 | 学习状态 |
| :-- | :-- | :-- | :-- | :-- |
| 1 | Chat completions | `/v1/chat/completions` | OpenAI 主力对话接口 | 已掌握（见 LLM网关使用.md） |
| 2 | Responses | `/v1/responses` | OpenAI 新一代有状态接口 | 已整理（本章） |
| 3 | Messages | `/v1/messages` | Anthropic Claude 原生接口 | 已整理（本章） |
| 4 | Token count | `/v1/messages/count_tokens` | Anthropic token 预估 | 待学 |
| 5 | Gemini | Gemini 原生 wire 格式（含流式） | Google 生态客户端 | 待学 |
| 6 | Embeddings | OpenAI 兼容 Embeddings | 向量化 | 待学 |
| 7 | Audio | 转写、翻译、语音 | 音频处理，记录用量 | 待学 |
| 8 | Realtime | OpenAI Realtime WebSocket 代理 | 实时语音对话 | 待学 |
| 9 | Rerank | Cohere 兼容 Rerank | 重排序 | 待学 |
| 10 | Passthrough | 任意路径直透 | 不转换直接转发上游 | 待学 |
| 11 | Models | `/v1/models` | 列出网关模型 | 已掌握 |
| 12 | Decisions | OpenAI Decisions / TypeSafe SystemOne | 决策路由与 token 追踪 | 待学 |

# Responses API（/v1/responses）

OpenAI 新一代接口。与 chat completions 的区别：请求体用 `input` 而非 `messages`；支持服务端多轮状态（previous_response_id）与内置工具；OpenAI SDK 的 `client.responses.create(...)` 走此端点。新版本 Agent 客户端多已默认使用。

**llm 段模式零配置**：自动映射，现有配置直接可用。前提是该模型的 provider 支持 Responses 格式；provider 只声明 completions 格式时是否可用需实测。

**三个边界**：

1. 不支持 WebSocket 传输，只能 HTTP POST。WS 升级请求返回 `405` + `websocket_not_supported`。
2. 命名空间工具（namespaced tools）：上游走 Chat Completions 或 Bedrock 时，工具名被扁平化为 `namespace__function` 格式；`allowed_tools` 限制与自定义命名空间成员不支持，使用即在网关层失败，请求不到上游。
3. usage 字段统一按 OpenAI 约定上报（缓存 token 计入 `usage.input_tokens`，并单独在 `input_tokens_details.cached_tokens` 报告）。

# Anthropic Messages API（/v1/messages）

Anthropic Claude 的原生接口。Claude Code、Claude Desktop 等 Anthropic 生态客户端使用此方言。与 chat completions 的结构差异：`max_tokens` 必填；响应为 `content` 数组 + `stop_reason`，非 `choices` + `finish_reason`。

**llm 段模式零配置**：自动映射。anthropic provider 会自动补 `x-api-key`、`anthropic-version` 头。

**协议转换：客户端方言翻译**。客户端说 Anthropic 方言，上游不需要懂它。网关按上游声明格式自动转换，优先级固定（与 formats 列表顺序无关）：

| 优先级 | 上游格式 | 网关动作 |
| :-- | :-- | :-- |
| 1 | messages | 原生直传 |
| 2 | responses | 转 OpenAI Responses |
| 3 | completions | 转 OpenAI Chat Completions |
| 4 | Bedrock Converse | 转 Bedrock Converse |

同时声明 responses 与 completions 时，固定优先走 Responses。

**反向转换同样成立**：OpenAI 客户端（`/v1/chat/completions`）路由到 Anthropic messages 上游时，网关转为 Messages 格式，回复转回 OpenAI 形状（官方 completions 页明示）。即网关可放心当“方言翻译器”：客户端用哪个 SDK 都行，上游配哪家都行。

**thinking（推理历史）保留差异（选型关键）**：

- chat completions ↔ messages 之间：双向保留（靠 `reasoning_content` + `reasoning_signature` 回放）。
- messages → responses 方向：静默丢弃，模型每轮丢失先前推理。
- 推理模型多轮会话需保留推理上下文时，让上游只声明 completions 格式。

**静默丢弃清单（走 Responses 转换时，无错误无警告）**：`stop_sequences`、`top_k`、thinking/redacted-thinking 历史、消息历史中的 citations、document/server-tool 内容块、tools 列表中的 server 工具（如 web search）。依赖这些特性的请求换转换路径后必须重测。

**实用细节**：上游拒绝超长 prompt 时，网关把错误改写为 `capability_rejected: prompt_too_long` 前缀（仅 OpenAI 格式错误；Gemini/Vertex 的 Google 格式错误不加标记）。Claude Code 依赖此标记自动压缩上下文重试。客户端 query string（如 `?beta=true`）仅原生 messages 透传时保留，转换后丢弃。

**配套端点**：`/v1/messages/count_tokens`（token 预估，路由类型 anthropicTokenCount）。llm 段模式下同样自动可用；转换路由下的行为未验证。

# 客户端接入（Anthropic 方言）

Anthropic SDK 客户端把 base URL 指到网关根即可：

```text
ANTHROPIC_BASE_URL = http://127.0.0.1:4000
ANTHROPIC_API_KEY  = 网关 Key（未开认证时填非空占位值）
model = 网关 Incoming model match（如 chat-main）
```

SDK 自动请求 `/v1/messages`。usage 字段永远跟客户端方言走：用哪个端点，就收到哪种约定的 usage（`input_tokens` vs `prompt_tokens`），与上游实际厂商无关。

# 验证命令（PowerShell）

**Responses**：

```powershell
$body = @{
    model = "chat-main"
    input = "Reply with one short greeting."
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://127.0.0.1:4000/v1/responses" `
    -Method Post -ContentType "application/json; charset=utf-8" -Body $body
```

通过标准：返回 OpenAI Responses 结构（`output` 数组 + `usage`）。

**Messages**：

```powershell
$body = @{
    model = "chat-main"
    max_tokens = 100
    messages = @(
        @{ role = "user"; content = "Reply with one short greeting." }
    )
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "http://127.0.0.1:4000/v1/messages" `
    -Method Post -ContentType "application/json; charset=utf-8" -Body $body
```

通过标准：返回 Anthropic 形状（`content` 数组、`stop_reason`、`usage.input_tokens`）。

# 后续进阶方向（对话中仅列名，待逐个学习验证）

- Transformations：CEL 表达式动态改写 LLM 请求字段（如按身份限制 max_tokens）。
- 虚拟模型其余路由：failover（故障转移）、conditional（条件路由）、callout；及 `agw.ai.original_model` / `gen_ai.request.model` 追溯属性。
- Inference 推理路由：Gateway API Inference Extension 与 standalone EPP 调度模式。
- Benchmarking：推理压测。

# 官方来源与版本

- API 类型总览：https://agentgateway.dev/docs/standalone/latest/documentation/llm/api-types.md
- Responses：https://agentgateway.dev/docs/standalone/latest/documentation/llm/api-types/responses.md
- Chat completions（含转 Messages 方向与 reasoning 回放）：https://agentgateway.dev/docs/standalone/latest/documentation/llm/api-types/completions.md
- Messages（转换优先级、静默丢弃、prompt_too_long）：https://agentgateway.dev/docs/standalone/latest/documentation/llm/api-types/messages.md
- Token count：https://agentgateway.dev/docs/standalone/latest/documentation/llm/api-types/token-count/
- 虚拟模型：https://agentgateway.dev/docs/standalone/latest/documentation/llm/virtual-models.md
- 抓取日期：2026-02-25（latest，即 1.7.x）；写作时需复核
