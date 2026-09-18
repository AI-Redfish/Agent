

# 概述

执行一次性问答后输出结果并退出。

Print 模式（-p）非常适合集成到脚本和 CI 流程中。

# 案例

```
# 一次性问答，输出后退出
pi -p "总结一下这个代码库"

# 管道输入：将文件内容传给 AI
cat README.md | pi -p "总结这段文字"

# 带图片的一次性问答
pi -p @screenshot.png "这张图里有什么"

# 命名会话（方便之后继续）
pi --name "代码审查" -p "审查 src/ 目录下的代码"

# 只读模式（不允许修改文件）
pi --tools read,grep,find,ls -p "审查代码不修改"



```



# 指定模型

```
$ pi --provider openai --model gpt-4o -p "帮我重构这段代码的逻辑"
# 合并写法
$ pi --model openai/gpt-4o -p "帮我重构这段代码的逻辑"
# 模型名后加冒号和推理等级，可以控制这次调用的思考深度
$ pi --model sonnet:high -p "这个复杂的算法有什么潜在问题"
```



#  工具控制

```
# Pi Agent 在非 Windows 平台内置 7 个工具：read、write、edit、bash、grep、find、ls。
# 用 --tools 做白名单，只保留指定工具
$ pi --tools read,grep,find,ls -p "审查代码不修改"
#  排除指定工具
$ pi --exclude-tools bash -p "分析代码但不执行命令"
# 禁用全部内置工具，AI 只能基于对话内容回答，扩展和自定义工具仍然可用
$ pi --no-builtin-tools -p "纯问答"
```





# JSON 模式

JSON 模式将所有事件以 JSON 行（JSONL）格式输出，适合程序解析和处理。

```
$ pi --mode json "总结项目结构"
{"type":"session","version":3,"id":"019f8c2e-7a41-7b3d-9e5f-2c6a1d84b0e7","timestamp":"2026-08-31T02-40-11-000Z","cwd":"/Users/runoob/projects/runoob-demo"}
{"type":"agent_start"}
{"type":"turn_start"}
{"type":"message_start","message":{...}}
{"type":"message_update","usage":{...},"assistantMessageEvent":{...}}
{"type":"message_end","message":{...}}
{"type":"turn_end","message":{...},"toolResults":[]}
{"type":"agent_end","messages":[...]}
```

首行是会话元数据头，记录格式版本、会话 ID、时间戳和工作目录。

之后的每一行都是一个独立的 JSON 事件，包含事件类型和对应的数据。









