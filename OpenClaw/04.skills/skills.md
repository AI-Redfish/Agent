# 概述

ClawHub 技能仓库地址：https://clawhub.ai/

ClawHub 国内镜像：https://skillhub.tencent.com/







# 快速上手

```
# 安装clawhub CLI
npm install -g clawhub

# 搜索skill
clawhub search skill名称

# 安装skill
clawhub install skill名称

# 验证skill
openclaw skills list
```



**skill配置**

某些 Skills 需要额外的配置（如 API Key）。

```
openclaw skills config <skill-name>
```

或直接编辑配置文件：

```
~/.openclaw/skills/<skill-name>/config.json

{
  "github": {
    "token": "ghp_your_github_token",
    "defaultOrg": "your-org",
    "autoReview": true
  }
}
```



# 相关命令

**查询skill**

```
# 搜索技能
clawhub search <关键词>

# 查看skill详情
clawhub info <skill-name>
```



**安装skill**

```
# 安装技能
npx clawhub install <skill-name>

# 安装特定版本
clawhub install <skill-name>@1.2.3

# 从 GitHub 安装
clawhub install github:username/repo

# clawhub默认安装到默认工作空间，如果要安装到其他工作空间，则需要指定--workdir
# 安装到工作空间的skill可能不会立即生效，目前已直的方式是重启服务。
clawhub install my-skill --workdir C:\path\to\project
```





**更新skill**

```
# 更新所有 Skills
clawhub update

# 更新特定 Skill
clawhub update <skill-name>
```



**卸载skill**

```
clawhub uninstall <skill-name>
```



**管理skill**

```
# 列出已安装
openclaw skills list

输出
✓ browser (v1.2.0) - ready
✓ github (v2.1.5) - ready
✓ weather (v1.0.3) - ready
⚠ calendar (v0.9.1) - error

----------------------

# 禁用 Skill
openclaw skills disable <skill-name>

# 启用 Skill
openclaw skills enable <skill-name>


# 查看特定 Skill 的日志
openclaw logs --skill browser

# 实时查看日志
openclaw logs --skill browser --follow
```





# 常用Skill

## Browser

浏览器自动化。

可以进行的操作，网页访问、网内内容抓取，搜索、抓取、表单操作，网页截图。

```
clawhub install browser --workdir C:\Users\redfish\Desktop\MyOpenCLI

# 打开浏览器，用 Google 搜索 "OpenClaw"
```



## calendar

日程查询、创建事件、提醒。

```
clawhub install calendar --workdir C:\Users\redfish\Desktop\MyOpenCLI

# 明天下午3点提醒我开会
```





## todoist

任务管理、项目组织。

```
clawhub install todoist --workdir C:\Users\redfish\Desktop\MyOpenCLI

# 添加待办事项：完成项目文档
```









