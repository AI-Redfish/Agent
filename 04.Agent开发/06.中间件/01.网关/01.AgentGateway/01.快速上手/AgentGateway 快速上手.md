> 学习笔记 · 主题：agentgateway 快速上手 · 来源：官网 agentgateway.dev 与 GitHub 官方仓库 · 信息抓取日期：2026-11-16（当时最新版 v1.7.0）

# agentgateway 是什么

Linux 基金会托管的开源代理。它基于 AI 原生协议 MCP 与 A2A 构建。它为 agent-to-LLM、agent-to-tool、agent-to-agent 通信提供安全、可观测与治理能力。

**三种网关能力**

- LLM Gateway：用统一的 OpenAI 兼容接口转发到 OpenAI、Anthropic、Gemini、Bedrock、Ollama 等厂商。
- MCP Gateway：把 stdio、HTTP、SSE、Streamable HTTP 的 MCP 服务聚合为一个入口。
- A2A Gateway：代理 agent 之间的通信，含能力发现与任务协作。

**两种部署形态**

| 形态 | 配置方式 | 适用场景 |
| :-- | :-- | :-- |
| Standalone | 单个 YAML 配置文件 | 本机、容器、单机服务 |
| Kubernetes | Gateway API 与 CRD，内置控制器 | 集群内 |

*本笔记只覆盖 Standalone。*

# 官方地址

| 用途 | 地址 |
| :-- | :-- |
| 官网 | https://agentgateway.dev |
| Standalone 文档 | https://agentgateway.dev/docs/standalone/latest/documentation/quickstart/ |
| Kubernetes 文档 | https://agentgateway.dev/docs/kubernetes/latest/documentation/quickstart/ |
| GitHub 仓库 | https://github.com/agentgateway/agentgateway |
| Releases 下载页 | https://github.com/agentgateway/agentgateway/releases |
| 配置 schema | https://agentgateway.dev/schema/config |
| 文档源码仓库 | https://github.com/agentgateway/website |
| 官方容器镜像 | cr.agentgateway.dev/agentgateway |

**版本现状**

- 抓取时最新稳定版为 `v1.7.0`。
- 版本标签形如 `v1.7.0`，镜像标签与之一致。
- nightly 构建版本号为 `0.0.0-alpha.<commit>`，不在 releases 页展示。

# Windows 部署（二进制）

**前提**

- 系统要求 64 位 Windows（amd64）。
- 官方提供 Windows 预编译二进制 `agentgateway-windows-amd64.exe`。
- 官方一键安装脚本 `curl -sL https://agentgateway.dev/install | bash` 只适用于 macOS 与 Linux，Windows 需手动下载。

**下载**

```powershell
$ver  = "v1.7.0"
$base = "https://github.com/agentgateway/agentgateway/releases/download/$ver"

Invoke-WebRequest "$base/agentgateway-windows-amd64.exe" -OutFile agentgateway.exe
Invoke-WebRequest "$base/agentgateway-windows-amd64.exe.sha256" -OutFile agentgateway.exe.sha256
```

**校验**

```powershell
(Get-FileHash .\agentgateway.exe -Algorithm SHA256).Hash.ToLower()
Get-Content .\agentgateway.exe.sha256
```

两行输出的哈希值应一致。

**运行**

```powershell
.\agentgateway.exe --version
.\agentgateway.exe
```

不带参数运行的行为：

- 首次运行在用户配置目录生成 `config.yaml`，之后不再覆盖。
- 内置 `default` 网关监听 4000 端口。
- UI 挂在同一网关，访问 http://localhost:4000/ui 。
- 自动创建 SQLite 数据库，供 UI 的 Analytics 与 Logs 页面使用。

**用自带配置运行**

```powershell
.\agentgateway.exe -f .\config.yaml
```

此时若配置文件没有 `ui` 段，UI 只监听管理接口 15000 端口，访问 http://localhost:15000/ui 。

**端口**

| 端口 | 用途 |
| :-- | :-- |
| 4000 | 默认网关，代理流量与 UI |
| 3000 | 示例中 MCP 监听端口（由配置决定） |
| 15000 | 管理接口与 UI（配置文件未声明 `ui` 时） |

**配置目录**

按官方文档，配置目录为 `$XDG_CONFIG_HOME/agentgateway`，未设置该变量时为 `~/.config/agentgateway`。Windows 下的实际路径官方未单独说明。

*建议：Windows 上显式用 `-f` 指定配置文件路径，不依赖默认目录。*

**注意**

- 官方文档未提供独立的 Windows 安装章节，Windows 支持体现在 release 资产与 nightly 构建产物 `release-binary-windows` 上。
- 本笔记未在 Windows 实机跑通（二进制下载中断），首次运行请用 `--version` 与 UI 页面确认结果。

# 源码部署

**环境要求**

| 依赖 | 版本 |
| :-- | :-- |
| Rust | 1.86 以上 |
| Node | 24.22.1（见仓库 `ui/.nvmrc`） |
| pnpm | 由 Node 自带 corepack 提供，版本锁在 `ui/package.json` |
| Git | 任意较新版本 |

