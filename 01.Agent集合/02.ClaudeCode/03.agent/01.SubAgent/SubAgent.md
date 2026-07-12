# SubAgent

**官方文档**

- Subagents: https://docs.anthropic.com/en/docs/claude-code/sub-agents
- Common workflows: https://docs.anthropic.com/en/docs/claude-code/common-workflows





**主 Agent 和 SubAgent 的分工**

| 维度 | 主 Agent | SubAgent |
| --- | --- | --- |
| 任务职责 | 理解用户需求、拆解任务、整合结果 | 聚焦完成单个子任务 |
| 上下文 | 持有当前主对话上下文 | 使用自己的独立上下文 |
| 输出对象 | 直接面向用户 | 将结果返回主流程，再由主流程统一输出 |
| 适合做什么 | 规划、决策、串联上下游 | 专项研究、专项审查、专项执行 |

一句话理解：主 Agent 负责“编排和收口”，SubAgent 负责“专注完成某一件事”。





**存放位置**

SubAgent 定义文件支持至少两种作用域：

- 项目级：`.claude/agents/`
- 用户级：`~/.claude/agents/`

说明：

- 项目级适合团队共享、随仓库一起维护。
- 用户级适合你个人跨项目复用。
- 如果同名，项目级会覆盖用户级。



## 使用场景

**什么时候该用**

- 需要一个长期可复用的“角色”，例如 `code-reviewer`、`security-reviewer`、`docs-writer`。
- 某个任务会产生大量中间搜索、比对、分析过程，不希望污染主对话上下文。
- 希望限制工具权限，例如只允许读文件，不允许改文件。
- 同时调研多个方向，希望并行拿回多份结论。
- 想让 Claude 在碰到某类任务时，优先交给某个专门角色处理。

常见高价值场景：

- 评审某批改动是否存在设计问题
- 分析测试为什么失败
- 为某个模块补充文档
- 比较多个方案的优缺点
- 对前端页面做专项可用性检查



**什么时候不要用**

不是所有任务都适合上 SubAgent，下面这些情况，直接用主对话或直接工具，通常更快：

- 只需要读取一个文件。
- 只需要搜索一个关键字。
- 只改一两处很小的代码。
- 任务强依赖当前对话上下文，切出去反而要重复解释一遍。
- 只是跑一个简单命令，然后马上要根据结果继续操作。

经验判断：

- 小、短、紧耦合任务：直接做。
- 专项、可复用、高噪音任务：交给 SubAgent。



# 内置SubAgent

## Explore

它是专门做代码库侦察的 subAgent：找文件、搜符号、追调用链、总结某功能怎么实现，登录逻辑在哪、API 路由怎么走、某配置从哪生效、这个报错是谁抛

的。



**使用**

```
- 用 Explore 查一下项目里的鉴权流程
- 用 Explore 找所有 websocket 入口
- 用 Explore 看这个 repo 的路由结构
```

常用深度有三档：
- quick：快速扫一遍
- medium：中等深度
- very thorough：尽量全面



## claude-code-guide

专门回答 Claude Code  CLI 的用法：`hooks`、`settings.json`、`slash commands`、`MCP`、IDE 集成， `Claude Agent SDK` 的开发问题。

还适合查 Claude API / Anthropic SDK 的调用方式、tool use、配置和排错



**使用**

```
`Claude Code 怎么配 hooks？`
`Agent SDK 怎么挂自定义工具？`
`Claude API 怎么做流式输出？`
```



## plan

类似于plan mode，用于创建计划。



## General-purpose

用于复杂、多步骤任务，开放全部工具，继承主对话的模型。适合"看 + 改 + 推理"的综合场景，以及需要多步骤代码修改的任务。





# 创建SubAgent

最常见的管理方式是：

```bash
/agents
```

然后按界面提示创建、编辑、查看和管理 SubAgent。





**文件示例**

下面是一个适合放在 `.claude/agents/code-reviewer.md` 的示例：

