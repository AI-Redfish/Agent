# 概述

主配置文件（最重要！）。

存储全局设置（模型、渠道、Gateway 模式、绑定地址、Agents 默认值、插件等）。



**重启**

修改配置后需重启网关服务生效。



# 相关命令

```
# 显示openclaw.json完整路径
openclaw config file

openclaw config get <json路径>

openclaw config set <json路径> <值>

openclaw config validate
```



# 完整结构案例

```
{
  "models": {
    "mode": "merge",
    "providers": {
      "服务商名称": {
        "baseUrl": "API地址",
        "apiKey": "你的密钥",
        "api": "协议类型",
        "models": []
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "服务商名称/模型id",
        "fallbacks": ["备用服务商名称/模型id"]
      },
      "models": {
        "服务商名称/模型id": { "alias": "别名" }
      },
      "imageModel": {
        "primary": "服务商名称/模型id"
      },
      "thinkingDefault": "low",
      "verboseDefault": "off",
      "elevatedDefault": "on",
      "timeoutSeconds": 600,
      "contextTokens": 200000
    }
  },
  "gateway": {
    "mode": "local",
    "port": 18789,
    "auth": {
      "mode": "token",
      "token": "123456"
    }
  },
  "telegram": {
    "enabled": true,
    "botToken": "你的BotToken"
  },
  "memory": {},
  "session": {}
}
```





# **models**

AI 模型配置，默认模型设置。API 认证信息。

```
{
  "models": {
    "mode": "merge",
    "providers": {
      "服务商名称": {
        "baseUrl": "API地址",
        "apiKey": "你的密钥",
        "api": "协议类型",
        "models": []
      }
    }
  }
}
```



- `mode`：`merge` 表示和已有配置合并，`replace` 表示完全替换
- `providers`：服务商列表，可以同时配置多个服务商
- 每个服务商下：
  - `baseUrl`：API 地址
  - `apiKey`：你的密钥
  - `api`：调用协议，**OpenAI GPT 模型必须用 `openai-responses`**，Claude 用 `anthropic-messages`
  - `models`：该服务商下可用的模型列表







# gateway

```
{
  "gateway": {
    "mode": "local",
    "port": 18789,
    "bind": "127.0.0.1",
    "token": "c9917c5a066beeb26266d09baed99495e7563b33c771e89a"
  }
}
```



## 基本配置

**port**

网关端口号(默认 18789)。



**bind**

绑定地址(默认 127.0.0.1)。



**token**

访问令牌,用于 Web UI 认证。



## mode

网关模式。一般用local即可。













# messages

 消息处理配置。

如，TTS(文本转语音)设置，消息格式配置。
