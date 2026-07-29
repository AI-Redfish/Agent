

# 概述

OpenSpec 本质上是把需求整理成可执行规范：先说明要做什么、范围是什么、规则是什么、如何验收，再据此实现和测试。它适合需求容易变形、多人协作或 AI/Agent 参与的场景，核心价值是减少理解偏差和返工。


文件结构
```
openspec/
├── project.md              # 项目约定、技术栈、编码规范等上下文信息
├── specs/                  # 📌 源：当前系统已构建的“真理”（只读/已构建的能力）
│   └── [capability]/       # 单一能力（如 auth、payment）
│       ├── spec.md         # 需求与场景
│       └── design.md       # 技术设计模式
└── changes/                # 🚀 提议：将要发生的“变更”（读写/工作区）
    ├── [change-name]/      # 一个独立的变更（如 add-dark-mode）
    │   ├── proposal.md     # 为什么要改，改什么，影响范围
    │   ├── tasks.md        # 实施任务清单（待办事项）
    │   ├── design.md       # （可选）此变更的技术决策
    │   └── specs/          # 增量变更（对 specs/ 的差异描述）
    │       └── [capability]/
    │           └── spec.md # 使用 ADDED/MODIFIED/REMOVED 描述变更
    └── archive/            # 📦 已完成的历史变更归档
```


# 安装
```
# 安装openSpec
npm install -g @fission-ai/openspec@latest

# 进入工作空间，初始化项目。系统会创建openspec目录以及相关文件。
openspec init
# 命令会生成如下文件
openspec/
  ├── proposals/       # 所有提案记录
  ├── archives/        # 已归档的完成规范
  ├── project.md       # 项目整体规范
  └── config.yaml      # 可选配置
```

# 快速上手
## 前提探索
```
/opsx:explore
```
使用如上命令进入“思考模式”，帮你梳理需求、评估方案，但不生成任何正式文件。
 
**案例**
```
/opsx:explore 我想用js写一个脚本，通过读取配置文件创建定时任务。
```

## 创建提案
```
 /opsx:propose 通过js实现定时任务注册，支持注册，注销，手动执行。
```


OpenSpec 会自动生成：
```
openspec/changes/add-user-auth/
├── proposal.md   (为什么要做，解决了什么问题)
├── design.md     (技术方案、架构决策)
├── tasks.md      (可执行的任务清单)
└── specs/        (变更涉及的规范 delta)。这里的规范，即产品需求。
```

**审查提案**
对以上生成文件内容：提案，任务清单等文件进行人工审查。

也可以让 Claude 帮你审查提案的合理性。


## 任务实施
```
/opsx:apply
```

AI读取 tasks.md，按顺序逐步实施任务。


## 归档
```
/opsx:archive
```
以上命令将会进行如下动作：
- 将 specs/ 中的 delta 合并到 openspec/specs/ 主规范
- 将 changes/add-user-auth/ 移动到 changes/archive/ 归档目录。归档的变更完整记录了某次改动的规范变化。
- 清理临时文件



## 其他操作
## 同步增量需求
```
/opsx:sync
```
将某个变更（Change）中的增量规范（Delta Specs）合并到项目的主规范（Main Specs）中，但保留变更本身（即不归档）。

</br>

**使用场景**

正式完成归档之前，就先把已确定的规范修改应用到项目规范文档中。


# CLI命令

| 命令 | 作用 |
| --- | --- |
| `openspec init` | 在项目中初始化 OpenSpec，创建目录结构和配置文件。 |
| `openspec list` | 列出所有进行中的变更及其任务完成进度。 |
| `openspec list --specs` | 列出所有已归档的稳定规范。 |
| `openspec show <change-name>` | 查看某个变更的详细信息（提案、任务等）。 |
| `openspec validate <change-name>` | 检查变更的规范格式是否正确。 |
| `openspec archive <change-name>` | 在终端中归档一个已完成的变更（对应 AI 命令 `/opsx:archive`）。 |
