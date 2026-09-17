# Claude Code 缓存机制说明

Claude Code 的缓存机制核心目标是同时提升性能和降低成本：通过复用稳定的系统提示、工具定义和对话前缀，减少服务端重复计算的 Token 数量，从而显著降低首 Token 延迟（TTFT），并让命中的输入 Token 按更低价格计费。典型连续会话中，Prompt Cache 可以让大量历史上下文命中缓存，使交互响应更快、长会话成本更可控。

## 1. 缓存总体分层

Claude Code 的缓存可以理解为两层：

| 层级 | 名称 | 位置 | 主要作用 |
|---|---|---|---|
| L1 | 客户端内存缓存 | 本地 Claude Code 进程 | 避免本地重复读取、重复枚举工具和重复计算临时状态 |
| L2 | API Prompt Cache | Anthropic 服务端 | 复用请求前缀的 KV Cache，降低延迟和输入 Token 成本 |

其中，L2 API Prompt Cache 是 Claude Code 长上下文高性能体验的核心。

## 2. L1：客户端内存缓存（本地）

### 2.1 缓存内容

| 缓存项 | 说明 | 生命周期 |
|---|---|---|
| Tool 调用结果 | 例如 `read_file` 返回的文件内容 | 同一会话内 |
| MCP 工具列表 | MCP Server 注册的工具 Schema | 会话期间 |
| 文件系统快照 | 目录结构、Git 状态等 | 按需刷新 |
| 编译结果 | TypeScript、Go 等代码的临时编译产物 | 文件变更后失效 |

### 2.2 实现机制示例

```python
class ClientCache:
    def __init__(self):
        self.tool_results = {}      # {tool_call_id: result}
        self.file_contents = {}     # {file_path: (content, mtime)}
        self.mcp_tools = []         # 工具列表缓存

    def get_file(self, path):
        mtime = os.path.getmtime(path)
        if path in self.file_contents and self.file_contents[path][1] == mtime:
            return self.file_contents[path][0]
        content = self._read_file(path)
        self.file_contents[path] = (content, mtime)
        return content
```

L1 缓存主要优化本地交互体验，减少重复文件读取、工具列表加载和临时状态计算。

## 3. L2：API Prompt Cache（服务端）

### 3.1 什么是 Prompt Cache

Prompt Cache 是 Anthropic API 的服务端缓存能力。客户端可以在请求中标记可缓存内容，服务端会存储这些内容对应的 KV Cache。后续请求如果前缀完全匹配，就可以直接复用缓存，避免重复计算相同上下文。

### 3.2 Claude Code 会缓存哪些内容

Claude Code 通常会将稳定且重复出现的请求前缀标记为可缓存，例如：

```json
{
  "system": [
    {
      "type": "text",
      "text": "You are Claude Code, an expert programmer...",
      "cache_control": {"type": "ephemeral"}
    }
  ],
  "tools": [
    {
      "name": "read_file",
      "description": "...",
      "input_schema": {},
      "cache_control": {"type": "ephemeral"}
    },
    {
      "name": "write_file",
      "cache_control": {"type": "ephemeral"}
    }
  ],
  "messages": [
    {
      "role": "user",
      "content": "之前的对话历史...",
      "cache_control": {"type": "ephemeral"}
    },
    {
      "role": "user",
      "content": "最新问题"
    }
  ]
}
```

常见可缓存部分包括：

- 系统提示词
- 工具定义
- MCP 工具 Schema
- 稳定的对话历史前缀
- 部分项目上下文，例如 `CLAUDE.md`

最新一轮用户输入通常不是缓存命中的部分，因为它会随每次请求变化。

### 3.3 缓存匹配规则

Prompt Cache 的命中条件是：**新请求开头部分与历史请求开头部分完全一致**。

```text
请求 1: [System][Tools][历史消息1][历史消息2][新问题A]
请求 2: [System][Tools][历史消息1][历史消息2][新问题B]
        ↑ 完全相同的前缀 ↑                    ↑ 不同 ↑

结果：
- System、Tools、历史消息1、历史消息2 命中缓存
- 只需要计算新问题B及其后续内容
```

任何会改变请求前缀的内容，都可能导致缓存 miss。

### 3.4 缓存生命周期

| 阶段 | 时间 | 说明 |
|---|---|---|
| 创建 | 首次请求 | 服务端存储 KV Cache |
| 有效 | 约 5 分钟 | 有活动请求会续期 |
| 过期 | 无访问后约 5 分钟 | 服务端自动清理 |
| 失效 | 前缀变化 | 任意字节不同都可能导致缓存 miss |

### 3.5 缓存效果

| 指标 | 典型效果 |
|---|---|
| 缓存命中率 | 连续会话中常见 85% - 95% |
| 命中 Token 成本 | 约为正常输入 Token 的 10% |
| TTFT 降低 | 常见可降低 50% - 80% |

实际效果取决于会话连续性、上下文稳定性、工具定义变化、MCP 配置变化和是否触发压缩。

## 4. Claude Code 的优化策略

### 4.1 系统提示静态化

不利于缓存的设计：

```text
System: 当前时间 2024-06-03 10:30:25，你是 Claude Code...
```

更利于缓存的设计：

```text
System: 你是 Claude Code，一个 AI 编程助手。
工作流程：先理解需求 → 制定计划 → 执行 → 验证。
可用工具：read_file, write_file, bash, grep...
```

Claude Code 会尽量保持系统提示稳定，避免把频繁变化的内容放进可缓存前缀中，从而提升系统提示部分的命中率。

### 4.2 工具定义固化

工具定义越稳定，缓存命中越稳定。

