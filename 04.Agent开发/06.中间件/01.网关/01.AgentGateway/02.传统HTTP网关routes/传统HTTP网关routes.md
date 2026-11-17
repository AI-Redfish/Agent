> 适用范围：Windows 本地 Standalone 传统 HTTP 网关（`routes` / `tcpRoutes`）。使用时阅读本章；安装与编译见 ../01.快速上手/AgentGateway 快速上手.md；LLM 专用网关见 ../03.LLM网关/LLM网关使用.md。
> 依据：官方文档（来源页见文末）与本地实测。实测二进制：`E:\redfish\AgentGateway\agentgateway.exe`（commit `18f83707`，即 v1.7.0-132-g18f83707）。实测日期：2026-11-16。

# routes 在 agentgateway 中的定位

agentgateway 一个进程同时提供两类能力：

| 层 | 配置段 | 作用 |
| :-- | :-- | :-- |
| 传统网关底座 | `routes`、`tcpRoutes` | 按路径、方法、header 匹配请求，转发到任意 HTTP/TCP 后端 |
| AI 快捷层 | `llm`、`mcp`、`agent` | 按模型名/工具聚合声明式配置，自动获得协议转换与 AI 专属策略 |

AI 快捷层最终也走同一数据面。快捷层省配置；底座更灵活。需求超出"转发 LLM/MCP"时，用 `routes`。

*定位结论与官方 configuration-modes 页一致，并经本机实测确认。*

# 三层结构：gateways → listeners → routes

```text
客户端流量
  → gateways（端口入口；一个名字 + 一个端口）
    → listeners（可选；同一端口按 hostname 细分，各自可带 TLS）
      → routes / tcpRoutes / llm / mcp / ui（按名字挂到网关）
```

- 每个网关必须有 `port`。
- 网关不写 `listeners` 时，自带一个隐式 listener，服务所有 hostname。单机使用不需要配 listener。
- `routes`、`llm`、`mcp`、`ui` 都是**按名字挂到网关**。省略挂载目标时，附加到名为 `default` 的网关；整个配置没有 `gateways` 段时，系统隐式创建 default（LLM 4000、MCP 3000）。
- 一条 route 可以同时挂到多个网关（如同一 API 同时服务 HTTP 与 HTTPS 端口）。

`binds` 字段被 `gateways` 取代。`binds` 仍能用，已弃用。

# 定义网关

```yaml
gateways:
  default:
    bindAddress: 127.0.0.1   # 可选；省略则监听所有网卡
    port: 3000
    protocol: HTTP           # HTTP / HTTPS / TCP 等；HTTP 可省略
    tls:                     # HTTPS/mTLS 时使用
      cert: ./certs/cert.pem
      key: ./certs/key.pem   # mTLS 另加 root
```

| 字段 | 说明 |
| :-- | :-- |
| `bindAddress` | 监听的本地 IPv4/IPv6 地址；不接受主机名。只给自己用填 `127.0.0.1` |
| `port` | 监听端口，该网关所有 listener 共享 |
| `protocol` | 协议类型；决定该网关用 `routes` 还是 `tcpRoutes` |
| `tls` | 证书与密钥；高级项含 `cipherSuites`、`minTLSVersion` 等 |

本机多个 gateway 并存示例（公网/内网分离）：

```yaml
gateways:
  public:
    port: 8080
  internal:
    port: 8081
```

# 定义 HTTP 路由

```yaml
routes:
- name: local-backend
  gateways: [default]          # 省略则挂到 default
  hostnames:                   # 可选；按 Host 头匹配
  - "example.com"
  matches:
  - path:
      pathPrefix: /
  backends:
  - host: localhost:8000
    weight: 1
```

