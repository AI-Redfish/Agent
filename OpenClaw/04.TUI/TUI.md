# 启动TUI

```
# 打开终端版聊天界面 ，默认连本地正在运行的 Gateway。
openclaw tui

# 打开终端 TUI，但不连本地，而是连接远程 Gateway。
openclaw tui --url ws://<host>:<port> --token <gateway-token>

# 如果 Gateway 使用密码鉴权
openclaw tui --url ws://<host>:<port> --password <password>
```



**启动选项**

| 参数                    | 说明                   | 默认值                              |
| :---------------------- | :--------------------- | :---------------------------------- |
| `--url <url>`           | Gateway WebSocket 地址 | 读取配置或 `ws://127.0.0.1:<port>`  |
| `--token <token>`       | Gateway Token 鉴权     | —                                   |
| `--password <password>` | Gateway 密码鉴权       | —                                   |
| `--session <key>`       | 指定 Session           | `main`                              |
| `--deliver`             | 启动时开启消息投递     | 默认关闭                            |
| `--thinking <level>`    | 覆盖思考级别           | —                                   |
| `--history-limit <n>`   | 加载历史条数           | 200                                 |
| `--timeout-ms <ms>`     | Agent 超时时间         | 读取 agents.defaults.timeoutSeconds |



# 斜杠命令

```
/help                          # 查看帮助
/status                        # 查看连接状态
/agent <id>                    # 切换 Agent
/session <key>                 # 切换 Session
/model <provider/model>        # 切换模型（如 /model anthropic/claude-sonnet-4-6）
/think <off|minimal|low|medium|high>   # 设置思考深度
/deliver <on|off>              # 开启/关闭消息投递到 Provider
/new                           # 重置当前 Session
/abort                         # 中止当前运行
/exit                          # 退出 TUI
```



# 本地 Shell 命令

在输入框以 `!` 开头，可以直接执行本地 shell 命令：

```
!ls -la          # 列出当前目录
!cat log.txt     # 查看文件内容
```



# 键盘快捷键

| 快捷键   | 功能                                 |
| :------- | :----------------------------------- |
| `Enter`  | 发送消息                             |
| `Esc`    | 中止当前运行                         |
| `Ctrl+C` | 清空输入（连按两次退出）             |
| `Ctrl+D` | 退出 TUI                             |
| `Ctrl+L` | 打开模型选择器                       |
| `Ctrl+G` | 打开 Agent 选择器                    |
| `Ctrl+P` | 打开 Session 选择器                  |
| `Ctrl+O` | 切换工具输出展开 / 折叠              |
| `Ctrl+T` | 切换 Thinking 显示（会重新加载历史） |





### 