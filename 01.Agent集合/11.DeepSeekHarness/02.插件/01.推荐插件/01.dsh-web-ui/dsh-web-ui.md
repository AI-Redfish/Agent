# 安装

```
# 1. 克隆仓库
git clone https://github.com/zhu1090093659/dsh-web-ui.git
cd dsh-web-ui

# 2. 安装依赖并构建
pnpm install
pnpm -r build

# 3. 把全家桶链接进 web profile（推荐，先链接全部子包再注册聚合包）
node scripts/link-profile.mjs
# 进入dsh源码安装目录
cd XXX/deepseek-harness
pnpm dsh plugin --profile web add link:dsh-web-ui源码所在目录/packages/dsh-web-ui-all


# 4. 重启 dsh web，侧边栏即可看到全部插件入口
pnpm dsh web
```

单独安装某个插件

```
dsh plugin --profile web add @linxin666/dsh-liangshen              # 梁神模式
dsh plugin --profile web add @linxin666/dsh-client-ui-task-board   # 任务看板
dsh plugin --profile web add @linxin666/dsh-ssh                    # 远程连接（SSH）
dsh plugin --profile web add @linxin666/dsh-tool-describe-image    # 图像理解工具
dsh plugin --profile web add @linxin666/dsh-pet                    # 鲸鱼娘宠物
```



**重启 dsh web**

侧边栏出现全部插件入口



# 卸载

```
# 卸载
pnpm pnpm dsh plugin --profile web remove @linxin666/dsh-web-ui-all

# 重启
pnpm dsh web
```



# 梁神模式

通过“两阶段启动”策略，解决了 DeepSeek V4 Pro 模型在任务初期因工具集过大而产生的性能不稳定问题。

在保留完整能力的同时，稳定地将实测性能从 92 分提升至 98-99 分。





# 任务看板

**创建任务**

设置权限会失败，只能用默认。







































