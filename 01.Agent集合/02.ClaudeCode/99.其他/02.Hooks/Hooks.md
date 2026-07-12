# 官方文档

https://code.claude.com/docs/zh-CN/hooks-guide





# 作用范围

| 位置                          | 范围         | 可共享             |
| :---------------------------- | :----------- | :----------------- |
| `~/.claude/settings.json`     | 你的所有项目 | 否，本地到你的机器 |
| `.claude/settings.json`       | 单个项目     | 是，可以提交到仓库 |
| `.claude/settings.local.json` | 单个项目     | 否，gitignored     |



# hook组成

## matcher

没有匹配器，hook 会在其事件的每次出现时触发。匹配器让你缩小范围。



例如，如果你只想在文件编辑后运行格式化程序（而不是在每次工具调用后），将匹配器添加到你的 `PostToolUse` hook

```
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "prettier --write ..." }
        ]
      }
    ]
  }
}
```

`"Edit|Write"` 匹配器是一个正则表达式模式，匹配工具名称。hook 仅在 Claude 使用 `Edit` 或 `Write` 工具时触发，而不是在它使用 

`Bash`、`Read` 或任何其他工具时。



每个事件类型匹配特定字段。匹配器支持精确字符串和正则表达式模式：

| 事件                                                         | 匹配器过滤的内容 | 示例匹配器值                                                 |
| :----------------------------------------------------------- | :--------------- | :----------------------------------------------------------- |
| `PreToolUse`、`PostToolUse`、`PostToolUseFailure`、`PermissionRequest` | 工具名称         | `Bash`、`Edit|Write`、`mcp__.*`                              |
| `SessionStart`                                               | 会话如何开始     | `startup`、`resume`、`clear`、`compact`                      |
| `SessionEnd`                                                 | 会话为什么结束   | `clear`、`logout`、`prompt_input_exit`、`bypass_permissions_disabled`、`other` |
| `Notification`                                               | 通知类型         | `permission_prompt`、`idle_prompt`、`auth_success`、`elicitation_dialog` |
| `SubagentStart`                                              | 代理类型         | `Bash`、`Explore`、`Plan` 或自定义代理名称                   |
| `PreCompact`                                                 | 什么触发了压缩   | `manual`、`auto`                                             |
| `SubagentStop`                                               | 代理类型         | 与 `SubagentStart` 相同的值                                  |
| `ConfigChange`                                               | 配置源           | `user_settings`、`project_settings`、`local_settings`、`policy_settings`、`skills` |
| `UserPromptSubmit`、`Stop`、`TeammateIdle`、`TaskCompleted`、`WorktreeCreate`、`WorktreeRemove` | 不支持匹配器     | 始终在每次出现时触发                                         |



## type

### command

hook出发后执行命令。

```
------------------------------------------------
windows

{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "powershell.exe -Command \"[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('Claude Code needs your attention', 'Claude Code')\""
          }
        ]
      }
    ]
  }
}
```





### prompt

对于需要判断而不是确定性规则的决策，使用 `type: "prompt"` hooks。Claude Code 不运行 shell 命令，而是将你的提示和 hook 的输

入数据发送给 Claude 模型（默认为 Haiku）来做决策。如果你需要更多能力，可以使用 `model` 字段指定不同的模型。模型的唯一工作

是返回一个是/否决策作为 JSON：

- `"ok": true`：操作继续
- `"ok": false`：操作被阻止。模型的 `"reason"` 被反馈给 Claude，以便它可以调整。

此示例使用 `Stop` hook 来询问模型是否所有请求的任务都已完成。如果模型返回 `"ok": false`，Claude 继续工作并使用 `reason` 作为

其下一条指令：

```
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Check if all tasks are complete. If not, respond with {\"ok\": false, \"reason\": \"what remains to be done\"}."
          }
        ]
      }
    ]
  }
}
```





### agent

当验证需要检查文件或运行命令时，使用 `type: "agent"` hooks。与只进行单个 LLM 调用的提示 hooks 不同，代理 hooks 生成一个 

subagent，它可以读取文件、搜索代码和使用其他工具来在返回决策前验证条件。

代理 hooks 使用与提示 hooks 相同的 `"ok"` / `"reason"` 响应格式，但默认超时更长（60 秒）和最多 50 个工具使用轮次。此示例验证

在允许 Claude 停止之前测试通过：

```
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "agent",
            "prompt": "Verify that all unit tests pass. Run the test suite and check the results. $ARGUMENTS",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```



