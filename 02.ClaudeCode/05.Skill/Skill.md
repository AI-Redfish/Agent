# 概述

Skills 是更高级的复合工作流。当 Claude 判断某个任务适合某个 skill 时，会自动读取并执行对应的 SKILL.md，无需手动调用。

每个 skill 是一个子目录，目录内包含 `SKILL.md`。



**目录位置**

```
.claude/skills
```



**案例**

skills/security-review/SKILL.md

```
# Security Review Skill

## 触发条件
当用户请求代码审查、代码涉及认证/授权/加密/用户输入处理时自动触发。

## 执行步骤
1. 扫描 SQL 注入风险（检查所有数据库查询）
2. 检查 XSS 防护（验证输出转义）
3. 审计权限边界（确认最小权限原则）
4. 检查敏感数据处理（日志、错误信息中是否泄露）
5. 输出 OWASP Top 10 对照检查表

## 输出格式
按 CVSS 评分排列，高危问题优先展示。
```



**Skills vs Commands 的区别**

> - **Commands** 需要用户主动输入斜杠命令触发，是"工具箱"
> - **Skills** 由 Claude 根据上下文自动判断是否调用，是"智能本能"





# 官方插件

## skill-creator

skill-creator 的作用，简单说就是：帮你把“一个常做的工作流”沉淀成可复用的 skill

核心价值是把“会话里的经验”变成“以后能直接调用的能力”。

也可以对现有skill进行优化。

 

**安装**

  - 在 Claude Code 里输入 /plugin
  - 搜索 skill-creator
  - 按提示安装/启用



**使用**

- “帮我创建一个用于总结 PR 评论的 skill”
- 帮我做一个 prd-review skill，输入是产品PRD，输出要包含缺失项、歧义点、边界场景、风险、追问清单
- “把刚才这个排查流程整理成一个 skill”
- “测试并改进我现有的 skill”

 
# skill状态
claude code可以设置各个skill的状态。
```
/skills
```
通过如上命令列出所有安装的skill，移动到指定的skill，按空格键切换skill的状态。

- on：启动。
- name-only：每次对话仅加载这个skill的name，不会携带description。
- user-only：只有用户手动触发，明确声明使用这个skill，这个skill才会被触发。
- off。关闭这个skill。


# Claude Code 中怎么使用 Skill

## 1. Skill 是什么

在 Claude Code 里，**Skill 可以理解为一组可复用的“能力模板 / 命令能力”**。

当用户输入某些特定请求，或者直接使用斜杠命令（例如 `/commit`、`/review-pr`），Claude Code 会通过 `Skill` 机制去调用对应能力，帮助完成特定类型的任务。

可以把它理解成：

- 普通对话：直接按自然语言处理
- Skill：针对某类任务的专用工作流

---

## 2. Skill 的典型触发方式

### 方式一：用户直接输入斜杠命令

这是最直观的方式。

例如：

```bash
/commit
/review-pr 123
```

这类命令本质上会触发对应的 Skill。

在代理内部，调用形式类似：

```json
{
  "skill": "commit",
  "args": "-m 'Fix bug'"
}
```

也就是说：

- `skill`：Skill 名称
- `args`：传给 Skill 的额外参数（可选）

---

### 方式二：用户提出与某个 Skill 明确匹配的需求

即使用户没有显式输入 `/xxx`，只要需求明显对应某个 Skill，也应该调用它。

例如：

- “帮我配置 Claude Code 的 settings.json” → 适合 `update-config`
- “每 5 分钟检查一次部署状态” → 适合 `loop`
- “帮我用 Claude API 写个示例” → 适合 `claude-api`

这种情况下，Claude 不应只口头提到 Skill，而是要**真的调用 Skill 工具**。

---

## 3. 什么时候必须用 Skill

当满足以下任一情况时，应优先使用 Skill：

- 用户显式提到某个 slash command
- 用户请求的任务和现有 Skill 明确匹配
- 系统已经说明“这是阻塞性要求（BLOCKING REQUIREMENT）”

也就是说：

> 如果有合适的 Skill，就要先调用 Skill，而不是跳过它直接自己发挥。

---

## 4. Skill 的基本调用格式

调用结构很简单：

```json
{
  "skill": "skill-name",
  "args": "optional arguments"
}
```

示例：

### 调用一个简单 Skill

```json
{
  "skill": "pdf"
}
```

### 带参数调用

```json
{
  "skill": "commit",
  "args": "-m 'Fix login bug'"
}
```

### 使用带命名空间的 Skill

```json
{
  "skill": "ms-office-suite:pdf"
}
```

说明：

- `args` 是可选的
- Skill 名称必须来自**当前环境已提供的可用 Skill 列表**
- 不能凭空猜一个 Skill 名称

---

## 5. 当前上下文里可用的 Skill