| 字段 | 说明 |
| :-- | :-- |
| `gateways` | 挂载目标，`<gateway-name>` 或 `<gateway-name>/<listener-name>`；省略挂 default |
| `name` | 可选名称 |
| `hostnames` | 可选 hostname 列表 |
| `matches` | 匹配规则：path、headers、method、query |
| `backends` | 后端列表 |
| `policies` | 可选策略（CORS、backendAuth 等） |

`backends` 不只支持 `host`。完整后端类型：静态 `host`、`ai:`（LLM provider）、`mcp:`（MCP 服务）。`host` 后端只能写在 `routes` 里；`ai` 与 `mcp` 后端的简写形式分别见 LLM 网关篇与 MCP 网关篇。

## matches 匹配规则

**path**：

```yaml
matches:
- path:
    pathPrefix: /api     # 前缀匹配；另有 exact 精确匹配
```

**method + headers 组合**（一条 match 内多条件是 AND）：

```yaml
matches:
- path:
    pathPrefix: /api
    method: POST
  headers:
  - name: Authorization
    value:
      exact: "Bearer abc123token"   # 精确匹配
  - name: Authorization
    value:
      regex: "^Bearer .*"           # 或正则匹配
```

同一 match 内的条件是 AND：请求必须全部满足（官方 matching 页明示，适用于 headers 与 query）。

*多条 `matches` 之间、query 参数匹配：官方未逐字定义语义，本篇未实测；配置前请核对 traffic-management/matching 页并自行验证。*

## 后端权重分流

```yaml
routes:
- name: api-v2
  backends:
  - host: api-v2.example.com:8080
    weight: 80
  - host: api-v1.example.com:8080
    weight: 20
```

# TCP 路由

TCP 网关（`protocol: TCP`）用 `tcpRoutes`。它没有 path/header/method 匹配，也没有 HTTP 策略，只按端口整体转发字节流。

```yaml
gateways:
  postgres-proxy:
    port: 5432
    protocol: TCP
tcpRoutes:
- name: postgres-backend
  gateways: [postgres-proxy]
  backends:
  - host: postgres.example.com:5432
    weight: 1
```

# 本机实测记录

**实验环境**：`E:\redfish\AgentGateway\agentgateway.exe`（commit `18f83707`）。注意《AgentGateway 快速上手》中记录的旧路径 `D:\develop\project\AgentR\agentgateway\target\release\agentgateway.exe` 已失效。

**实验配置**（`lab.yaml`，两个 python http.server 分别服务 dirA/dirB）：

```yaml
config:
  adminAddr: 127.0.0.1:15060
gateways:
  lab:
    bindAddress: 127.0.0.1
    port: 4100
    protocol: HTTP
  tcp-lab:
    bindAddress: 127.0.0.1
    port: 5100
    protocol: TCP
routes:
- name: api-v2
  gateways: [lab]
  matches:
  - path:
      pathPrefix: /v2
  backends:
  - host: 127.0.0.1:8000
    weight: 50
  - host: 127.0.0.1:8001
    weight: 50
- name: post-only
  gateways: [lab]
  matches:
  - path:
      pathPrefix: /post-only
    method: POST
  backends:
  - host: 127.0.0.1:8000
- name: header-route
  gateways: [lab]
  matches:
  - path:
      pathPrefix: /hdr
    headers:
    - name: x-team
      value:
        exact: red
  backends:
  - host: 127.0.0.1:8000
tcpRoutes:
- name: tcp-forward
  gateways: [tcp-lab]
  backends:
  - host: 127.0.0.1:8000
```

启动前先校验：`agentgateway.exe -f lab.yaml --validate-only` 输出 `Configuration is valid!`。

**验证矩阵与结果**：

