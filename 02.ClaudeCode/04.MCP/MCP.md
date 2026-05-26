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











