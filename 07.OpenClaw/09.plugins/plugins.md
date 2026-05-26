# 概述

插件是轻量代码模块，可通过新增命令、工具及 Gateway RPC 能力，为 OpenClaw 拓展额外功能。



查看已加载插件

```
openclaw plugins list
```

安装官方插件（示例：语音通话插件）

```
openclaw plugins install @openclaw/voice-call
```

插件安装后重启网关生效

```
openclaw gateway restart
```