**步骤**

```powershell
git clone https://github.com/agentgateway/agentgateway.git
cd agentgateway

cd ui
corepack enable
corepack pnpm install --frozen-lockfile
corepack pnpm build
cd ..

cargo build --release --features ui
```

产物路径：`target\release\agentgateway.exe`。

**命令对应关系**

官方推荐 `make build`。它先构建 UI，再执行带 `--features ui` 的 `cargo build --release`。没有 make 时按上面的步骤手动执行。

```text
make build          →  cd ui && corepack pnpm install --frozen-lockfile && corepack pnpm build
                       cargo build --release --features ui
make build UI=0     →  cargo build --release
```

**只编译代理、跳过 UI**

```powershell
cargo build --release
```

此时不校验 UI 产物，二进制缺少内置 Web UI。

**注意**

- `ui/dist` 不纳入版本控制。在新检出上直接执行 `cargo build --features ui` 会失败。
- 本地开发可用 `cargo run -- -f examples\mcp-basic\config.yaml` 直接跑示例。
- UI 开发模式 `pnpm dev` 监听 19000 端口。

# 基本使用

**最小 LLM 路由配置**

```yaml
# config.yaml
llm:
  port: 4000
  models:
  - name: smart
    provider: openAI
    params:
      model: gpt-5.5
      apiKey: $OPENAI_API_KEY
  - name: anthropic/*
    provider: anthropic
    params:
      apiKey: $ANTHROPIC_API_KEY
    transformation:
      model: llmRequest.model.stripPrefix("anthropic/")
```

- `name` 是客户端请求里的 `model` 值。
- `params.model` 是转发给厂商的真实模型名。
- 通配名会带上前缀匹配，需配合 `transformation` 去前缀。

**设置密钥并启动**

```powershell
$env:OPENAI_API_KEY = "sk-..."
$env:ANTHROPIC_API_KEY = "sk-ant-..."

.\agentgateway.exe -f .\config.yaml
```

**发请求**

```powershell
$body = '{"model":"smart","messages":[{"role":"user","content":"Say hello"}]}'
Invoke-RestMethod -Uri http://localhost:4000/v1/chat/completions `
  -Method Post -ContentType "application/json" -Body $body
```

同一请求的 curl 形式：

```bash
curl http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"smart","messages":[{"role":"user","content":"Say hello"}]}'
```

**MCP 聚合配置**

```yaml
# config.yaml
mcp:
  port: 3000
  policies:
    cors:
      allowOrigins:
      - "*"
      allowHeaders:
      - mcp-protocol-version
      - content-type
      - cache-control
      - mcp-session-id
      exposeHeaders:
      - "Mcp-Session-Id"
  targets:
  - name: everything
    stdio:
      cmd: npx
      args: ["@modelcontextprotocol/server-everything"]
```

- `stdio` 类型的 target 会在客户端连接时启动本地命令。
- 远端 MCP 服务用 `mcp` 传输：

```yaml
mcp:
  port: 3000
  targets:
  - name: remote-mcp
    mcp:
      host: http://localhost:3005/mcp
```

**MCP 端点**

| 端点 | 传输 |
| :-- | :-- |
| `/mcp` | Streamable HTTP，JSON-RPC 走 POST |
| `/sse` | SSE |

MCP 请求必须带 `Accept: application/json, text/event-stream`。初始化后每个请求还要带 `mcp-session-id` 响应头里的会话 ID。

**UI 与 Playground**

| 地址 | 用途 |
| :-- | :-- |
| http://localhost:4000/ui | 首次运行打开的欢迎向导，可启用 LLM、MCP、Traffic |
| http://localhost:4000/ui/llm/playground/ | LLM 调试台 |
| http://localhost:4000/ui/mcp/playground/ | MCP 工具调试台 |

Playground 提示 `Browser access is not allowed` 时，点 `Apply CORS`。

**配置热加载**

agentgateway 监听配置文件变化。改路由或策略后不需要重启进程。

# 常见问题

**配置文件不生效**

- `-f` 指定的文件不会自动补默认项。数据库与 UI 需在文件里显式声明：

```yaml
config:
  database:
    url: sqlite://data.db
gateways:
  default:
    port: 4000
ui:
  gateways: default
```

*`: url` 用相对路径最稳。Windows 下带盘符的绝对路径写法官方未给出，需自行验证。*

**Windows 上 stdio 目标启动失败**

MCP `stdio` 的 `cmd` 在 Windows 上可能需要写成 `npx.cmd`。官方文档未说明这一点，此项为推断，需实测确认。

**UI 打不开**

- 用无参方式启动时访问 4000 端口。
- 用 `-f` 启动且配置无 `ui` 段时访问 15000 端口，且只允许本机访问。

**端口冲突**

默认占用 4000，示例 MCP 占用 3000。启动前确认端口空闲：

```powershell
netstat -ano | Select-String ":4000"
```
