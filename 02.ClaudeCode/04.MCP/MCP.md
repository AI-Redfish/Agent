# 官方文档

https://code.claude.com/docs/zh-CN/mcp#%E5%AE%89%E8%A3%85-mcp-%E6%9C%8D%E5%8A%A1%E5%99%A8



# list

```
claude mcp list
```

查看当前安装了哪些MCP。



# get

获取特定服务器的详细信息。

```
claude mcp get github
```



# remove

删除服务器.

```
claude mcp remove github
```



# 添加MCP

## 命令行添加

Stdio 服务器作为您机器上的本地进程运行。它们非常适合需要直接系统访问或自定义脚本的工具。

```
# 基本语法
claude mcp add [options] <name> -- <command> [args...]

# windows：MCP服务
claude mcp add --scope local files -- cmd /c "npx -y @modelcontextprotocol/server-filesystem C:/Users/redfish/Desktop"
```



**windows环境**

在本机 Windows（不是 WSL）上，使用 `npx` 的本地 MCP 服务器需要 `cmd /c` 包装器以确保正确执行。

```
# CMD窗口：这创建了 Windows 可以执行的 command="cmd"
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package


```

没有 `cmd /c` 包装器，您会遇到”连接已关闭”错误，因为 Windows 无法直接执行 `npx`。（有关 `--` 参数的说明，请参阅上面的注释。）





**选项分隔**

所有选项（`--transport`、`--env`、`--scope`、`--header`）必须位于服务器名称**之前**。然后 `--`（双破折号）将服务器名称与传递给 MCP 服务器的命令和参数分开。例如：

- `claude mcp add --transport stdio myserver -- npx server` → 运行 `npx server`
- `claude mcp add --transport stdio --env KEY=value myserver -- python server.py --port 8080` → 运行 `python server.py --port 8080`，环境中有 `KEY=value`

这可以防止 Claude 的标志与服务器标志之间的冲突。



## json配置添加mcp

如果您有 MCP 服务器的 JSON 配置，可以直接添加它：

```
# 基本语法
claude mcp add-json <name> '<json>'

# 示例：使用 JSON 配置添加 HTTP 服务器
claude mcp add-json weather-api '{"type":"http","url":"https://api.weather.com/mcp","headers":{"Authorization":"Bearer token"}}'

# 示例：使用 JSON 配置添加 stdio 服务器
claude mcp add-json local-weather '{"type":"stdio","command":"/path/to/weather-cli","args":["--api-key","abc123"],"env":{"CACHE_DIR":"/tmp"}}'

# 示例：添加带有预配置 OAuth 凭据的 HTTP 服务器
claude mcp add-json my-server '{"type":"http","url":"https://mcp.example.com/mcp","oauth":{"clientId":"your-client-id","callbackPort":8080}}' --client-secret
```



## 修改配置文件添加

修改如下配置文件，添加mcp对应部分内容。



用户级：C:\Users\<你的用户名>\.claude.json



项目级(推荐)：当前项目下的.mcp.json



本地级：



## 参数

**scope**

```
--scope
```

标志指定配置的存储位置：

- `local`（默认）：仅在当前项目中对您可用（在较旧版本中称为 `project`）
- `project`：通过 `.mcp.json` 文件与项目中的每个人共享
- `user`：在所有项目中对您可用（在较旧版本中称为 `global`）



**transport** 

指定mcp的通信方式。

- 支持：`stdio`、`sse`、`http`
- 默认：`Defaults to stdio if not specified`

```
claude mcp add --transport stdio my-server -- npx my-mcp-server
```





建议指定transport

认虽然是 `stdio`，不代表任何 server 都适合省略。

如果你的 MCP Server 本身是 `http` 或 `sse` 服务，就必须显式写对应的 `--transport`。

否则 Claude 会把它当成 `stdio`，基本就连不上。



**env**

使用 `--env` 标志设置环境变量（例如，`--env KEY=value`）

使用 MCP_TIMEOUT 环境变量配置 MCP 服务器启动超时（例如，`MCP_TIMEOUT=10000 claude` 设置 10 秒超时）

当 MCP 工具输出超过 10,000 个令牌时，Claude Code 将显示警告。要增加此限制，请设置 `MAX_MCP_OUTPUT_TOKENS` 环境变量（例如，`MAX_MCP_OUTPUT_TOKENS=50000`）









# 使用MCP

## 隐式使用

claude code自己根据理解判断是否调用指定MCP。



## 显示调用

```
使用　context7 参考官方文档，吧Rails的版本升级到8.0。
```

以上context7为本地安装的mcp服务名称。 