根据当前系统提示，这里可用的 Skill 有：

### `update-config`

用于配置 Claude Code 的 `settings.json` / `settings.local.json`。

适用场景：

- 调整权限
- 配置 hook
- 设置环境变量
- 修改自动化行为
- 排查 settings / hook 问题

示例需求：

- “允许 npm 命令”
- “设置 DEBUG=true”
- “每次 Claude 停止后执行某个动作”

---

### `simplify`

用于检查**已变更代码**是否还能进一步复用、简化、提质、提效，并修复发现的问题。

适用场景：

- 代码改完后再做一轮简化审查
- 降低重复逻辑
- 提升代码整洁度

注意：

- 它更像是“针对现有改动做优化审视”
- 不是通用问答 Skill

---

### `loop`

用于**按间隔重复执行某个 prompt 或 slash command**。

适用场景：

- “每 5 分钟检查一次部署状态”
- “持续轮询某项任务”
- “定时运行某个工作流”

注意：

- 适用于**循环 / 周期性**任务
- **不适用于一次性任务**

---

### `claude-api`

用于构建基于 **Claude API / Anthropic SDK / Agent SDK** 的应用。

适用场景：

- 用户明确提到 Claude API
- 代码里出现 `anthropic`、`@anthropic-ai/sdk`、`claude_agent_sdk`
- 需要示例、集成、SDK 使用说明

不适用场景：

- 普通编程问题
- 使用的是 OpenAI 或其他 AI SDK

---

## 6. 使用 Skill 时的关键规则

### 1）不要只提 Skill，不调用它

如果判断应该使用某个 Skill，就必须真正调用，而不是只说：

> “你可以用 /commit”

更合适的做法是：直接执行对应 Skill。

---

### 2）不要重复调用已经在运行的 Skill

如果某个 Skill 已经在运行，不应再次启动同一个 Skill。

---

### 3）不要把内建 CLI 命令当 Skill

只有**系统明确列出的 user-invocable skills** 才能用 `Skill` 工具调用。

不能把普通内建命令误当作 Skill。

---

### 4）如果当前回合已经加载了对应命令，不要重复调用

如果消息里已经出现类似 `<command-name>` 的标记，表示该 Skill/命令可能已经展开，这时应直接按展开后的说明执行，而不是再次调用 Skill。

---

## 7. Skill 与普通工具的区别

Claude Code 里除了 Skill，还有很多普通工具，例如：

- `Read`：读文件
- `Edit`：改文件
- `Write`：写文件
- `Bash`：执行命令
- `Grep` / `Glob`：搜索

它们和 Skill 的区别在于：

### 普通工具

- 面向单一步骤能力
- 更底层
- 需要自己组合工作流

### Skill

- 面向一类完整任务
- 更高层
- 往往代表一个封装好的工作流程

可以理解为：

> Skill 是“任务级能力”，普通工具是“动作级能力”。

---

## 8. 实际使用建议

### 适合优先找 Skill 的情况

如果你的需求属于以下类型，建议先想想有没有现成 Skill：

- 配置 Claude Code
- 定时 / 循环执行某个动作
- 针对某类固定场景的工作流
- Claude API / Anthropic SDK 集成

---

### 不一定要用 Skill 的情况

如果只是：

- 看一个文件
- 改一小段代码
- 搜索某个函数
- 运行一条普通命令

通常直接使用普通工具就足够，不必强行套 Skill。

---

## 9. 一句话总结

**Skill 是 Claude Code 中针对特定任务场景封装好的高层能力。**

使用时主要记住四点：

- 用户输入 `/xxx`，通常就是在触发 Skill
- 需求与某个 Skill 明确匹配时，应直接调用 Skill
- Skill 名称必须来自当前环境提供的可用列表
- Skill 是任务级工作流，普通工具是底层执行动作

---

## 10. 常见示例

### 示例 1：配置权限

用户说：

```text
允许 npm 命令
```

适合使用：

```text
update-config
```

---

### 示例 2：循环检查部署

用户说：

```text
每 5 分钟检查一次部署状态
```

适合使用：

```text
loop
```

---

### 示例 3：使用 Claude API

用户说：

```text
帮我写一个调用 Claude API 的 Python 示例
```

适合使用：

```text
claude-api
```

---

### 示例 4：对改动做简化审查

用户说：

```text
帮我看看这次改动还能怎么简化
```

适合使用：

```text
simplify
```

---

## 11. 最后的理解框架

你可以用下面这个判断顺序来理解 Claude Code 中的 Skill：

1. 先看用户是不是直接用了 `/skill-name`
2. 再看当前系统有没有提供匹配的 Skill
3. 如果匹配，就优先调用 Skill
4. 如果不匹配，再用普通工具自己完成任务

这样基本就能正确理解 Claude Code 下 Skill 的使用方式。