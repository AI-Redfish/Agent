# 概述

ClawHub 技能仓库地址：https://clawhub.ai/

ClawHub 国内镜像：https://skillhub.tencent.com/



**路径**

```
~/.openclaw/skills/
```



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

