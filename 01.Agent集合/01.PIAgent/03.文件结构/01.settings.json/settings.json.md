# 配置文件位置

Pi Agent 从两个固定路径读取配置，两者的优先级不同。

| 文件路径                  | 作用范围         | 说明                             |
| :------------------------ | :--------------- | :------------------------------- |
| ~/.pi/agent/settings.json | 全局（所有项目） | 适用于所有项目的通用配置         |
| .pi/settings.json         | 项目级           | 仅对当前项目生效，会覆盖全局配置 |

可以直接编辑 JSON 文件，或使用交互模式中的 **/settings** 命令来修改常用选项。



# 配置合并规则

项目配置（.pi/settings.json）会覆盖全局配置（~/.pi/agent/settings.json）。



嵌套对象采用**合并**而非替换策略，下面用一个例子来说明。

全局配置文件 ~/.pi/agent/settings.json：

```
{
  "theme": "dark",
  "compaction": { "enabled": true, "reserveTokens": 16384 }
}
```

项目配置文件 .pi/settings.json：

```
{
  "compaction": { "reserveTokens": 8192 }
}
```

合并后实际生效的配置中，theme 取全局的 dark，compaction.enabled 取全局的 true，compaction.reserveTokens 被项目配置覆盖为 8192。

也就是说，项目配置只覆盖它显式声明过的字段，其余字段继续沿用全局配置。



