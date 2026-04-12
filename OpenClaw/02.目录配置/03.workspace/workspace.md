# 概述

OpenClaw 的默认工作目录,所有 AI 生成的文件、临时文件和用户请求的输出文件都保存在此。

```
~/.openclaw/
├── openclaw.json                 # 主配置文件（JSON/JSON5）
├── workspace/                    # 你的 AI “灵魂”文件夹（推荐 git 版本控制）
│   ├── SOUL.md                   # 人格设定（语气、风格）
│   ├── USER.md                   # 你的个人偏好和背景
│   ├── MEMORY.md                 # 长期记忆（手动可编辑）
│   ├── IDENTITY.md               # Agent 名称、形象
│   ├── AGENTS.md                 # 多 Agent 路由规则，指令说明。
│   ├── BOOT.md                   # 启动配置
│   ├── HEARTBEAT.md              # heartbeat,每日检查清单 
│   └── skills/                   # 已安装技能（每个技能一个子文件夹）
├── agents/<cid>/                 # 每个 Agent 的独立状态目录。（<cid> 为实例 ID）
├── agents/<cid>/agent/auth-profiles.json
								  # API Key & OAuth 凭证（新版推荐位置），旧版可能在 ~/.openclaw/credentials/
├── credentials/                  # API Key、OAuth（旧版）
├── memory/<cid>.sqlite           # 向量记忆库
├── skills/                       # 全局技能包
└── secrets.json                  # 加密凭证（可选）

/tmp/openclaw/*.log				  # Gateway 服务日志（调试用）
```



默认情况下,AI 只能访问此目录及其子目录，若需访问其他路径,需要配置 `filesystem-mcp` 技能并授予额外权限。



**建议**

定期清理不需要的临时文件。

重要输出建议备份到工作区外。

可以在此建立项目子目录进行组织管理。







# USER.md

**路径**

通常位于工作区或用户自定义位置



**说明** 

用户信息文件,包含关于用户的个性化信息,帮助 AI 更好地理解用户需求。



**内容示例**

- 用户偏好设置
- 常用工作流程
- 项目背景信息
- 自定义指令





