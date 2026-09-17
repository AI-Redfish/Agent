

# 概述

`settings.json` 用于配置 Claude Code 的默认行为，例如权限、hooks、模型、环境变量等。





**官方文档**

https://docs.anthropic.com/en/docs/claude-code/settings

https://docs.anthropic.com/en/docs/claude-code/iam





**位置**

| 位置 | 范围 | 可共享 |
| :--- | :--- | :--- |
| `~/.claude/settings.json` | 当前用户的全局配置 | 否，仅当前机器生效 |
| `.claude/settings.json` | 当前项目配置 | 是，可以提交到仓库 |
| `.claude/settings.local.json` | 当前项目的本地配置 | 否，通常不提交 |



# permissions

`permissions` 用于控制 Claude Code 在会话中对工具和操作的授权方式：哪些直接允许，哪些需要确认，哪些明确拒绝。



**作用**

- 减少重复的权限确认，提高日常使用效率。
- 对高风险命令、敏感文件、敏感目录做限制。
- 为不同场景设置不同默认模式，例如只读审查、日常编码、自动化执行。





## 配置示例

**常见日常开发配置**

```json
{
  "permissions": {
    "defaultMode": "acceptEdits",
    "allow": [
      "Read",
      "Bash(npm run lint)",
      "Bash(npm test)"
    ],
    "ask": [
      "Bash(git push)"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./secrets/**)",
      "Bash(rm -rf *)"
    ]
  }
}
```

说明：

- 常用检查命令直接放行。
- `git push` 这类会影响远端仓库的操作，建议保留人工确认。
- `.env`、密钥目录、危险删除命令建议明确写入 `deny`。



**只读审查模式**

```json
{
  "permissions": {
    "defaultMode": "plan"
  }
}
```

说明：适合只想让 Claude 看代码、做分析、给建议，而不允许它直接修改文件或执行命令的场景。



## 配置选项



**defaultMode 可选值**

设置会话默认权限模式。

| 值 | 说明 | 常见场景 |
| :--- | :--- | :--- |
| `default` | 标准权限模式，按默认策略进行交互确认。每次改文件或跑命令都问你。 | 日常通用 |
| `acceptEdits` | 自动接受文件编辑相关操作。如果是命令仍要寻味。 | 本地高频编码 |
| `plan` | 仅做分析和规划，不执行写入或命令。 | 代码审查、方案设计 |
| `bypassPermissions` | 跳过权限确认。 | 受控自动化环境，需谨慎使用 |



**disableBypassPermissionsMode**

设为 `"disable"` 时，禁止启用 `bypassPermissions` 模式。

```json
{
  "permissions": {
    "disableBypassPermissionsMode": "disable"
  }
}
```

说明：适合团队环境或风险要求较高的环境，避免会话切换到 `bypassPermissions` 模式。



**additionalDirectories**

允许 Claude 访问工作区之外的额外目录。

```json
{
  "permissions": {
    "additionalDirectories": [
      "D:/shared/docs",
      "D:/work/config"
    ]
  }
}
```

说明：当 Claude 需要读取当前项目目录之外的文件时，可以通过该字段显式放行额外目录。



**其他字段**

| 字段                | 说明                                 |
| :------------------ | :----------------------------------- |
| `permissions.allow` | 命中后直接允许执行。                 |
| `permissions.ask`   | 命中后弹出确认，由用户决定是否继续。 |
| `permissions.deny`  | 命中后直接拒绝执行。                 |



## 使用建议

- 优先采用最小授权原则，只放行真正高频且低风险的操作。
- `deny` 的优先级高于 `allow` 和 `ask`，敏感规则应优先写在 `deny` 中。
- `Bash` 建议只放行具体命令，不建议直接放开全部 shell 权限。
- 涉及密钥、证书、生产配置的路径，建议显式加入 `deny`。
- 团队共享规则建议写入 `.claude/settings.json`；个人偏好建议写入 `.claude/settings.local.json`。
- `bypassPermissions` 仅适合高信任、强约束的自动化环境，普通开发场景应谨慎使用。





# env

指定环境变量。

```
{
  "permissions": {
    "allow": [
    
    ]
  },
   "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

