> 适用范围：Windows 本地 Standalone LLM Gateway。使用时阅读本章；安装与编译见 ../01.快速上手/AgentGateway 快速上手.md。
> 依据：官方文档与本地源码 commit `18f83707`（`v1.7.0-132-g18f83707`），不是纯 v1.7.0 标签。记录日期：2026-11-16。

# LLM Gateway 的作用

LLM Gateway 接收客户端请求，按模型名称选择上游，并处理支持的协议转换。它本身不提供模型推理，也不会自动获取上游账号权限。

```text
客户端 → Agentgateway → 上游模型服务
           /v1          OpenAI、Anthropic、自建兼容服务等
```

**三个名称**

| 名称 | 用途 | 示例 |
| :-- | :-- | :-- |
| 客户端模型名 | 客户端请求的 model，也是网关匹配规则 | chat-main |
| 上游模型名 | 网关发送给模型厂商的真实名称 | 填账号实际有权限的模型 ID |
| 显示名称 | UI 的可选标签，不参与请求匹配 | 主力对话模型 |

**两种密钥**

- 上游 API Key：用于网关访问模型厂商，配置在 Provider API key。
- 网关访问 Key：用于客户端访问网关；只有配置入站认证后，才需要使用对应的有效凭证。
- 两者不是同一概念。不要把上游密钥分发给所有客户端。



# 使用前准备

你需要上游服务的协议类型、Base URL、可用模型 ID，以及该服务要求的 API Key。不要把真实密钥写入学习笔记或提交 Git。

**启动现有程序**

在 PowerShell 中执行：

```powershell
cd D:\develop\project\AgentR\agentgateway
.\target\release\agentgateway.exe
```

如果已有 Agentgateway 运行，不要重复启动。先访问现有 UI。

- 模型管理：http://127.0.0.1:4000/ui/llm/models
- 调试页面：http://127.0.0.1:4000/ui/llm/playground
- 客户端 API Base URL：http://127.0.0.1:4000/v1

*以上地址适用于本机会话中生成的默认配置。端口以实际配置和启动日志为准。管理端口 15000 曾发生冲突，可在启动前设置 `$env:ADMIN_ADDR = "127.0.0.1:15050"`。*



# 4000 与 15000 入口的区别

**日常统一使用 4000**

在本机当前配置下，4000 与 15000 提供同一套管理 UI。15000 页面提供的 Provider、Model、网关及策略等管理操作，在 4000 页面也有对应入口；LLM Playground 应从 4000 页面使用。

这是同一进程的两个监听入口，不是两个独立实例。结论适用于本次源码构建 commit `18f83707` 及下方配置，不代表所有版本、鉴权策略和部署方式都相同。

| 项目 | 4000：default 业务网关 | 15000：admin 管理入口 |
| :-- | :-- | :-- |
| UI 页面 | 提供同一套管理 UI，推荐日常使用 | 提供本机管理 UI |
| 配置操作 | 在当前权限与可写配置来源下，可管理 Provider、Model、网关和策略 | 提供对应管理操作 |
| LLM Chat completions | 挂载了 LLM 业务路由，可转发模型请求 | 当前未提供该业务接口 |
| 本次 Playground 验证 | 浏览器实际请求成功，HTTP 200，收到 OK 回复 | 聊天请求误发管理端口，HTTP 404 |

**对应配置**

以下仅展示双入口的相关配置。合并到当前生效文件，不要用它覆盖整份配置。保留已有 `config.database`、`config.session`、`llm.providers`、`llm.models` 和 MCP 等内容，避免重复顶层键。

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

- `config.adminAddr`：管理监听地址；没有被环境变量覆盖时，上例使用本机 15000。
- `gateways.default.port`：名为 default 的业务网关监听 4000。
- `ui.gateways: default`：在 default 网关上提供管理 UI，不会因此关闭 admin 入口。
- `llm.gateways: default`：把 LLM 接口挂到同一个网关。
- 如果管理端口冲突，可用 `ADMIN_ADDR` 改到 15050；这不会把业务网关 4000 一起改掉。

**为什么从 15000 打开 Playground 会 404**

本次构建在 UI 与 LLM 挂到同一网关时，Playground 采用页面同源地址发送请求。代码依据为 `ui/src/gatewayUrls.ts` 和 `ui/src/api/playgroundApi.ts`。