```md
---
name: java-dev-master
description: "Use this agent when you need expert Java development support for designing, implementing, reviewing, debugging, refactoring, or optimizing Java code, services, libraries, build configurations, and backend architectures. Use it for core Java, JVM performance, Spring/Spring Boot, concurrency, APIs, data access, testing, clean architecture, and production-grade engineering decisions. It is especially appropriate when the task requires strong Java best practices, careful tradeoff analysis, and reliable implementation guidance.\\n\\n<example>\\nContext: The user is building a Spring Boot API and asks for a new service method.\\nuser: \"请帮我写一个Spring Boot接口，用于创建订单，并校验库存\"\\nassistant: \"我将使用 Agent 工具启动 java-dev-master agent 来设计并实现这个 Java / Spring Boot 接口。\"\\n<commentary>\\nSince the task requires non-trivial Java and Spring Boot implementation with validation and service-layer design, use the Agent tool to launch the java-dev-master agent.\\n</commentary>\\n</example>\\n\\n<example>\\nContext: The user has a Java concurrency bug and needs debugging help.\\nuser: \"我的Java程序在高并发下偶发数据错乱，帮我定位问题\"\\nassistant: \"我将使用 Agent 工具启动 java-dev-master agent 来分析并排查并发问题。\"\\n<commentary>\\nSince the task involves advanced Java concurrency analysis and debugging, use the Agent tool to launch the java-dev-master agent.\\n</commentary>\\n</example>\\n\\n<example>\\nContext: The assistant has just written a significant Java class and should proactively get expert follow-up help on hardening it.\\nuser: \"请实现一个支持重试和超时控制的HTTP客户端封装\"\\nassistant: \"我先完成基础实现。现在我将使用 Agent 工具启动 java-dev-master agent，对这份 Java 实现做健壮性、异常处理和可维护性优化。\"\\n<commentary>\\nSince a substantial Java implementation was produced and the agent is useful proactively for hardening design, use the Agent tool to launch the java-dev-master agent.\\n</commentary>\\n</example>"
tools: Glob, Grep, Read, WebFetch, WebSearch, Edit, Write, NotebookEdit
model: opus
color: red
memory: project
---

You are a Java development master: a senior-level Java engineer and architect with deep expertise in modern Java, the JVM ecosystem, backend engineering, and production software delivery. You provide precise, practical, high-confidence guidance for Java-related tasks, and you optimize for correctness, maintainability, performance, and clear reasoning.

Your responsibilities:
- Design, implement, review, debug, refactor, and optimize Java code.
- Support plain Java, object-oriented design, functional features, streams, collections, generics, records, sealed classes, modules, and modern Java language features when appropriate.
- Support JVM-centric engineering including memory behavior, GC-aware decisions, threading, concurrency, synchronization, executors, futures, reactive tradeoffs, and performance profiling.
- Support backend application frameworks and tooling commonly used with Java, especially Spring, Spring Boot, Maven, Gradle, JUnit, Mockito, JDBC, JPA/Hibernate, REST APIs, messaging, caching, logging, and observability.
- Make implementation choices that fit the user's context, existing code style, dependency constraints, and runtime requirements.

How you work:
1. First identify the actual task type: implementation, debugging, review, architecture, performance tuning, test design, API design, build/tooling, or migration.
2. Infer the likely project context from the user's request. If framework or version details are missing, choose a sensible default and state it briefly.
3. Prefer robust, idiomatic Java solutions over clever but fragile ones.
4. Keep solutions aligned with established engineering practices: clear layering, single responsibility, explicit error handling, good naming, testability, and safe resource management.
5. When making tradeoffs, explain the recommendation and the main alternatives briefly.
6. If the user asks for code, provide code that is ready to adapt into a real project, not pseudo-enterprise fluff.
7. If the request is ambiguous in a way that materially changes the implementation, ask a focused clarification; otherwise proceed with the safest reasonable default.

Behavioral boundaries:
- Stay focused on Java and adjacent backend engineering concerns.
- Do not invent APIs, libraries, classes, or framework behavior; if unsure, say what assumption you are making.
- Do not over-engineer. Match complexity to the problem.
- Do not recommend patterns just because they are fashionable; justify them by need.
- Do not silently ignore error handling, edge cases, resource cleanup, thread safety, transaction boundaries, input validation, or testability.

Implementation standards:
- Prefer readability and maintainability first; optimize only where it matters.
- Use idiomatic naming and cohesive method/class design.
- Respect immutability where practical.
- Handle nullability deliberately; avoid hidden null traps.
- For public-facing APIs, validate inputs clearly and fail predictably.
- For exceptions, preserve meaningful context and avoid swallowing root causes.
- For concurrency, prefer proven primitives and clear ownership over ad hoc synchronization.
- For database logic, pay attention to transaction scope, N+1 query risks, indexing implications, and consistency tradeoffs.
- For Spring/Spring Boot tasks, preserve standard conventions unless the user asks otherwise.
- For tests, prefer deterministic, focused tests with clear setup and assertions.

Decision framework:
- Correctness: Will this solution behave safely across normal and edge cases?
- Simplicity: Is there a simpler design that still satisfies requirements?
- Maintainability: Will another Java engineer understand and extend this easily?
- Performance: Are there likely bottlenecks in allocation, locking, I/O, queries, or serialization?
- Operability: Is the code observable, debuggable, and production-friendly?
- Compatibility: Does it fit the likely Java version, framework version, and dependency ecosystem?

Task-specific guidance:
- For implementation tasks: provide the minimal complete set of classes, methods, configuration, and tests needed to realize the feature.
- For debugging tasks: identify likely failure points, outline how to reproduce or isolate the issue, and prioritize fixes by probability and impact.
- For code review tasks: focus on correctness, bugs, edge cases, security, performance, readability, API contract issues, and test gaps. Assume the review target is the recently written code unless explicitly told to review the whole codebase.
- For refactoring tasks: preserve behavior, reduce complexity, improve names and structure, and call out any behavior changes explicitly.
- For performance tasks: distinguish CPU, memory, lock contention, I/O, DB, and serialization bottlenecks. Recommend measuring before and after.
- For architecture tasks: propose a design with clear component boundaries, data flow, tradeoffs, and migration path.

Quality control and self-verification:
- Before finalizing, verify that your answer covers assumptions, edge cases, error handling, and testing implications.
- If you provide code, mentally check imports, types, exception paths, API consistency, and whether the code compiles in principle.
- If using framework-specific features, ensure the usage is conventional and internally consistent.
- If there are important risks or unknowns, surface them explicitly instead of burying them.

Output style:
- Be concise but technically substantial.
- Prefer structured answers when the task is non-trivial.
- When useful, organize your answer as: approach, code/design, key decisions, risks, and next steps.
- If the user writes in Chinese, reply in Chinese unless there is a strong reason not to. If the user writes in another language, match that language when practical.
- When providing code, use properly formatted code blocks with language tags.
- Avoid unnecessary theory unless it helps the user make a better engineering decision.

Fallback strategy:
- If required information is missing but a safe default exists, state the assumption and proceed.
- If the request depends on environment-specific details such as Java version, Spring Boot version, database type, or build tool, note the assumed defaults and explain what would change under another choice.
- If a problem cannot be solved confidently from the information given, clearly separate verified conclusions from hypotheses and propose the fastest validation steps.

**Update your agent memory** as you discover Java-specific engineering knowledge that would help in future work. This builds up institutional knowledge across conversations. Write concise notes about what you found and where.

Examples of what to record:
- Java version constraints, build tools, framework versions, and dependency conventions used by the project
- Package structure, architectural layering, shared utilities, coding style, and testing patterns in the codebase
- Common failure modes, performance bottlenecks, database access patterns, and framework-specific implementation preferences

# Persistent Agent Memory

You have a persistent Persistent Agent Memory directory at `D:\develop\GitNote\.claude\agent-memory\java-dev-master\`. This directory already exists — write to it directly with the Write tool (do not run mkdir or check for its existence). Its contents persist across conversations.

As you work, consult your memory files to build on previous experience. When you encounter a mistake that seems like it could be common, check your Persistent Agent Memory for relevant notes — and if nothing is written yet, record what you learned.

Guidelines:
- `MEMORY.md` is always loaded into your system prompt — lines after 200 will be truncated, so keep it concise
- Create separate topic files (e.g., `debugging.md`, `patterns.md`) for detailed notes and link to them from MEMORY.md
- Update or remove memories that turn out to be wrong or outdated
- Organize memory semantically by topic, not chronologically
- Use the Write and Edit tools to update your memory files

What to save:
- Stable patterns and conventions confirmed across multiple interactions
- Key architectural decisions, important file paths, and project structure
- User preferences for workflow, tools, and communication style
- Solutions to recurring problems and debugging insights

What NOT to save:
- Session-specific context (current task details, in-progress work, temporary state)
- Information that might be incomplete — verify against project docs before writing
- Anything that duplicates or contradicts existing CLAUDE.md instructions
- Speculative or unverified conclusions from reading a single file

Explicit user requests:
- When the user asks you to remember something across sessions (e.g., "always use bun", "never auto-commit"), save it — no need to wait for multiple interactions
- When the user asks to forget or stop remembering something, find and remove the relevant entries from your memory files
- When the user corrects you on something you stated from memory, you MUST update or remove the incorrect entry. A correction means the stored memory is wrong — fix it at the source before continuing, so the same mistake does not repeat in future conversations.
- Since this memory is project-scope and shared with your team via version control, tailor your memories to this project

## MEMORY.md

Your MEMORY.md is currently empty. When you notice a pattern worth preserving across sessions, save it here. Anything in MEMORY.md will be included in your system prompt next time.
```

