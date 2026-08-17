# 官方地址

https://github.com/zhu1090093659/dsh-web-ui

# 梁神模式

```
pnpm dsh plugin --profile web add @linxin666/dsh-liangshen
```



通过“两阶段启动”策略，解决了 DeepSeek V4 Pro 模型在任务初期因工具集过大而产生的性能不稳定问题。

在保留完整能力的同时，稳定地将实测性能从 92 分提升至 98-99 分。





# Git图谱

```
pnpm dsh plugin --profile web add @linxin666/dsh-client-ui-git-graph
```





# 鲸鱼娘宠物

```
pnpm dsh plugin --profile web add @linxin666/dsh-pet
```





# SSH

```
pnpm dsh plugin --profile web add @linxin666/dsh-ssh
```



**隧道**

链路

```
你的电脑 -> SSH 到「主机别名」对应的服务器 -> 由那台服务器访问「远程主机:远程端口」
```



**Agent 直连**

Agent 和面板共用同一份主机配置，对话里说一句「连一下 xxx 看看状态」，智能体就去执行远程命令。























