> 适用范围：Windows 本地 Standalone A2A 网关。使用时阅读本章；安装见 ../01.快速上手/AgentGateway 快速上手.md。
> 依据：官方文档（来源页见文末）与本地实测。实测二进制：`E:\redfish\AgentGateway\agentgateway.exe`（commit `18f83707`）。实测日期：2026-11-16。

# A2A 与 MCP 的分工

| 协议 | 解决的问题 |
| :-- | :-- |
| MCP | Agent 连接工具与数据源；取回上下文 |
| A2A（Agent-to-Agent） | Agent 之间的长时任务委托与状态管理 |

两者都是 JSON-RPC 协议。Agentgateway 对两者都提供安全、治理与可观测能力。

# A2A 网关的作用

把 A2A agent 挂到网关入口。客户端连网关，不直连 agent。网关对 A2A 流量做两件核心事：

1. **Agent Card 地址重写**：转发 `/.well-known/agent-card.json` 时，把卡片里的 agent 地址改写为网关自己的地址。客户端据此连回网关，不感知真实 agent 位置。
2. **A2A 协议处理与遥测**：标记为 A2A 的流量进入协议感知处理与监控。

# 配置：routes + a2a 标记

A2A 不是独立配置段，而是路由上的一个策略标记。新 `gateways` 格式写法（本机实测通过）：

```yaml
gateways:
  a2a-lab:
    bindAddress: 127.0.0.1
    port: 4300
routes:
- name: a2a-agent
  gateways: [a2a-lab]
  matches:
  - path:
      pathPrefix: /
  policies:
    a2a: {}          # 标记该路由流量为 A2A
  backends:
  - host: 127.0.0.1:9500
```

要点：

- `policies.a2a: {}` 是开关。不加时就是普通 HTTP 转发（无 card 重写）。
- 后端 `host` 指向真实 A2A agent 的地址端口。
- 官方 `agent/a2a` 页示例仍用已弃用的 `binds` 旧格式；`binds` 仍可用但应迁移到 `gateways`（对照 ../02.传统HTTP网关routes/传统HTTP网关routes.md）。

# 本机实测记录

**实验拓扑**：python 标准库写一个最小 A2A agent（监听 9500，返回 agent card 与 `message/send` JSON-RPC 回复），网关 4300 代理它。

```text
客户端 → 网关 4300（policies.a2a: {}）→ 最小 agent 127.0.0.1:9500
```

**验证矩阵与结果**：

| 验证项 | 命令/操作 | 结果 | 结论 |
| :-- | :-- | :-- | :-- |
| 配置校验 | `--validate-only` | Configuration is valid | 新格式 `policies.a2a` 被接受 |
| Agent Card 获取 | `GET http://127.0.0.1:4300/.well-known/agent-card.json` | `supportedInterfaces[0].url` = `http://127.0.0.1:4300/` | card 经网关且地址已重写 |
| 对照：无 `a2a` 标记 | 同请求打到无标记的 4400 实例 | url 保持 `http://127.0.0.1:9500/` | 重写由 `a2a: {}` 标记触发；无标记即纯透传 |
| JSON-RPC 转发 | POST `message/send` | 返回 agent 的 `pong from minimal a2a agent` | 请求转发与响应透传正常 |

# 接入 AWS Bedrock AgentCore（未实测）

`aws.agentCore` 后端可直连 Bedrock AgentCore runtime，不需要自建代理：

```yaml
routes:
- matches:
  - path:
      pathPrefix: /agentcore
  backends:
  - aws:
      agentCore:
        agentRuntimeArn: arn:aws:bedrock-agentcore:<region>:<account-id>:runtime/<runtime-id>
```

网关从 ARN 推导端点、替换请求路径为 `/runtimes/<arn>/invocations`、默认用 AWS 凭证链做 SigV4 签名。runtime 若配置了 JWT Inbound Auth，改用 `backendAuth.key` 策略带 Bearer token（SigV4 被替换）。ARN 的 service 元素必须是 `bedrock-agentcore`，否则加载配置时报错。

*本节为官方文档转述，无 AWS 环境，未实测。*

# 已知坑

**1. 忘加 `a2a: {}` 标记**

路由能通（纯 HTTP 转发），但 agent card 不重写：客户端拿到真实 agent 地址后绕过网关直连。表现为"能调通但客户端显示上游地址"。

**2. 官方示例是旧格式**

`agent/a2a` 页的 YAML 用 `binds`。照抄能跑，但与现有 `gateways` 配置混用时注意不要重复顶层键；迁移字段对照见官方 gateways 页 Migrate from binds 节。

# 官方来源与版本

- MCP 与 A2A 对比：https://agentgateway.dev/docs/standalone/latest/documentation/mcp/about.md
- A2A 代理：https://agentgateway.dev/docs/standalone/latest/documentation/agent/a2a.md
- AgentCore 后端：https://agentgateway.dev/docs/standalone/latest/documentation/agent/agentcore.md
- A2A 协议：https://github.com/a2aproject/A2A
- 抓取与实测日期：2026-11-16；二进制 commit `18f83707`

# 验证范围与未验证项

**已实测**：`policies.a2a` 新格式校验、card 获取与地址重写、有无标记对照、`message/send` JSON-RPC 转发。

**未验证**：真实 A2A SDK agent（官方 helloworld 样例）、流式任务（`message/stream`）、多 agent 多路由、agentcore 后端、A2A 遥测输出、长时任务状态管理。