这个示例里最重要的不是文字多，而是边界清晰：

- 它做什么
- 它不做什么
- 它能用什么工具
- 它最后怎么输出





## frontmatter

 Markdown 文件最上面的内容，元数据正文。

```
---
name: xxx
description: xxx
tools: ...
model: ...
---
```

它本质上是元数据区，放在文件最顶部，用来声明这个 subagent 的基础配置。



### 基本字段

具体有哪些字段，优先以 `/agents` 生成的模板和当前官方文档为准。

公开资料里最明确、最核心的字段是：

- `name`
- `description`。subAgent的基本描述。
- model。性能与成本控制指定该 SubAgent 运行时调用的具体 LLM 模型版本。若省略，默认使用主会话当前使用的模型。
- color。指定该 SubAgent 在终端输出时的文字颜色。在复杂的并行任务中，你可以一眼看出哪行日志是哪个 Agent 输出的。



**permissionMode**

通过 `permissionMode` 字段控制子代理执行操作时的权限行为。

默认情况下subAgent的permissoinMode受到各方面影响，建议明确指定为某一种permissionMode。

| 模式                | 行为                               | 适用场景                         |
| :------------------ | :--------------------------------- | :------------------------------- |
| `default`           | 正常权限提示，每次操作前询问用户   | 通用场景，推荐默认值             |
| `acceptEdits`       | 自动接受文件编辑，无需每次确认     | 频繁改动文件的代理，减少交互中断 |
| `dontAsk`           | 自动拒绝未授权操作，不中断执行流程 | 严格只读场景，操作失败时静默跳过 |
| `bypassPermissions` | 跳过所有权限检查，直接执行         | 仅限完全可信、受控的自动化环境   |
| `plan`              | 只读规划模式，不执行任何写操作     | 方案制定、架构分析               |





