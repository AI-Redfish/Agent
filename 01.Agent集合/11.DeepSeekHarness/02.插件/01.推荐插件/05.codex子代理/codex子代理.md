# 安装

```
# 安装 Codex 子代理 Bundle
pnpm dsh plugin --profile web add @deepseek-ai/dsh-subagent-codex

# 安装 Claude Code 子代理 Bundle
pnpm dsh plugin --profile web add @deepseek-ai/dsh-subagent-claude-code
```



**修改cordis.patch.yml**

位置：~/.dsh/profilex/web/cordis.patch.yml

```

```





# 对话中使用

```
请用 codex_review 审查 src/main.py
请用 codex_auto 自动修复 src/utils.py 的代码风格问题
请用 claude_code 帮我生成单元测试
```



