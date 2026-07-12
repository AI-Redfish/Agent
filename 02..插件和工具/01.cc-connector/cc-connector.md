# cc-connector

仓库：`https://github.com/openai/codex-plugin-cc`

# 安装

1. 先准备环境：
   已安装 codex CLI。
   已安装 Node.js 18.18+。
2. 安装cc-connect。
   npm install -g cc-connect@beta
3. 验证安装：cc-connect --version
4. 在用户目录下创建 .cc-connect\config.toml
5. 添加config.toml内容如下：
```
[log]
level = "info"

[[projects]]
name = "wechat-ai"
# 【请修改这里】改成你电脑上项目的绝对路径，例如：
work_dir = "C:/Users/Administrator/Desktop/AgentDemo"

[projects.agent]
type = "codex"

[[projects.platforms]]
type = "weixin"

[projects.platforms.options]
token = ""
```
6. 配置微信
```
cc-connect weixin setup
```
这一步成功后，你的终端就会弹出二维码。用手机微信扫码确认，就完成授权了。
7. 启动服务。
```
cc-connect
```
8. 开始对话。