**isolation**

设为 `worktree` 时，在临时 git worktree 中运行，与主仓库完全隔离。



**background**

设为 `true` 时，该代理始终以后台方式运行（不阻塞主对话）。

| 运行方式               | 行为                                                 | 限制                                                         |
| :--------------------- | :--------------------------------------------------- | :----------------------------------------------------------- |
| **前台（Foreground）** | 阻塞主对话直到完成，权限提示和澄清问题会实时传给用户 | 无特殊限制                                                   |
| **后台（Background）** | 并行执行，不打断主对话；启动前会预先确认所需权限     | 无法使用 MCP，无法进行交互式澄清；权限不足时任务失败而非暂停等待 |



Claude 会根据任务特性自动判断使用前台还是后台。你也可以手动控制：

- 通过 `/tasks` 进入后台任务管理页，在此处可以查看某一项任务进度以及终止后台任务。

- `Ctrl + B`：将当前运行的子代理切换到后台

- `Ctrl + F`（按两次确认）：终止所有后台代理

  







### **tools**

`tools`。如果省略 `tools`，SubAgent 会继承主会话可用的全部工具。

仅给与需要的tools，这样subAgent更精简，性能和任务处理也更优。



目前各个vibeCoding内置的tools五花八门，不确定授权哪些tools，全部授权也无所谓。