```text
打开 15000/ui → 聊天 POST 15000/v1/chat/completions → 404
打开 4000/ui  → 聊天 POST 4000/v1/chat/completions  → LLM 路由 → 上游
```

管理端口能返回 UI HTML，不代表它也提供业务接口。因此，不能仅凭两个 UI 首页都返回 200，判断两个入口的 Playground 都能使用。

本次 404 由请求端口引起，不需要重新注册 Provider 或 Model。其他情况下的 404 仍需核对实际 Request URL、模型匹配与上游路径，不能一概归因于端口。

**推荐访问地址**

```text
管理页面：http://127.0.0.1:4000/ui
模型管理：http://127.0.0.1:4000/ui/llm/models
模型调试：http://127.0.0.1:4000/ui/llm/playground
客户端 Base URL：http://127.0.0.1:4000/v1
```

不访问 15000 即可，无须为统一日常入口而专门关闭管理监听。不要从旧的 15000 标签继续进入 Playground；直接新开 4000 的调试页面。

*安全边界：4000 挂载管理 UI 后，它不只是模型 API 入口。不要把未鉴权的 4000 直接对外暴露；共享前需分别规划管理权限、业务认证与网络访问范围。*


# 通过 UI 接入第一个模型

推荐先完成这条路径：添加模型 → Playground 对话 → 外部客户端调用。无需手工修改 YAML。

**打开模型管理**

进入左侧 **LLM → Models**，点击 **Add model**。首次使用时，可能需要先在欢迎页面启用 **Enable LLM**。

**填写字段**

| 界面字段 | 如何填写 |
| :-- | :-- |
| Incoming model match | 填 chat-main，作为客户端使用的模型名 |
| Display name | 可选，只影响显示 |
| Provider | 官方厂商选择对应名称；其他 OpenAI 兼容服务可选择 Custom |
| Provider API key | 按上游要求配置；优先使用 Env var 引用进程已有环境变量 |
| Base URL | 自定义服务填写其 API 基础路径，通常含 /v1，不含 /chat/completions |
| Outgoing model | 选择 Explicit，再填上游真实模型 ID；不要把 chat-main 当成厂商模型 ID |

若选择 **Custom**，在支持的协议格式中启用 **Chat completions**。只有上游实际支持时，才启用其他格式。

**理解 Outgoing model**

