# ~/.openclaw/agents/cid/

每个会话(Conversation)的状态和配置存储目录。`<cid>` 是会话 ID,每个会话都有独立的配置空间。

```
~/.openclaw/agents/<cid>/
├── agent/
│   ├── auth-profiles.json    # 该会话的 OAuth 和 API 密钥
│   └── ...
└── ...
```



## **auth-profiles.json**

存储该智能体使用的 API 认证信息，包含各个服务的 OAuth token。

新版本使用此路径,旧版本存储在 `~/.openclaw/credentials/`。



每个会话的认证信息相互独立，可以为不同会话配置不同的 API 密钥。

支持多智能体并行运行。