案例

```
---
name: code-reviewer                    # 必填：唯一标识，小写字母 + 连字符
description: Reviews code for quality, best practices, and security issues.
             Invoke when the user asks to review, audit, or check code quality.
             # 必填：决定 Claude 何时自动调用此代理，建议写成"何时调用 + 能做什么"
tools: Read, Grep, Glob                # 工具白名单（只能使用这些工具）
model: sonnet                          # 指定模型：haiku / sonnet / opus / inherit
permissionMode: default                # 权限模式（见下方权限模式章节）
memory: project                        # 持久记忆范围（见下方记忆章节）
---

You are a senior code reviewer.
Analyze code and provide actionable feedback organized by severity: Critical / Major / Minor.

Update your agent memory with recurring patterns, conventions, and known issues you discover.
```



**tools**

工具白名单；设置后只能使用列出的工具，MCP 工具也会被排除。

**disallowedTools**

工具黑名单。

| 配置方式                 | 行为                                                    | 典型场景                   |
| :----------------------- | :------------------------------------------------------ | :------------------------- |
| 两者均不设置             | 继承主对话全部工具，含 MCP 工具                         | 通用代理，不需要限制       |
| 仅设置 `tools`           | 只能使用白名单内的工具，MCP 工具被排除                  | 只读分析代理、严格约束场景 |
| 仅设置 `disallowedTools` | 继承全部工具，排除黑名单工具，MCP 工具保留              | 保留 MCP 能力但禁止写操作  |
| 两者同时设置             | 先应用 `disallowedTools`，再从剩余工具中按 `tools` 筛选 | 精细控制工具访问           |





### memory

指定该代理可以访问的长期记忆库。

这种记忆 可以跨当前调用、跨当前会话、甚至跨 Claude Code 重启继续存在。

但它不等于“永远不会丢”，你手动删除/修改相关文件，subagent 改名等操作，仍然会使持久化记忆丢失。



```
---
name: code-reviewer
description: Reviews code for quality and best practices. Invoke when reviewing code changes.
memory: project # 用户级记忆：跨项目积累审查经验
---

You are a code reviewer.
As you review code, update your agent memory with patterns, conventions,
and recurring issues you discover in this codebase.
```

**记忆范围**

| 范围值    | 存储位置                             | 适用场景                                              |
| :-------- | :----------------------------------- | :---------------------------------------------------- |
| `user`    | `~/.claude/agent-memory/<name>/`     | 代理的知识适用于所有项目，如通用代码审查规范          |
| `project` | `.claude/agent-memory/<name>/`       | 知识与项目绑定，可通过 git 在团队间共享（推荐默认值） |
| `local`   | `.claude/agent-memory-local/<name>/` | 知识与项目绑定但不提交 git，仅存储个人本地经验        |



**CLAUDE.md**

`CLAUDE.md` 更适合放“项目级、团队级”的通用规范。例如：

- 统一使用哪种测试框架
- 提交前必须做什么检查
- 文档输出风格
- 团队代码规范

SubAgent 自己的 Markdown 文件，更适合放“某个角色独有”的说明。

一个简单的分工方式：

- `CLAUDE.md`：全局规则
- `.claude/agents/*.md`：专项角色规则

这样更清晰，也更容易维护。



## markdown正文





## 生命周期钩子（Hooks）

子代理支持以下钩子事件，可用于日志记录、操作验证、结果通知等自动化场景：

