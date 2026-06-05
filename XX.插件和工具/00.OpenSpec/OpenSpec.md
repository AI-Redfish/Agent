

# 1. OpenSpec 是什么

OpenSpec 是一个面向 AI 编程的 **规范驱动开发（Spec-Driven Development）** 系统。它的核心目标是在写代码之前，先把需求、设计、任务和规格变更标准化，让人和 AI 对“要构建什么、为什么构建、如何验收”形成一致理解。

它主要解决 AI 编程中的几个常见问题：

- 需求散落在聊天记录中，难以复用、审查和追踪。
- AI 输出不可预测，同一需求多次生成结果可能不同。
- 团队协作时，很难知道 AI 基于什么前提做了哪些改动。
- 缺少变更验证机制，容易出现需求、设计、实现不一致。

OpenSpec 的思路是：**先写规范，再让 AI 按规范实现**。规范作为项目资产保存在仓库中，可被 AI 工具读取、修改、验证和归档。

# 2. 核心机制

## 2.1 文件化需求

OpenSpec 把需求从对话上下文中抽离出来，沉淀为项目内的 Markdown 文件。这样需求不依赖某一次 AI 会话，而是成为可以被审查、复用、版本管理的工程资产。

常见文件包括：

- `proposal.md`：说明为什么要做、要改什么。
- `design.md`：说明技术设计、架构决策和关键取舍。
- `tasks.md`：拆解可执行任务和验收步骤。
- `specs/**/*.md`：描述功能规格、需求和场景。

## 2.2 Delta Spec

Delta Spec 是 OpenSpec 的关键机制之一。它不要求每次变更都重写完整规格，而是只描述“发生了什么变化”。

常见操作类型：

- `ADDED`：新增需求或场景。
- `MODIFIED`：修改已有需求或场景。
- `REMOVED`：删除已有需求或场景。
- `RENAMED`：重命名需求或规格。

这种机制让规格演进更清晰，也便于审查变更影响。

## 2.3 三层验证

OpenSpec 通过验证机制确保规范和变更是可解析、可合并、可执行的。

常见验证层次：

1. **格式验证**：Markdown 结构、标题、字段是否符合要求。
2. **语义验证**：Spec、Delta Spec、Change 的关系是否合理。
3. **业务一致性验证**：变更归档后是否能合并成一致的最终规格。

# 3. OpenSpec 架构概览

文章中将 OpenSpec 的架构分为三层：

## 3.1 CLI 层

CLI 是开发者和 AI 工具使用 OpenSpec 的入口，常用命令包括：

```bash
openspec init      # 初始化项目，生成 OpenSpec 目录和 AI 工具说明
openspec list      # 查看当前活跃的变更提案
openspec validate  # 验证规范、变更或项目结构
openspec archive   # 将完成的变更归档并合并到正式规格
```

CLI 通常还支持 `--json` 输出，便于 AI 编程助手或其他自动化工具调用。

## 3.2 Core 层

Core 层负责 OpenSpec 的核心逻辑，包含：

- Artifact Graph：根据文档依赖关系建立有向无环图（DAG），确定文档生成和验证顺序。
- Specs Apply：在归档时把 Delta Specs 合并进正式 Specs。
- Validation：解析 Markdown 并校验 Spec、Change、Delta Spec 的结构和语义。

## 3.3 Schema 层

Schema 层定义工作流需要哪些文档、文档之间的依赖关系、模板和应用规则。默认的 spec-driven schema 大致如下：

```yaml
name: spec-driven
version: 1
artifacts:
  - id: proposal
    generates: proposal.md
    requires: []

  - id: specs
    generates: "specs/**/*.md"
    requires: [proposal]

  - id: design
    generates: design.md
    requires: [proposal]

  - id: tasks
    generates: tasks.md
    requires: [specs, design]

apply:
  requires: [tasks]
  tracks: tasks.md
```

这意味着：先有提案，再有规格和设计，最后形成任务清单；完成后通过归档把变更合并到正式规范中。

# 4. 关键概念关系

## 4.1 Spec

Spec 是稳定的功能规格，描述系统应该满足什么需求。它通常包含 Purpose、Requirements 和 Scenario。

示例结构：

```markdown
# Authentication Specification

# Purpose
描述认证系统的目标。

# Requirements

## Requirement: User Login
系统 SHALL 支持用户使用用户名和密码登录。

## Scenario: Successful Login
- **GIVEN** 用户输入有效用户名和密码
- **WHEN** 用户点击登录按钮
- **THEN** 系统返回认证 token
- **AND** 重定向到用户主页
```

## 4.2 Change

Change 表示一次变更提案，通常位于 `openspec/changes/<change-id>/` 下。它是开发一个新功能或修改现有行为时的工作单元。

一个 Change 通常包含：

```text
openspec/changes/<change-id>/
├── proposal.md
├── design.md        # 可选，复杂变更建议保留
├── tasks.md
└── specs/
    └── <capability>/
        └── spec.md  # Delta Spec
```

## 4.3 Proposal

`proposal.md` 解释“为什么要做”和“做什么”。它适合在编码前与人类确认范围，避免 AI 直接跳到实现。