当 hook 输入数据本身足以做决策时使用提示 hooks。当你需要根据代码库的实际状态验证某些内容时使用代理 hooks。











# hook脚本



## 输入

Hooks 通过 stdin获取claude传递给hook的输入信息。

输入信息为json格式，不同事件的输入不一样。



案例：PreToolUse触发的输入：

```
{
  "session_id": "abc123",          // 此会话的唯一 ID
  "cwd": "/Users/sarah/myproject", // 事件触发时的工作目录
  "hook_event_name": "PreToolUse", // 哪个事件触发了此 hook
  "tool_name": "Bash",             // Claude 即将使用的工具
  "tool_input": {                  // Claude 传递给工具的参数
    "command": "npm test"          // 对于 Bash，这是 shell 命令
  }
}
```



## 输出

退出代码确定接下来会发生什么：

- **Exit 0**：操作继续。对于 `UserPromptSubmit` 和 `SessionStart` hooks，你写入 stdout 的任何内容都会添加到 Claude 的上下文中。
- **Exit 2**：操作被阻止。写入原因到 stderr，Claude 会收到它作为反馈，以便它可以调整。
- **任何其他退出代码**：操作继续。Stderr 被记录但不显示给 Claude。使用 `Ctrl+O` 切换详细模式以在转录中查看这些消息。



案例：一个想要阻止命令的 `PreToolUse` hook

```
#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

if echo "$COMMAND" | grep -q "drop table"; then
  echo "Blocked: dropping tables is not allowed" >&2  # stderr 变成 Claude 的反馈
  exit 2 # exit 2 = 阻止操作
fi

exit 0  # exit 0 = 让它继续
```





## 结构化JSON输出

退出代码给你两个选项：允许或阻止。为了获得更多控制，退出 0 并改为打印特定 JSON 对象到 stdout。



注意：

使用 exit 2 通过 stderr 消息阻止，或使用 exit 0 和 JSON 进行结构化控制。

不要混合它们：当你退出 2 时，Claude Code 会忽略 JSON。





例如，`PreToolUse` hook 可以拒绝工具调用并告诉 Claude 为什么，或将其升级给用户以获得批准

```
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Use rg instead of grep for better performance"
  }
}
```

不同的事件，json结构话输出的字段以及字段选项不一样。以下三个选项特定于 `PreToolUse`：

- `"allow"`：继续而不显示权限提示
- `"deny"`：取消工具调用并将原因发送给 Claude
- `"ask"`：照常向用户显示权限提示



# 事件

## Notification

**触发时机**

当 Claude 等待输入或或需要权限时，以及等待用户确认事触发。

```
------------------------------------------------
windows

{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "powershell.exe -Command \"[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('Claude Code needs your attention', 'Claude Code')\""
          }
        ]
      }
    ]
  }
}
```







## PreToolUse

Tool使用前。



### matcher

| 事件         | 匹配器过滤的内容 | 示例匹配器值                    |
| :----------- | :--------------- | :------------------------------ |
| `PreToolUse` | 工具名称         | `Bash`、`Edit|Write`、`mcp__.*` |





### **json结构化输出**

```
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Use rg instead of grep for better performance"
  }
}
```



**permissionDecision**

- `"allow"`：继续而不显示权限提示
- `"deny"`：取消工具调用并将原因发送给 Claude
- `"ask"`：照常向用户显示权限提示



## PostToolUse

Tool使用后。







# 官方插件

## hookify

通过对话的方式创建钩子。

把你的操作规范变成自动触发的提醒或拦截规则。



**工作机制**

Hookify 会挂在几个时机上：

- UserPromptSubmit：你提交提示时
- PreToolUse：工具执行前
- PostToolUse：工具执行后
- Stop：Claude 准备结束时



**规则文件**

它读取 .claude/hookify.*.local.md

如果规则匹配，就根据 action 选择：
- warn：警告但允许继续
- block：直接阻止



**文件案例**

```
name: 规则名
enabled: true。是否启用，true或false
event: bash | file | stop | prompt | all
pattern: rm\s+-rf
action：warn 或 block。建议先用 warn，确认不误伤后再改成 block
```

 

**使用步骤**

  - 第一步：执行
    /hookify Warn me when I try to use rm -rf
  - 第二步：让 Claude 尝试相关命令，验证是否触发
  - 第三步：按需编辑 .claude/hookify.*.local.md



**使用案例**

```
/hookify Don't use console.log in production files
```



**列出规则**

```
/hookify:list
```



**查看帮助**

```
/hookify:help
```



**启用/禁用**

/hookify:configure

