# 安装

```
# 安装 Codex 子代理 Bundle
pnpm dsh plugin --profile web add @deepseek-ai/dsh-subagent-codex

# 安装 Claude Code 子代理 Bundle
pnpm dsh plugin --profile web add @deepseek-ai/dsh-subagent-claude-code
```



**修改cordis.patch.yml**

位置：~/.dsh/profilex/web/cordis.patch.yml

```
# ============================================================
# DSH Profile 补丁配置 - Codex & Claude Code 子代理
# ============================================================
# 说明：
# 1. 此文件位于 $DSH_HOME/profiles/<你的Profile名称>/cordis.patch.yml
# 2. 配置生效顺序：基础配置 → 此补丁配置
# 3. 修改后需要重启 DSH 实例才能生效
# ============================================================

# ============================================================
# 第一部分：注册子代理实例（定义"干活的人"）
# ============================================================

# ---------- Codex 实例 1：只读审查 ----------
# 用途：代码审查、安全扫描、静态分析
# 权限：never - 自动拒绝所有需要确认的操作
- id: subagent-codex-review
  name: '@deepseek-ai/dsh-subagent-codex'
  config:
    providerName: codex-review
    permissionMode: never
    env:
      OPENAI_API_KEY: !!js process.env.OPENAI_API_KEY

# ---------- Codex 实例 2：全自动化 ----------
# 用途：代码生成、批量重构、自动化修复
# 权限：dangerously-bypass-approvals-and-sandbox - 完全自动化，跳过所有确认
- id: subagent-codex-auto
  name: '@deepseek-ai/dsh-subagent-codex'
  config:
    providerName: codex-auto
    permissionMode: dangerously-bypass-approvals-and-sandbox
    env:
      OPENAI_API_KEY: !!js process.env.OPENAI_API_KEY

# ---------- Claude Code 实例 ----------
# 用途：代码编辑、文件操作、交互式开发
# 权限：acceptEdits - 自动接受编辑操作，其他操作需确认
- id: subagent-claude-code
  name: '@deepseek-ai/dsh-subagent-claude-code'
  config:
    providerName: claude-code
    permissionMode: acceptEdits
    env:
      ANTHROPIC_API_KEY: !!js process.env.ANTHROPIC_API_KEY

# ============================================================
# 第二部分：暴露为工具（创建"菜单按钮"）
# ============================================================

# ---------- 工具：codex_review ----------
# 关联 codex-review 实例，前台运行
- id: tool-subagent-codex-review
  name: '@deepseek-ai/dsh-tool-subagent'
  config:
    provider: codex-review
    toolName: codex_review
    enableRunInBackground: false

# ---------- 工具：codex_auto ----------
# 关联 codex-auto 实例，后台运行
- id: tool-subagent-codex-auto
  name: '@deepseek-ai/dsh-tool-subagent'
  config:
    provider: codex-auto
    toolName: codex_auto
    enableRunInBackground: true

# ---------- 工具：claude_code ----------
# 关联 claude-code 实例，前台运行
- id: tool-subagent-claude-code
  name: '@deepseek-ai/dsh-tool-subagent'
  config:
    provider: claude-code
    toolName: claude_code
    enableRunInBackground: false
```





# 对话中使用

```
请用 codex_review 审查 src/main.py
请用 codex_auto 自动修复 src/utils.py 的代码风格问题
请用 claude_code 帮我生成单元测试
```