# cccp
Claude Code 的并行处理引擎。

## 安装
```
# 全局安装
npm install -g mcp-cccp-server

# 验证安装
npx mcp-cccp-server --version
```

或者手动修改.mcp.son文件。
```
# windows环境
{
  "mcpServers": {
    "cccp": {
      "type": "stdio",
      "command": "cmd",
      "args": [
        "/c",
        "npx",
        "-y",
        "mcp-cccp-server"
      ],
      "env": {
        "CCCP_PROVIDER": "api",
        "ANTHROPIC_AUTH_TOKEN": "your-api-key-here",
        "CCCP_API_CONCURRENCY": "4"
      }
    }
  }
}
```

**关键配置参数**

|环境变量   |   默认值  |   说明|
|-------   |   ------  |-------|
|CCCP_PROVIDER  |api	|api(直调API) / claude(通过CLI) / codex(通过Codex)|
|ANTHROPIC_AUTH_TOKEN   |-	|Anthropic API Key（provider=api时必填）|
|CCCP_API_CONCURRENCY	|8	|API模式最大并发数（建议2-4）|
|CCCP_CLI_CONCURRENCY	|2	|CLI模式最大并发数|
|CCCP_AUTO_REPAIR	|true	|失败任务自动重试|
|CCCP_CACHE_TTL_MS	|3600000	|结果缓存时间（1小时）|


<br><br><br>
**核心工具**

安装成功后，Claude Code 中会出现三个 MCP 工具：

|工具名 |功能	|何时使用|
|-------   |   ------  |-------|
|mcp__cccp__parallel_code	|并行执行多个独立任务	|批量处理、同时分析多个文件|
|mcp__cccp__sequential_code	|串行执行，任务间可传递结果 |需要上一步输出作为下一步输入|
|mcp__cccp__ping	|健康检查	|验证 MCP Server 是否正常运行|

<br>

## 使用

**场景1：并行分析多个文件**
```
请用 parallel_code 同时分析 src/ 目录下的 auth.js、api.js、db.js 这三个文件，分别总结它们的主要功能和潜在问题
```

Claude 实际调用的代码：
```
mcp__cccp__parallel_code({
  provider: "api",
  tasks: [
    {
      name: "分析 auth.js",
      task: "分析 src/auth.js 的主要功能和潜在问题"
    },
    {
      name: "分析 api.js",
      task: "分析 src/api.js 的主要功能和潜在问题"
    },
    {
      name: "分析 db.js",
      task: "分析 src/db.js 的主要功能和潜在问题"
    }
  ]
})
```

**场景2：批量生成 API 模块**

```
用 parallel_code 帮我同时生成 User、Product、Order 三个 API 模块的基础代码框架，每个模块包含 CRUD 操作，输出到 src/api/ 目录下
```
参数说明：使用 outputPath 可以让结果自动写入文件，不占用主会话的上下文。
```
mcp__cccp__parallel_code({
  provider: "api",
  tasks: [
    {
      name: "生成 User API",
      task: "生成 User 模块的 CRUD API 代码",
      outputPath: "src/api/user.js"
    },
    {
      name: "生成 Product API",
      task: "生成 Product 模块的 CRUD API 代码",
      outputPath: "src/api/product.js"
    },
    {
      name: "生成 Order API",
      task: "生成 Order 模块的 CRUD API 代码",
      outputPath: "src/api/order.js"
    }
  ]
})
```


***场景3：有依赖关系的任务（串行）***
```
我需要：1. 先读取 database/schema.sql 了解表结构
2. 基于表结构生成 TypeScript 类型定义
3. 基于类型定义生成 CRUD 操作函数
请用 sequential_code 串行执行
```
实际执行的代码
```
mcp__cccp__sequential_code({
  provider: "api",
  tasks: [
    {
      name: "读取 schema",
      task: "读取 database/schema.sql 并总结所有表结构"
    },
    {
      name: "生成类型定义",
      task: "基于上一步的结果，为每个表生成 TypeScript 接口定义"
    },
    {
      name: "生成 CRUD 函数",
      task: "基于上一步的类型定义，生成对应的 CRUD 操作函数"
    }
  ]
})
```
⚠️ sequential_code 会自动将上一步的输出作为 $PREV_RESULT 变量传递给下一步，你只需在 task 中引用即可。

**场景4：健康检查**
```
请用 ping 检查 CCCP MCP Server 是否正常运行
```

## 对比其他并发工具
**subAgent**
subAgent的并发性更好，但是cccp的成本更低。


原因：cccp需要切换进程性能更差。但是cccp完全独立上下文，没有skill，额外mcp的加载，更少的上下文。