- **Incoming model**：直接沿用客户端传入的模型名。
- **Explicit**：使用指定的上游模型名，适合 chat-main 这样的别名。
- **Strip prefix**：用于 openai/* 这样的匹配规则，转发前移除前缀。
- **Custom**：通过 CEL 表达式改写模型名。

**保存配置**

点击 **Save model**。当前使用可写文件配置时，UI 会保存到当前配置来源，改动随后应用；不必为增加模型重启服务。

本机默认配置通常在 `$HOME\.config\agentgateway\config.yaml`。如果用 `-f` 启动，则以指定文件为准。不要同时在 UI 和编辑器保存，避免相互覆盖。

**在 Playground 验证**

进入 **LLM Playground**，选择新模型，输入简单问题，点击 **Send**。收到有效助手回复才算这次真实模型调用成功。

仅能保存模型或在 /v1/models 看到模型，不能证明上游密钥、网络和权限有效。



# 配置环境变量密钥

在启动 Agentgateway 的同一个 PowerShell 窗口设置变量，然后启动。UI 的 **Env var** 中填写变量名，例如 LLM_API_KEY，不加美元符号。

```powershell
$secret = Read-Host "输入上游 API Key" -AsSecureString
$env:LLM_API_KEY = [System.Net.NetworkCredential]::new("", $secret).Password
.\target\release\agentgateway.exe
```

这可避免将真实密钥作为命令字面量写进终端历史；密钥仍会以明文存在于进程环境，不能当作专用密钥库。

**已启动进程的限制**

- 在新窗口设置环境变量，不会更新已经运行的 Agentgateway 进程。
- YAML 热加载也不会自动获得另一个终端的新环境变量。
- 需要使用新变量时，先停止对应实例，再从已设置变量的终端重新启动。
- UI 中直接填写密钥可能将其写入配置文件；不要分享该文件的原始内容。



# 通过配置文件接入

UI 与 YAML 是配置同一功能的两种入口，不要求两者各配置一次。

**OpenAI 官方服务**

以下是配置片段。合并到已有 llm 段，不要重复创建同名顶层键；保留已有数据库、会话、MCP 和 UI 设置。将 upstream-model-id 替换为账号可用的真实模型 ID。

```yaml
llm:
  gateways: default
  models:
  - name: chat-main
    provider: openAI
    params:
      model: upstream-model-id
      apiKey: $LLM_API_KEY
```

**自建或第三方 OpenAI 兼容服务**

将下例中的 upstream.example.com 与模型 ID 替换为实际值。Base URL 应遵循上游文档，不是所有服务都采用 /v1。

```yaml
llm:
  gateways: default
  models:
  - name: chat-main
    provider:
      custom:
        formats:
        - type: completions
    params:
      model: upstream-model-id
      baseUrl: https://upstream.example.com/v1
      apiKey: $LLM_API_KEY
```

**Base URL 路径拼接**

| params.baseUrl | Chat completions 的上游路径 |
| :-- | :-- |
| https://upstream.example.com/v1 | /v1/chat/completions |
| http://127.0.0.1:18080 | /chat/completions |
| https://upstream.example.com/v1/chat/completions | 不要这样填写，会与端点路径重复 |

不使用上游认证的本地服务，可省略 apiKey；不要因此省略网关本身的访问控制评估。

**独立配置文件的最小结构**

如果不沿用已有配置，先建立以下基础结构，再合并前面的 llm 段：

```yaml
gateways:
  default:
    port: 4000
ui:
  gateways: default
```

使用 `agentgateway.exe -f 配置路径` 启动。自带配置不自动添加数据库；没有配置数据库时，不应预期 Analytics 与 Logs 的持久化功能完整可用。新配置使用 gateways，不再优先使用已弃用的 llm.port。

**校验配置**

```powershell
.\target\release\agentgateway.exe -f "配置文件完整路径" --validate-only
```

配置校验不等于真实模型调用成功；仍需发送对话请求。



# 外部客户端如何使用

OpenAI 兼容客户端填写：

```text
Base URL: http://127.0.0.1:4000/v1
Model: chat-main
API Key: 配置了网关认证时填写有效网关凭证
```

网关未启用入站认证、且已单独配置上游凭证时，通常不需要调用方提供上游 Key。部分 SDK 要求 API Key 字段非空，此时可填占位值；不要据此误认为网关已受保护。

**PowerShell 列出模型**

```powershell
$base = "http://127.0.0.1:4000/v1"
Invoke-RestMethod -Uri "$base/models"
```

**PowerShell 发起对话**

```powershell
$body = @{
    model = "chat-main"
    messages = @(
        @{ role = "user"; content = "Reply with one short greeting." }
    )
    stream = $false
} | ConvertTo-Json -Depth 10

$response = Invoke-RestMethod -Uri "$base/chat/completions" `
    -Method Post -ContentType "application/json; charset=utf-8" `
    -Body ([System.Text.Encoding]::UTF8.GetBytes($body))
$response.choices[0].message.content
```

若启用了网关 Bearer 认证，给请求额外传入 `-Headers @{ Authorization = "Bearer $env:GATEWAY_API_KEY" }`。不要把上游 Key 与网关 Key 混用。

**流式输出**

在 PowerShell 中使用 curl.exe，避免 Windows PowerShell 把 curl 解释成别名：

```powershell
$streamBody = @{
    model = "chat-main"
    messages = @(@{ role = "user"; content = "Say hello." })
    stream = $true
} | ConvertTo-Json -Depth 10 -Compress
$streamBody | curl.exe -N "$base/chat/completions" `
    -H "Content-Type: application/json" --data-binary "@-"
```

以上流式示例要求上游支持流式 Chat completions；它不适用于不支持该格式的模型。



# Pi 与其他 Agent 接入

Agent 接入网关，而不是再直连上游 Provider。Agent 使用网关的模型匹配名与访问 Key；上游密钥由网关保管。

**Pi 配置**

Pi 的默认用户配置文件为 `$HOME/.pi/agent/models.json`；如果设置了自定义 Agent 目录，以实际目录为准。Windows 常见路径为 `C:\Users\<用户>\.pi\agent\models.json`。

在已有 `providers` 对象内增加 `agentgateway`，保留其他 Provider。下面展示完整 JSON 结构，合并时不要覆盖原文件。

```json
{
  "providers": {
    "agentgateway": {
      "baseUrl": "http://127.0.0.1:4000/v1",
      "api": "openai-completions",
      "apiKey": "$AGENTGATEWAY_API_KEY",
      "models": [
        {
          "id": "sinomis/gpt-6.1-sol",
          "name": "Agentgateway 本地网关"
        }
      ]
    }
  }
}
```

- `api` 使用已验证网关端点所对应的 Chat completions 协议，不要直接改为 Responses。
- `id` 对应网关 **Incoming model match**，不是显示名称，也不是上游真实模型名。上例保留 `sinomis/` 前缀；换模型时以自己的网关配置为准。
- `$AGENTGATEWAY_API_KEY` 是 Pi 读取的环境变量引用，值应为有效网关 Key，不是上游 Provider Key。
- 只有网关未启用入站认证时，才可用 `local-placeholder` 等非空占位值满足客户端要求。占位值不是安全控制，Strict 模式下会被拒绝。

**在 Pi 中选择**

先让启动 Pi 的进程具备 `AGENTGATEWAY_API_KEY` 环境变量。保存 models.json 后，在 Pi 输入 `/model`，选择 agentgateway 下的模型。当前安装版本的 Pi 会在打开模型选择器时重新加载该文件。

先测试简单对话，再测试流式响应与工具调用。Playground 返回普通对话成功，不代表 Pi 的完整 Agent 工具循环已通过验证。

**其他 Agent 的通用参数**

| 参数 | 本机 Agent | 局域网其他电脑的 Agent |
| :-- | :-- | :-- |
| 协议 | OpenAI-compatible Chat completions | 同左 |
| Base URL | http://127.0.0.1:4000/v1 | 使用网关主机的局域网地址及已安全开放的业务端口 |
| Model | 网关的 Incoming model match | 同左 |
| API Key | 开启认证后填写有效网关 Key | 每位使用者独立的有效网关 Key |

其他电脑的 `127.0.0.1` 指向它自己，不能用来访问你的主机。若 Agent 在容器或远程环境中，地址也要按实际网络关系调整。

*Pi 依据：本机安装包 docs/models.md、docs/models-configuration.md。配置格式已核对；本会话未修改 Pi 用户配置，也未完成 Pi 对话与工具调用的端到端测试。*



# 局域网共享与管理隔离

**没有额外配置时，其他人能不能调用**

如果业务网关监听局域网可达地址，防火墙与网络允许连接，且没有有效入站认证或其他阻断策略，其他人可以通过网关使用已配置模型。对方不需要知道上游密钥，调用可能消耗你的上游额度。

本会话检查时，4000 监听 `0.0.0.0`，未带 Key 的模型列表请求返回 200，且当时未配置 LLM Key 认证。这是检查当时的状态，不代表后续配置仍相同；尚未从另一台电脑验证可达性。

`0.0.0.0` 是监听所有 IPv4 网卡，不是客户端填写的目标地址。客户端应填主机实际局域网 IP 或域名。

**只给自己用**

把业务网关绑定到回环地址。以下为配置片段，合并进现有 default 网关，不要覆盖原有模型、策略、数据库和其他网关。

```yaml
gateways:
  default:
    bindAddress: 127.0.0.1
    port: 4000
```

管理入口也应保持回环监听，例如 `config.adminAddr: 127.0.0.1:15000`。修改监听后需核对进程日志与实际监听结果，不能只看 UI 保存成功。

**需要给部分同事用**

- 本机管理入口只监听回环地址；共享业务入口不挂载管理 UI 或不需要的 MCP 路由。
- 可保留本机 4000，再规划独立共享业务端口，例如 4100。端口号只是示意，需配置相应网关与 LLM 挂载。
- 共享入口启用 Strict 认证，每人一个独立网关 Key，并限制允许使用的模型。
- Windows 防火墙仅放行指定来源 IP 或可信网段，检查 IPv4、IPv6 与其他网络入口；不要关闭整个防火墙。
- 共享入口使用受客户端信任的 HTTPS，避免在网络中明文传输 Bearer Key。
- 配合限流、预算与审计，Key 泄漏时可单独撤销。预算依赖相应的用量、成本上报与配置，不能把它当作绝对不会超支的保证。

**保护模型，不等于保护管理 UI**

`llm.policies.apiKey` 保护的是它覆盖的 LLM 请求，不会自动保护所有 UI 和管理 API。只设置模型 Key，却把可修改配置的页面开放给局域网，仍存在权限被修改的风险。

前文“日常统一使用 4000”仅适用于本机操作。当前配置中 4000 同时提供管理 UI，不应原样作为未隔离的局域网共享入口。需要远程管理时，应额外配置管理认证与权限。

*本节为配置建议，不表示已经修改监听、开启鉴权、分离入口或放行防火墙。*



# 网关 API Key 的三种校验模式

这里校验的是 Agent 或客户端访问网关时携带的 **网关 Key**，不是上游 Provider Key。默认读取 `Authorization: Bearer <网关Key>`；如果修改过读取位置，以实际配置为准。

| Validation mode | 不带 Key | Key 无效 | Key 有效 | 作用 |
| :-- | :-- | :-- | :-- | :-- |
| Strict（严格） | 拒绝 | 拒绝 | 此校验层通过 | 必须持有有效网关 Key |
| Optional（可选，默认） | 此校验层放行 | 拒绝 | 此校验层通过 | 有 Key 才检查，允许匿名请求 |
| Permissive（宽松） | 此校验层放行 | 此校验层放行 | 识别有效身份，供后续策略使用 | 不能单独阻止未授权调用 |

表格只描述 API Key 认证层。模型访问权限、授权、限流和预算等其他策略仍可能拒绝请求。

**Permissive 不带 Key 或带错 Key，能否拿到模型回复**

可以，但不是保证成功。只要其他策略没有拒绝、模型路由匹配、网关配置的上游密钥有效且上游服务正常，请求就可能获得 LLM 回复，并消耗网关持有的上游额度。

Permissive 的含义是“有有效 Key 就识别身份”，不是“有效 Key 才能用”。Optional 也不是强制认证：完全不带 Key 仍可能调用成功。

**避免所有人都能用：选 Strict**

进入本机 `http://127.0.0.1:4000/ui/llm/keys`，在 **LLM → Virtual API Keys** 中配置：

1. 点击 **Enable API key auth**；已有策略时打开 **Settings**。
2. 将 **Validation mode** 设为 **Strict** 并保存。
3. 点击 **New key**，为每个使用者生成独立 Key，妥善保存；Strict 已开启但尚无可用 Key 时，模型调用会被拒绝。
4. 在 **Model access → Selected models** 中选择允许的模型，规则匹配的是客户端请求的模型名。
5. 把客户端占位 Key 换成对应的有效网关 Key；Playground 也要选择有效 Key。
6. 分别验证无 Key、错误 Key、有效 Key 三种请求，并单独确认管理页面已隔离或受保护。

本地 schema 中，`allowedModels` 不填写表示没有这一层额外模型限制；空数组表示拒绝所有模型；填写列表则限制客户端可请求的模型。它不代表对上游内部嵌套调用做全面权限约束。

**客户端携带 Key**

```powershell
$headers = @{ Authorization = "Bearer $env:AGENTGATEWAY_API_KEY" }
Invoke-RestMethod -Uri "http://127.0.0.1:4000/v1/models" -Headers $headers
```

上例用于检查带 Key 的模型列表访问；仍需发送实际对话验证允许的模型可以调用。预期 Strict 下无 Key 与无效 Key 被认证层拒绝，有效 Key 才继续后续处理。

**密钥与验证边界**

- 不把真实上游 Key、网关 Key 或包含凭据的配置截图写进笔记。截图已泄露真实密钥时，应撤销并重新生成。
- 文档中的占位 Key 不能直接用作生产共享密钥。
- 三种模式含义已依据本地 schema 与 Keys 页面源码核对；本次仅记录规则，不宣称已在当前实例切换并实测全部模式。


# 虚拟 Key 的属性

在 `http://127.0.0.1:4000/ui/llm/keys` 点击 **New key** 时，弹窗 **Create virtual key** 提供四个可选项。它们只作用于这一个 Key，不影响其他 Key。

| 属性 | 作用 |
| :-- | :-- |
| Store raw key | 勾选后保存 Key 原文，可在 UI 再次查看；不勾选只保存 SHA-256 哈希，保存后不再显示原文 |
| Budgets（预算） | 限制这个 Key 能花费的金额或消耗的 token，可按滚动窗口或累计总量控制 |
| Model access（模型权限） | 限制这个 Key 能请求的模型名；默认 Unrestricted 不限制 |
| Metadata（元数据） | 给使用这个 Key 的请求附加自定义标记，便于日志与审计区分调用者 |

**Store raw key**

对应配置里的 `key`（原文）与 `keyHash`（`sha256:<hex>` 格式）两种存储方式。哈希方式更安全：配置文件或 UI 泄露时拿不到 Key 原文。

代价是保存后无法再次查看。Key 需在创建时立即复制保管；丢失只能作废重建。

**Budgets**

按 Key 独立计算，在 LLM 响应后扣减。预算依赖上游返回用量与成本数据；上游不上报时，对应请求不会被计费，预算也不能保证绝对不超支。

给外部使用者分配 Key 时建议设置预算，防止单人耗尽上游额度。

**Model access**

三种取值：

- **Unrestricted**：不限制，可请求网关上任何模型。
- **Selected models**：只允许匹配所填模式的模型，如 `sinomis/gpt-6.1-sol`。
- **Deny all**：拒绝所有模型。

匹配依据是客户端请求的顶层 model 名，即网关的 Incoming model match。它不约束上游服务内部嵌套的模型调用。

**Metadata**

键值对形式，附着在通过该 Key 认证的请求上，用于日志、审计或按团队区分用量。不参与权限判断。

**给同事发 Key 的推荐组合**

1. Store raw key 不勾选，创建时立即复制交付。
2. Model access 选 Selected models，只放行业务需要的模型。
3. Budgets 设置金额或 token 上限。
4. Metadata 填使用者或团队名。

*本节依据 UI 弹窗与 schema 中 LocalAPIKey 字段核对；尚未实际创建 Key 并验证预算扣减行为。*


# 多模型与统一别名

多个 llm.models 项可以使用不同厂商；客户端通过 model 字段选择，不需要切换网关地址。

**通配名去前缀**

以下片段合并到 llm.models 列表中：

```yaml
- name: anthropic/*
  provider: anthropic
  params:
    apiKey: $ANTHROPIC_API_KEY
  transformation:
    model: llmRequest.model.stripPrefix("anthropic/")
```

客户端请求 anthropic/<真实模型ID>，网关移除 anthropic/ 前缀后转发。不要把这个通配项和精确模型别名混淆。

**虚拟模型**

虚拟模型在已有模型配置之上选择后端。下面的统一入口 smart 指向已经配置的 chat-main；这是路由示例，不代表已接入两个故障转移后端。

```yaml
llm:
  gateways: default
  models:
  - name: chat-main
    provider: openAI
    params:
      model: upstream-model-id
      apiKey: $LLM_API_KEY
  virtualModels:
  - name: smart
    routing:
      weighted:
        targets:
        - model: chat-main
          weight: 1
```

客户端改用 model=smart。多后端权重、故障转移与条件路由属于后续进阶配置；不要仅添加多个模型就认为自动启用了它们。



# 常见问题

| 现象 | 核查内容 |
| :-- | :-- |
| 模型列表为空 | 检查当前实例是否配置 llm.models，以及路由挂载的网关是否正确 |
| 列表有模型但对话失败 | 列表可由本地配置或目录生成，不代表上游连接可用 |
| 模型不匹配 | 客户端 model 应匹配 Incoming model match，不是显示名称 |
| 上游提示模型不存在 | 核对 Outgoing model、账号权限、服务商模型 ID |
| 401 / 403 | 可能来自网关，也可能来自上游；分别核对入站与上游凭据 |
| Playground 404，页面在 15000 | 本次构建可能把业务请求发到管理端口；改从 4000/ui/llm/playground 打开，并核对 Request URL |
| 其他 404 | 可能是模型不匹配、访问端口错误或 Base URL 路径错误；结合响应与日志判断 |
| 503 / connection timed out | 检查上游地址、DNS、网络、TLS 和出口代理；不能算调用成功 |
| 新设环境变量不生效 | 重新从设置变量的终端启动对应进程 |
| UI 保存失败 | 检查当前配置来源是否可写，不要假定所有部署模式都写本地文件 |
| 分析或日志页面无数据 | 检查数据库、请求日志及相关功能配置 |

**查看本机日志**

以下路径仅适用于此前按快速上手方案重定向日志的后台实例：

```powershell
Get-Content D:\agw-run.log -Tail 50
Get-Content D:\agw-run.err.log -Tail 30
```

*日志可能包含请求内容或敏感信息，分享前先脱敏。不要仅凭状态码断言唯一故障原因。*



# 验证范围与安全边界

**本会话已有验证**

- 本章四组模型配置示例（OpenAI、Custom、通配去前缀、虚拟模型）补齐基础网关后，均通过本地二进制的 --validate-only 校验；校验使用占位密钥，不发起真实模型调用。
- 模型注册测试：GET /v1/models 返回配置的模型名。这只验证模型暴露，不验证上游成功。
- 公网假密钥测试：请求返回 503 connection timed out。没有完成真实厂商调用，不作为成功证据。
- 本地 Mock 测试：代理请求返回 200 和 pong from mock；Mock 收到 /chat/completions，且出站 model 为 llama3。
- Mock 测试同时覆盖了直接模型 local-llama 与虚拟别名 smart；仅证明本地路由与模型名映射。
- 真实上游调用：本会话使用浏览器从 4000/ui/llm/playground 选择本机已配置模型，实际 POST 到 4000/v1/chat/completions，返回 HTTP 200 和 OK 回复；未改动 Provider 或 Model。
- 管理入口对照：15000 的 UI 页面可加载，但相同业务路径 POST 15000/v1/chat/completions 返回 404。结论限于本次构建与配置。
- 此前同一业务入口还曾返回上游 502，之后调用成功；未确定其短暂失败原因，不能将所有失败都归因于端口。
- 真实扣费核对、流式输出及 UI 保存的完整浏览器交互，尚未全部实测。

**最小成功标准**

模型出现在列表，并通过 Playground 或客户端收到真实上游的有效回复。

**本地与共享使用**

- 只在本机测试时，优先使用回环地址；用 netstat 检查监听范围，不要把默认网关假定为仅本机可达。
- 共享前配置身份认证、HTTPS、限流与预算；不要直接暴露未认证端口。
- 只共享业务接口，不直接公开管理 UI、原始配置或上游密钥。
- 环境变量不等于加密存储。不要把包含真实密钥的配置提交到笔记仓库。



# 官方来源与版本

官网 latest 会变化；本章字段以本地 commit 18f83707 为核对基准。示例模型 ID 是占位内容，必须替换。

- LLM 快速上手：https://agentgateway.dev/docs/standalone/latest/documentation/quickstart/llm/
- 自定义 Provider：https://agentgateway.dev/docs/standalone/latest/integrations/llm/providers/custom/
- 虚拟模型：https://agentgateway.dev/docs/standalone/latest/documentation/llm/virtual-models/
- 配置更新：https://agentgateway.dev/docs/standalone/latest/documentation/setup/update/
- UI 入口说明：https://agentgateway.dev/docs/standalone/latest/documentation/setup/ui/launch-ui/
- 源码：https://github.com/agentgateway/agentgateway/tree/18f83707118b3e2df500cc63299486958a0e86f5
- 本地界面依据：ui/src/pages/Models.tsx、ui/src/pages/models/ProviderConfigEditor.tsx、ui/src/main.tsx。
- Playground 请求地址依据：ui/src/gatewayUrls.ts、ui/src/api/playgroundApi.ts；结合本会话 HTTP 与浏览器实测。
- 配置字段依据：schema/config.json 中 LocalLLMConfig、LocalLLMModels、LocalLLMParams、LocalLLMVirtualModel。
- Key 校验与模型权限依据：schema/config.json 中 APIKeyMode、LocalAPIKeys、LocalAPIKey，以及 ui/src/pages/Keys.tsx。
- 监听范围依据：schema/config.json 中 LocalGateway.bindAddress。
- Pi 配置依据：本机安装包 docs/models.md、docs/models-configuration.md。
- 官方 Key 认证：https://agentgateway.dev/docs/standalone/latest/documentation/configuration/security/apikey-authn/
- 官方 Virtual API Keys：https://agentgateway.dev/docs/standalone/latest/documentation/llm/cost-controls/virtual-keys/
- 官方预算限制：https://agentgateway.dev/docs/standalone/latest/documentation/llm/cost-controls/budget-limits/
- 官方管理 UI 保护：https://agentgateway.dev/docs/standalone/latest/documentation/setup/ui/secure-ui/
