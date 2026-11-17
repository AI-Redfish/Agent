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

此时若配置文件没有 `ui` 段，UI 默认只在管理接口 15000 提供，访问 http://localhost:15000/ui 。要使用本章推荐的 4000 页面与 LLM Playground，需将 `ui` 和 `llm` 挂到 default 网关，见下文「4000 与 15000 的使用选择」。

**端口**

| 端口 | 用途 |
| :-- | :-- |
| 4000 | 默认网关，代理流量与 UI |
| 3000 | 示例中 MCP 监听端口（由配置决定） |
| 15000 | admin 管理接口及 UI；UI 挂载到 4000 后，管理入口仍存在，除非另有配置 |

**配置目录**

优先级：`$XDG_CONFIG_HOME/agentgateway`，未设置时用 `~/.config/agentgateway`。

Windows 实测路径为 `C:\Users\<用户>\.config\agentgateway\config.yaml`。Windows 下同样使用 `~/.config`，不跟随 `%APPDATA%`。

**注意**

- 官方文档未提供独立的 Windows 安装章节，Windows 支持体现在 release 资产与 nightly 构建产物 `release-binary-windows` 上。
- 本文 Windows 结论来自源码构建产物实测（2026-11-16，commit `18f83707`）。release 预编译包未实测。

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

产物路径：`target\release\agentgateway.exe`，约 108 MB。

**实测记录**

| 项 | 实测值 |
| :-- | :-- |
| Rust | 1.100.0，由 `rust-toolchain.toml` 锁定，rustup 自动安装 |
| Node | 24.12.0 可构建（仓库要求 24.22.1，未强制） |
| pnpm | 11.20.0，corepack 提供 |
| 并行度 | `-j 6`（16 GB 内存机器） |
| 耗时 | 20 分 36 秒 |

**PowerShell 坑**

`cargo ... 2>&1 | Tee-Object` 会把 cargo 的 stderr 进度行报成 `NativeCommandError`，看起来像编译失败，实际仍在编译。改用 cmd 重定向：

```powershell
cmd /c "cargo build --release --features ui -j 6 > D:\agw-build.log 2>&1"
```

**编译卡住的判断**

该阶段 rustc 长时间无输出属正常，大 crate 的 codegen 可长达 20 分钟。先确认进程存在，不要急着重跑：

```powershell
Get-Process rustc,cargo -ErrorAction SilentlyContinue | Select-Object Id,ProcessName,WorkingSet
```

判读：

| 现象 | 含义 | 处理 |
| :-- | :-- | :-- |
| 有 rustc，内存占用高 | 正在 codegen | 继续等 |
| 无 rustc，无 exe | 已退出或被杀 | 看日志尾部找 error |
| 日志停在 `Blocking waiting for file lock` | 多个终端同时构建 | 只留一个，其余关掉 |

内存 16 GB 时建议 `-j 6`；并行度过高可能被系统终止，表现为静默结束。

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

# 本地启动与访问

**启动前检查**

```powershell
netstat -ano | Select-String ":4000|:15000"
Get-Process agentgateway -ErrorAction SilentlyContinue
```

两条都无输出才能按默认端口启动。有则先处理，否则报 `os error 10048` 并退出。

**启动（前台，看日志）**

```powershell
cd D:\develop\project\AgentR\agentgateway
.\target\release\agentgateway.exe
```

无参数启动会读取或生成 `C:\Users\<用户>\.config\agentgateway\config.yaml`。默认配置把 UI 挂在 4000 网关，同时暴露 admin 15000。

**启动成功的日志特征**

```text
info  state_manager  loaded config from File("...\.config\agentgateway\config.yaml")
info  app            serving UI at http://localhost:4000/ui
info  management::hyper_helpers  listener established  address=127.0.0.1:15000 component="admin"
info  proxy::gateway  started bind  bind="bind/4000"
```

出现 `serving UI` 与 `bind/4000` 即可用。

**验证**

| 地址 | 实测 |
| :-- | :-- |
| http://127.0.0.1:4000/ui | 200 |
| http://127.0.0.1:15000/ui | 200 |

命令行验证：

```powershell
curl.exe -s -o NUL -w "%{http_code}" http://127.0.0.1:15000/ui
curl.exe -s -o NUL -w "%{http_code}" http://127.0.0.1:4000/ui
```

两个端口返回同一套 UI，但上述 200 只验证页面可加载，不验证 Playground 或上游模型可用。

**4000 与 15000 的使用选择**

- 在本机当前配置下，15000 页面提供的管理操作，在 4000 页面也有对应入口。
- 日常统一访问 `http://127.0.0.1:4000/ui`；LLM Playground 使用 `http://127.0.0.1:4000/ui/llm/playground`。
- 4000 同时挂载管理 UI 和 LLM 业务路由；15000 是管理入口，底层接口并不完全相同。
- 本次构建从 15000 打开 Playground，会向 15000 发送聊天请求并返回 404；从 4000 打开后，已通过浏览器实测 HTTP 200 并收到 OK 回复。
- 这是同一实例的两个入口，无须重复注册模型，也无须因统一访问入口而关闭 15000。

