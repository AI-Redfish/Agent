







# Cursor配置

![image-20250510124022444](MCPResource\image-20250510124022444.png)

![image-20250510131737214](MCPResource\image-20250510131737214.png)





```
linux：

{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "."
      ]
    }
  }
}

windows：
{
  "mcpServers": {
    "filesystem": {
      "command": "cmd",
      "args": [
        "/c",
        "npx",
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "C:\\Users\\redfish\\Desktop"
      ]
    }
  }
}
```