常见内容：

- 背景和问题。
- 目标与非目标。
- 变更范围。
- 影响面和风险。

## 4.4 Design

`design.md` 解释“如何做”。复杂变更中，它用于记录技术方案、架构取舍、数据模型、接口设计和迁移方案。

简单变更可以省略或保持很短，复杂变更建议保留。

## 4.5 Tasks

`tasks.md` 把变更拆成可执行步骤，适合 AI 按清单实现，也适合人类审查进度。

示例：

```markdown
# Tasks

- [ ] 1. 更新数据模型
- [ ] 2. 实现 API 逻辑
- [ ] 3. 增加测试用例
- [ ] 4. 运行 openspec validate
```

# 5. 常用工作流

## 5.1 初始化

```bash
npx openspec init
```

初始化通常会生成 `openspec/` 目录，并根据项目情况补充 AI 助手说明文件，使 Claude Code、Cursor、Windsurf 等工具知道如何遵守 OpenSpec 工作流。

## 5.2 创建变更

为新功能或行为调整创建一个 change：

```text
openspec/changes/add-user-login/
├── proposal.md
├── tasks.md
└── specs/
    └── auth/
        └── spec.md
```

变更目录名建议使用动词开头，例如：

- `add-user-login`
- `modify-auth-timeout`
- `remove-legacy-session`
- `rename-account-profile`

## 5.3 编写 Delta Spec

在 change 下的 `specs/<capability>/spec.md` 中，只描述本次变更。

示例：

```markdown
# ADDED Requirements

## Requirement: Password Login
系统 SHALL 支持用户使用用户名和密码登录。

## Scenario: Valid credentials
- **GIVEN** 用户输入有效用户名和密码
- **WHEN** 用户提交登录表单
- **THEN** 系统返回认证 token
```

## 5.4 验证

```bash
openspec validate
openspec validate <change-id>
openspec validate --strict
```

建议在让 AI 实现前、实现后、归档前都运行验证。

## 5.5 实现

实现阶段让 AI 读取：

1. `proposal.md`：确认目标和范围。
2. `design.md`：确认技术方案。
3. `tasks.md`：按任务逐项实现。
4. `specs/**/*.md`：确认验收场景。

## 5.6 归档

变更完成并验证通过后，将 change 归档：

```bash
openspec archive <change-id>
```

归档时会把 Delta Spec 合并到正式规格中，并把已完成的 change 移入归档区，便于后续追溯。

# 6. Core Profile 与 Extended Profile

文章提到 OpenSpec 可以按复杂度采用两种工作流。

## 6.1 Core Profile

适合小型功能、低风险改动或个人项目。

特点：

- 文档较少，路径短。
- 通常重点写 `proposal.md`、`tasks.md` 和必要的 Delta Spec。
- 更适合快速约束 AI 输出，不让流程变重。

## 6.2 Extended Profile

适合复杂需求、团队协作、高风险改动或需要审计的项目。

特点：

- 更强调 `design.md`、边界条件、风险和迁移方案。
- 更适合多人审查。
- 更适合需要长期维护和可追溯的工程系统。

# 7. 与 AI 编程助手协作的方式

OpenSpec 不锁定具体 AI 工具，文章提到它可支持 Claude Code、Cursor、Windsurf 等多种 AI 编程工具。

推荐协作方式：

1. **先让 AI 起草 proposal**：把口头需求转成结构化提案。
2. **人类审查 proposal**：确认目标、范围和非目标。
3. **让 AI 补充 spec/design/tasks**：把需求转成可验收场景和任务清单。
4. **运行 validate**：在实现前发现规范问题。
5. **让 AI 按 tasks 实现**：避免 AI 自行扩展范围。
6. **实现后再次 validate 和测试**：确认代码、任务和规格一致。
7. **archive 归档**：把变更合并进长期规格。

适合给 AI 的提示语：

```text
请阅读 openspec/changes/<change-id>/proposal.md、design.md、tasks.md 和 specs 下的 Delta Spec，严格按 tasks.md 实现，不要扩展范围。实现后运行 openspec validate 并更新 tasks.md 的完成状态。
```

# 8. 实践建议

- 小改动不要过度设计，优先使用 Core Profile。
- 涉及架构、数据模型、安全、权限、兼容性时，使用 Extended Profile。
- Change ID 使用清晰的动词短语，方便检索和归档。
- Spec 中的 Requirement 应该可验收，Scenario 尽量使用 GIVEN/WHEN/THEN。
- 不要把实现细节塞进 Spec；实现细节放到 Design。
- 不要让 AI 直接编码复杂需求，先让 AI 写 proposal/spec/tasks。
- 每次归档前运行 `openspec validate --strict`。
- 把 OpenSpec 文件纳入 Git 管理，让需求和代码一起审查。

# 9. 一句话总结

OpenSpec 的价值在于把 AI 编程从“聊天驱动”变成“规范驱动”：先沉淀可审查、可验证、可追溯的规格，再让 AI 基于规格实现，从而降低 AI 输出不可控和团队协作不透明的问题。