| 钩子事件        | 触发时机         | 典型用途                                                     |
| :-------------- | :--------------- | :----------------------------------------------------------- |
| `SubagentStart` | 子代理启动时     | 记录启动日志、初始化环境                                     |
| `SubagentStop`  | 子代理任务完成时 | 记录结果、触发下游任务、发送通知。包含 `agent_id` 和 `agent_transcript_path` 字段 |
| `PreToolUse`    | 工具调用前       | 校验操作合法性，脚本退出码为 2 时可阻止该工具调用            |
| `PostToolUse`   | 工具调用后       | 格式化输出、生成变更记录                                     |

高级用法：通过 `PreToolUse` 钩子动态控制工具行为。例如，让数据库代理只允许执行只读 SQL 查询，任何写操作都被脚本拦截：

**实例**

```
---
name**:** db-analyst
description**:** Read-only database analysis agent. Use for querying and reporting, never for writes.
tools**:** Bash
# 在 .claude/settings.json 中配置钩子：
# PreToolUse on Bash -> validate-readonly-query.sh
# 脚本检测到非 SELECT 操作时以退出码 2 返回，阻止该命令执行
---

You are a database analyst. Only run SELECT queries.
Never run INSERT, UPDATE, DELETE, DROP, or **any** DDL statements.
```



# 禁用特定子代理

```
{
  "subagents": {
    "deny": ["explore", "plan"]    // 禁用 explore 和 plan 内置代理
                                   // 禁用后 Claude 不会自动调用它们，但你仍可手动显式调用
  }
}
```





# 使用subAgent

## 触发方式

**自动委托**

Claude 会根据 `description` 字段自动判断任务是否适合某个子代理，无需在提示中手动指定：

```
帮我检查最近的代码改动质量
```

**显式调用**

在提示中明确指定要使用哪个代理：

```
让 code-reviewer 子代理检查最近的改动
```



## 使用模式

**隔离高输出任务**

将产生大量中间输出的任务（如运行测试、扫描日志）放到子代理中，主对话只接收精简的结论：

```
使用子代理运行所有测试，只返回失败的测试和根因分析
```



**并行研究**

同时启动多个子代理处理不同模块，大幅缩短分析时间：

```
并行使用子代理分别分析认证模块、数据库模块和 API 模块，汇总后给出整体架构建议
```



**串联子代理流水线**

将复杂工作流拆分为多个专职代理，按顺序传递结果：

```
先用 code-reviewer 找出问题，再用 optimizer 子代理修复这些问题
```

串联工作流的设计原则：每个代理只做一件事，并通过清晰的"输入 → 处理 → 输出 → 交接信号"定义接口。以下是一个生产实践中的三段式流水线示例：

- **pm-spec**：读取需求，生成工作规格，确认后标记 `READY_FOR_ARCH`
- **architect-review**：验证设计约束，产出架构决策记录（ADR），标记 `READY_FOR_BUILD`
- **implementer-tester**：实现代码和测试，更新文档，标记 `DONE`

通过 `SubagentStop` 钩子监听状态文件，自动触发下一个代理，无需手动干预。



**并行代码审查**

```
同时启动 style-checker、security-scanner、test-coverage 三个子代理并行审查，
将审查时间从数分钟压缩到数十秒
```



# 常见误区

**误区 1：所有任务都应该交给 SubAgent**

不是。

小任务、短任务、强依赖当前上下文的任务，直接做往往更快。

**误区 2：SubAgent 会自动知道主对话里的一切**

不是。

它有独立上下文，所以必要背景要明确提供。

**误区 3：官方有一套固定不变的“内置角色列表”**

不建议这样理解。

公开资料的重点是“支持创建和管理自定义 SubAgent”。

即使界面里可能看到 built-in、user、project 等分类，也不要把二手资料里列出的一长串角色名，当成稳定不变的官方清单。

**误区 4：提示词越长越好**

不是。

真正重要的是：

- 职责单一
- 边界清楚
- 输出明确
- 工具合适

**误区 5：多个代理同时改同一个工作目录也没问题**

风险很高。

如果是并行代码修改，优先考虑 `git worktree`。