与本次验证对应的配置片段：

```yaml
config:
  adminAddr: 127.0.0.1:15000
gateways:
  default:
    port: 4000
ui:
  gateways: default
llm:
  gateways: default
```

合并到当前生效配置，保留已有数据库、会话、Provider、Model 及 MCP 设置，不要整文件覆盖或重复顶层键。`ADMIN_ADDR` 环境变量可覆盖管理地址。

详细解释、请求路径及安全边界见 [LLM 网关使用：4000 与 15000 入口的区别](../03.LLM网关/01.LLM网关使用.md#4000-与-15000-入口的区别)。

*本结论限定本机 commit `18f83707` 及上述挂载方式。4000 提供管理 UI 后，不要将未受保护的端口直接对外开放。*

**后台常驻**

```powershell
Start-Process -FilePath .\target\release\agentgateway.exe `
  -WorkingDirectory D:\develop\project\AgentR\agentgateway `
  -RedirectStandardOutput D:\agw-run.log `
  -RedirectStandardError D:\agw-run.err.log -WindowStyle Hidden
```

查看日志：

```powershell
Get-Content D:\agw-run.log -Tail 20
```

**开机自启**

需要开机自启时用计划任务，不推荐注册为服务：

```powershell
$action  = New-ScheduledTaskAction -Execute "D:\develop\project\AgentR\agentgateway\target\release\agentgateway.exe" -WorkingDirectory "D:\develop\project\AgentR\agentgateway"
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName "agentgateway" -Action $action -Trigger $trigger -RunLevel Highest
```

取消：`Unregister-ScheduledTask -TaskName agentgateway -Confirm:$false`

**停止**

```powershell
Get-Process agentgateway | Stop-Process -Force
```

**端口冲突**

日志出现 `Error: admin server starts ... os error 10048` 表示 15000 被占用。本机该端口曾被深信服 `SangforSPVDI` 服务（`SangforPromoteService.exe`）占用。两种处理：

```powershell
# 方式一：换端口，不动第三方服务
$env:ADMIN_ADDR = "127.0.0.1:15050"

# 方式二：停占用方，会影响深信服 VDI 客户端功能
Stop-Service -Name SangforSPVDI -Force
```

确认占用者：

```powershell
$pid = (Get-NetTCPConnection -LocalPort 15000 -State Listen).OwningProcess
Get-Process -Id $pid | Select-Object Id,ProcessName,Path
```

停掉的服务重启电脑后会自动恢复，不会永久生效。

**已部署实例**

| 项 | 值 |
| :-- | :-- |
| 源码 | `D:\develop\project\AgentR\agentgateway` |
| 产物 | `target\release\agentgateway.exe`，108 MB |
| 日志 | `D:\agw-run.log` |
| 配置 | `C:\Users\Administrator\.config\agentgateway\config.yaml` |
| UI | 日常统一使用 http://127.0.0.1:4000/ui；15000 为额外管理入口 |

**升级重建**

```bash
git pull
cd ui && corepack pnpm build && cd ..
cargo build --release --features ui -j 6
```

重建后必须重启进程，旧二进制不会被替换。

# 拷贝到其他电脑

**结论**

可以直接用。exe 为单文件，UI 已内嵌，无外部资源依赖。已实测：复制到任意目录后启动成功，`/ui` 返回 200。

**前提**

| 条件 | 说明 |
| :-- | :-- |
| 64 位 Windows | 构建目标 `x86_64-pc-windows-msvc`；32 位与 ARM64 不可用 |
| VC++ 运行库 | 导入 `VCRUNTIME140.dll`，目标机需 VC++ 2015-2022 x64；纯净系统先装 `VC_redist.x64.exe` |

**其他行为**

- 首次运行在目标机生成独立配置与 SQLite 库，不继承来源机器数据。
- 目标机 15000 被占用时，同样用 `ADMIN_ADDR` 换端口。

*未验证：目标机缺少 VC 运行库时的具体报错。*



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

**启动后立刻退出**

看日志最后几行，常见两类：

- `os error 10048`：端口被占用，改 `ADMIN_ADDR` 或停占用方。
- 配置字段错误：用 `--validate-only` 校验：

```powershell
.\target\release\agentgateway.exe -f .\config.yaml --validate-only
```

**UI 打不开或 Playground 报 404**

- 本机默认配置的日常入口为 `http://127.0.0.1:4000/ui`。
- 用 `-f` 启动且配置无 `ui` 段时，UI 默认仅在本机管理入口 15000 提供。若要从 4000 使用 UI，请按前文配置挂载。
- 15000 的页面能打开但 Playground 返回 404 时，核对浏览器实际 Request URL；本次构建应从 `http://127.0.0.1:4000/ui/llm/playground` 发起业务请求。
- 配置模型并不等于调用成功；以实际收到上游有效回复为准。

**端口冲突**

默认占用 4000 与 15000，示例 MCP 占用 3000。启动前确认端口空闲：

```powershell
netstat -ano | Select-String ":4000|:15000"
```

15000 被占用时的处理见「本地启动与访问」。