```json
{
  "tools": [
    {"name": "read_file", "description": "读取文件", "input_schema": {}},
    {"name": "write_file", "description": "写入文件", "input_schema": {}},
    {"name": "bash", "description": "执行 shell 命令", "input_schema": {}}
  ]
}
```

工具定义如果频繁变化，例如新增 MCP 工具、移除 MCP 工具、修改工具 Schema，会改变请求前缀，导致原有缓存失效。

### 4.3 对话历史的分层缓存

Claude Code 采用类似“前缀冻结”的策略：

```text
第 1 轮:
[System][Tools][User: 分析这个项目]

第 2 轮:
[System][Tools][User: 分析这个项目][Assistant: 我分析了...][User: 写个测试]
 ↑ 历史前缀可命中缓存 ↑                              ↑ 新增部分不命中 ↑
```

核心原则是：历史前缀越稳定，后续请求越容易命中缓存。

### 4.4 Auto-Compaction 与缓存协调

当上下文接近阈值时，Claude Code 可能触发自动压缩：

```text
压缩前:
[System][Tools][历史1][历史2]...[历史N][新问题]

压缩后:
[System][Tools][摘要][新问题]
```

压缩会改变历史前缀，因此原有缓存通常会失效。压缩后的新摘要会形成新的缓存前缀，后续连续请求可重新命中。

常见优化策略包括：

- 不等上下文完全耗尽再压缩，保留缓冲空间
- 压缩后用新的摘要前缀重建缓存
- 摘要风格保持稳定，减少后续请求的前缀波动

### 4.5 多会话缓存隔离

不同 Claude Code 会话之间通常是独立上下文：

```text
工作空间 A（项目 X）
├── 会话 1 → 缓存 A1
├── 会话 2 → 缓存 A2
└── 会话 3 → 缓存 A3

工作空间 B（项目 Y）
└── 会话 4 → 缓存 B1
```

即使内容相似，不同会话也不应假设可以完全复用缓存。

### 4.6 SubAgent 的缓存隔离

Claude Code 中 SubAgent 通常是独立会话上下文：

```text
主会话
├── SubAgent A
├── SubAgent B
└── SubAgent C
```

SubAgent 不共享主会话的完整上下文缓存。它们适合隔离复杂搜索、审查或并行任务，但频繁使用 SubAgent 会产生额外上下文和缓存开销。

## 5. 缓存失效场景

| 场景 | 缓存影响 | 处理方式 |
|---|---|---|
| 新增 MCP 工具 | 工具定义变化，原缓存可能失效 | 下次请求重建缓存 |
| 修改 `CLAUDE.md` | 项目上下文变化，系统前缀可能变化 | 检测变更后重建缓存 |
| 切换 Git 分支 | `CLAUDE.md`、工具配置、本地状态可能变化 | 缓存前缀可能变化 |
| 超过约 5 分钟无活动 | 服务端缓存自然过期 | 下次请求重新创建缓存 |
| 手动 `/clear` | 清空对话历史，前缀变化 | 本地状态清空后重新开始 |
| 开启或关闭长上下文 | 请求格式和缓存键变化 | 需要重建缓存 |
| 修改 MCP Server 配置 | 工具列表或 Schema 变化 | 工具前缀缓存失效 |
| 大规模上下文压缩 | 历史前缀替换为摘要 | 原缓存失效，新摘要重建缓存 |

## 6. 如何查看缓存命中情况

### 6.1 Claude Code 内置命令

Claude Code 可通过以下命令查看上下文和用量概览：

```text
/context
/usage
/cost
```

这些命令可以帮助理解上下文占用、Token 使用和费用情况，但不一定直接展示完整的 Prompt Cache 命中明细。

### 6.2 使用 claude-tap 分析

可以使用 `claude-tap` 观察 Claude Code 发出的请求：

```bash
claude-tap --tap-live
```

在 Web 界面中重点关注：

- `cache_read_input_tokens`
- `cache_creation_input_tokens`

### 6.3 自己调用 Anthropic API 时查看

如果是直接调用 Anthropic API，响应的 `usage` 中通常会包含缓存相关字段：

```json
{
  "cache_creation_input_tokens": 12345,
  "cache_read_input_tokens": 67890
}
```

含义：

| 字段 | 含义 |
|---|---|
| `cache_creation_input_tokens` | 本次写入缓存的输入 Token |
| `cache_read_input_tokens` | 本次从缓存读取命中的输入 Token |

一般来说：

- `cache_read_input_tokens` 越高，说明命中越多
- `cache_creation_input_tokens` 越高，说明正在创建或刷新缓存
- 连续对话中，理想状态是 read 较高、creation 相对稳定

## 7. 最佳实践

| 实践 | 目的 |
|---|---|
| 保持 `CLAUDE.md` 稳定 | 避免项目上下文变化导致缓存失效 |
| 减少不必要的 MCP 工具 | 工具定义越少、越稳定，缓存前缀越稳定 |
| 尽量在同一会话内连续工作 | 最大化复用历史前缀缓存 |
| 避免频繁 `/clear` | 防止清空历史上下文和缓存前缀 |
| 控制 SubAgent 使用频率 | 避免产生额外独立会话缓存开销 |
| 避免频繁修改工具配置 | 保持工具 Schema 稳定 |
| 大文件读取使用 offset/limit | 减少无效上下文膨胀 |
| 长任务中保持适度交互频率 | 避免服务端缓存过期 |

## 8. 实用理解

可以把 Claude Code 缓存理解为：

```text
稳定前缀越长，缓存收益越大；
前缀变化越频繁，缓存收益越低。
```

因此，提升缓存命中率的关键不是“缓存所有内容”，而是让请求开头部分尽可能稳定：系统提示稳定、工具定义稳定、项目配置稳定、会话连续、少做无意义清空和重建。