| 验证项 | 命令 | 结果 | 结论 |
| :-- | :-- | :-- | :-- |
| 权重分流 | `curl http://127.0.0.1:4100/v2/data.txt` × 42 | 两个后端均命中，合计约 55:45（配置 50:50） | 分流生效；小样本波动大，不作为负载算法精确性证据 |
| method 匹配 | GET `/post-only` | 网关 404 | GET 不匹配仅 POST 的路由 |
| method 匹配 | POST `/post-only` | 上游返回 501（python http.server 不支持 POST） | 转发发生，POST 匹配成功 |
| header 匹配 | `/hdr` 不带 `x-team` | 网关 404 | 条件不满足，不转发 |
| header 匹配 | `/hdr` 带 `x-team: red` | 上游 404 File not found（`Server: SimpleHTTP` 头） | 匹配成功并转发；上游无该文件 |
| 路径转发形式 | 上游访问日志 | 收到 `GET /v2/data.txt` | **原始完整路径转发，不剥离前缀** |
| TCP 透传 | `curl http://127.0.0.1:5100/` | 返回 8000 的目录页 | TCP 路由可透传 HTTP；但无 L7 能力 |
| bindAddress | `netstat` | 4100/5100 仅监听 `127.0.0.1` | 绑定限制生效 |

# 区分网关拒绝与上游响应

排错第一步。同一状态码 404，来源不同：

| 响应特征 | 来源 | 含义 |
| :-- | :-- | :-- |
| `HTTP/1.1 404`，无 `Server` 头 | agentgateway 自己 | 没有任何 route 匹配该请求 |
| 上游状态行原样返回（含上游 `Server` 头） | 上游服务 | 路由匹配成功，404 来自后端 |

判断方法：`curl -i` 看响应头有无上游特征（如 `Server: SimpleHTTP`、nginx 等标识）。

# 已知坑

**1. pathPrefix 不剥离前缀**

匹配 `/v2` 后转发给上游的路径仍是 `/v2/...`。上游按完整路径处理。要剥离前缀需另配 rewrite（属流量治理章节，本篇不展开）。

**2. 本机第二个实例必须改三个端口**

默认端口：admin `15000`、stats `15020`、readiness `15021`。与已有实例并存时设置：

```powershell
$env:ADMIN_ADDR    = "127.0.0.1:15060"
$env:STATS_ADDR    = "127.0.0.1:15080"
$env:READINESS_ADDR = "127.0.0.1:15070"
```

只改 `ADMIN_ADDR` 不够；stats 或 readiness 冲突时进程启动失败，报 `os error 10048`，日志只有一行 `readiness server starts` 相关错误，容易误判为配置问题。三个变量名已对照源码 `config.rs`（commit `18f83707`）确认。

**3. YAML 顶层不支持 readinessAddr**

schema 中 `readinessAddr` 属于 RawConfig，CLI 的 `-f`/`-c` 入口都会拒绝该字段，只能用环境变量。

# 官方来源与版本

- Gateways：https://agentgateway.dev/docs/standalone/latest/documentation/configuration/gateways.md
- Routes：https://agentgateway.dev/docs/standalone/latest/documentation/configuration/routes.md
- Backends：https://agentgateway.dev/docs/standalone/latest/documentation/configuration/backends.md
- Request matching：https://agentgateway.dev/docs/standalone/latest/documentation/configuration/traffic-management/matching.md
- 配置模式（llm 与 routes 的关系）：https://agentgateway.dev/docs/standalone/latest/documentation/llm/configuration-modes.md
- schema：https://agentgateway.dev/schema/config（readinessAddr 字段）
- 端口默认值与环境变量：源码 crates/agentgateway/src/config.rs（commit `18f83707`），并经本机启动实测
- 抓取与实测日期：2026-11-16；latest 文档随版本变化，写作时需复核

# 验证范围与未验证项

**已实测**：路径前缀匹配、method 匹配、header 精确匹配、多后端权重分流、TCP 透传、bindAddress、`--validate-only`、第二实例三端口设置。

**未验证**：exact 路径匹配、regex header 匹配、query 匹配、多条 matches 之间的语义、hostnames、listeners、TLS、CORS 等策略、route 挂多个网关、负载均衡算法的精确分布。
