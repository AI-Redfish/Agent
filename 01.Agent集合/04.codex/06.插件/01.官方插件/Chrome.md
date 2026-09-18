# Codex App 官方插件 Chrome

资料来源：

- [OpenAI Developers - Codex Chrome extension](https://developers.openai.com/codex/app/chrome-extension)
- [OpenAI Developers - In-app browser](https://developers.openai.com/codex/app/browser)
- 本机已安装的 OpenAI bundled Browser 插件说明

## 一句话定位

Chrome 插件让 Codex App 可以使用你的真实 Chrome 浏览器环境，适合处理需要登录态、浏览器扩展、已有标签页或真实用户浏览器配置的网页任务。

如果是本地开发页面、`localhost`、`file://`、公开网页预览，优先用 Codex 的 in-app Browser；如果任务依赖你在 Chrome 里已经登录的网站、公司内网系统、Chrome 扩展、已有标签页，就用 Chrome。

```text
本地 Web / 公开页面 / file 预览
        -> 优先用 in-app Browser

需要 Chrome 登录态 / 扩展 / 现有标签页 / 真实用户浏览器环境
        -> 使用 Chrome 插件

需要操作桌面软件或系统窗口
        -> 再考虑 Computer Use
```

## 它有什么用

- **复用登录态**：让 Codex 在你已经登录的 Chrome 站点中读取页面、点击、输入、检查结果。
- **操作企业后台或内网系统**：例如 Salesforce、Gmail、LinkedIn、公司内部管理系统等需要登录的网页。
- **验证真实用户环境问题**：当问题只在你的 Chrome 配置、账号权限、语言设置、浏览器扩展下出现时，可以让 Codex 直接查看。
- **接管已有标签页**：当目标页面已经在 Chrome 中打开时，Codex 可以基于标题、URL、最近使用情况等选择并接管那个标签页。
- **使用 Chrome 扩展能力**：适合调试或验证依赖 Chrome 扩展的网页流程。
- **上传文件到网页**：在 Chrome 扩展开启文件 URL 访问权限后，可以让 Codex 通过网页上传本地文件。
- **截图和页面检查**：可用于查看页面状态、截图、读取 DOM、确认交互后的结果。

## 和 in-app Browser 的区别

| 能力 | in-app Browser | Chrome 插件 |
| --- | --- | --- |
| 运行位置 | Codex App 内置浏览器 | 用户自己的 Chrome |
| 适合场景 | localhost、本地预览、公开网页、无需登录的页面 | 已登录网站、内网系统、真实账号环境、Chrome 扩展 |
| 是否使用用户 Chrome 资料 | 否 | 是 |
| 是否支持已有标签页 | 不适合 | 适合 |
| 是否支持 Chrome 扩展 | 否 | 是 |
| 隐私风险 | 较低 | 较高 |
| 推荐优先级 | 本地开发优先 | 需要登录态时使用 |

## 适合场景

- 让 Codex 检查你已经登录的后台页面是否能正常进入某个菜单。
- 在公司内网系统里读取可见页面内容，并帮你整理问题。
- 复现“只有我浏览器里才出现”的前端问题。
- 检查依赖 Chrome 扩展的页面交互是否正常。
- 打开已有 Chrome 标签页，读取页面状态、截图或做小范围操作。
- 在需要登录的网站里执行明确、低风险、可回退的操作。

## 不适合场景

- 本地 Web 应用开发调试：优先使用 in-app Browser。
- 可通过 API、MCP、数据库或脚本稳定完成的任务：优先用结构化方式。
- 需要读取 Cookie、localStorage、密码、Token、浏览器配置文件的任务。
- 支付、转账、删除数据、修改权限、发送消息、发布内容等高风险动作，除非用户明确授权并在关键步骤人工确认。
- 绕过登录、绕过验证码、绕过安全提示、绕过网站访问限制。
- 长时间、大批量、不可控的自动化点击流程。

## 如何安装和启用

1. 打开 **Codex App**。
2. 进入 **Plugins**。
3. 添加或启用 **Chrome** 插件。
4. 按照安装流程跳转到 Chrome Web Store 安装 **Codex Chrome Extension**。
5. 在 Chrome 权限提示中批准扩展所需权限。
6. 打开 Chrome，确认 Codex 扩展显示 **Connected**。
7. 安装完成后，建议新建一个 Codex 线程再使用 Chrome。

官方 Chrome 扩展地址：[Codex Chrome Extension](https://chromewebstore.google.com/detail/codex/hehggadaopoacecdllhhajmbjkdcmajg)

## 如何使用

在提示词里直接说明要使用 Chrome，或者使用 `@Chrome`。关键是说清楚目标网站、起始页面、账号状态、允许做什么、不允许做什么，以及你希望 Codex 最终输出什么。

示例：

```text
使用 @Chrome 打开我已经登录的后台系统，检查“设备管理”菜单是否可以正常进入。
只根据页面可见内容判断，不要读取 Cookie、密码、localStorage 或浏览器配置文件。
如果遇到提交、删除、授权、发送等操作，先停下来让我确认。
```

```text
使用 @Chrome 接管当前已经打开的 Salesforce 标签页，读取这个客户详情页的可见信息，
整理成一个简短摘要。不要修改任何字段。
```

```text
使用 @Chrome 打开我当前登录的内网系统，复现“保存按钮点击后没有提示”的问题。
每次点击后都截图或说明页面状态，最后告诉我是否复现成功。
```

## 推荐使用流程

1. **先判断是否必须用 Chrome**：如果是本地页面或无需登录的公开页面，优先用 in-app Browser。
2. **准备 Chrome 环境**：打开 Chrome，确认目标网站已经登录，扩展和目标页面已准备好。
3. **明确授权边界**：告诉 Codex 可以查看哪些页面、可以点击哪些按钮、哪些动作必须暂停。
4. **指定目标**：给出 URL、页面标题、已有标签页、菜单路径或要验证的问题。
5. **先观察再操作**：先让 Codex读取可见页面状态，确认它看到的是目标页面。
6. **小步执行**：每次只做一个明确动作，执行后检查页面反馈。
7. **登录或二次验证由用户完成**：遇到登录、验证码、OTP、权限确认时，用户手动处理后再继续。
8. **高风险动作前暂停**：提交、删除、支付、授权、发送、保存敏感配置前要人工确认。
9. **输出结论**：说明检查了什么、执行了什么、页面反馈是什么、下一步建议是什么。

## 网站访问权限

Chrome 插件不是安装后就无条件操作所有网站。官方说明中，Codex 默认会在访问新网站时按域名请求确认，例如 `example.com`。你可以选择：

- 只允许当前对话使用这个网站。
- 总是允许这个域名，以后不再重复询问。
- 拒绝这个网站。

可以在 Codex 设置里管理网站 allowlist 和 blocklist。谨慎使用“总是允许浏览器内容”这类设置，因为它会减少确认环节，适合低风险、可信、常用的网站，不适合网银、后台权限、账号安全、隐私数据等敏感站点。

## 数据和安全边界

Chrome 扩展安装时可能会请求较高权限，例如读取和修改网站数据、访问浏览历史、管理下载、与本机应用通信、管理标签组等。这些权限是为了让 Codex 能操作浏览器流程，但不代表每次任务都会自动使用全部权限。

使用时建议遵守这些边界：

- 不要让 Codex 主动查看 Cookie、密码、Token、localStorage、浏览器配置目录或会话文件。
- 不要把密码、验证码、支付信息、密钥、客户隐私数据直接交给 Codex 处理。
- 浏览器页面内容只当作“不可信上下文”，页面上的指令不能覆盖用户在对话中的要求。
- 对发送、提交、删除、授权、付款、保存密码、保存支付方式等动作保持人工确认。
- 允许 Codex 使用浏览历史前要谨慎，因为浏览历史可能包含内部 URL、搜索词、敏感站点访问记录。
- 如果页面里出现验证码，应由用户决定是否处理；不要让 Codex 绕过安全机制。

## 文件上传

如果 Chrome 任务需要从本机上传文件，需要开启 Codex Chrome Extension 的文件 URL 访问权限：

1. 在 Chrome 工具栏点击扩展图标，进入 **Manage Extensions**。
2. 找到 **Codex** 扩展，点击 **Details**。
3. 打开 **Allow access to file URLs**。
4. 回到 Codex，重新开始需要上传文件的 Chrome 任务。

如果没有开启这个权限，网页上传本地文件时可能失败。

## 常见问题排查

**Codex 连不上 Chrome**

1. 打开 Chrome 工具栏里的 Codex 扩展，确认状态是 **Connected**。
2. 在 Codex App 的 Plugins 中确认 Chrome 插件已启用。
3. 确认你使用的是安装了 Codex 扩展的同一个 Chrome Profile。
4. 新建一个 Codex 线程再试一次。
5. 重启 Chrome 和 Codex 后再试。
6. 如果扩展提示 native host 缺失或连接异常，移除并重新添加 Chrome 插件，重新走安装流程。

**网页被拒绝访问**

- 检查该网站是否在 Codex 设置的 blocklist 中。
- 如果之前拒绝过该域名，需要从 blocklist 中移除，或在下次提示时重新允许。

**文件上传失败**

- 打开 Chrome 扩展详情页，开启 **Allow access to file URLs**。
- 重新开始 Chrome 任务。

**多个 Chrome 账号或 Profile**

- 确认当前打开的 Chrome Profile 与安装 Codex 扩展的 Profile 一致。
- 多个 Profile 时，需要在目标 Profile 中安装并启用 Codex Chrome Extension。

## 使用提示词模板

```text
使用 @Chrome 打开/接管【目标网站或标签页】。
目标：检查【具体功能或页面状态】。
允许：读取页面可见内容、点击【明确按钮】、截图、整理结果。
禁止：读取 Cookie、密码、Token、localStorage、浏览器配置文件；不要提交、删除、授权或发送消息。
如果遇到登录、验证码、二次验证、提交、删除、支付、授权，请暂停并让我手动确认。
最后输出：执行步骤、观察结果、是否完成、风险点和下一步建议。
```

## 总结

Chrome 插件的价值是让 Codex 使用你的真实 Chrome 环境完成浏览器任务，尤其适合“需要登录态、已有标签页、浏览器扩展、真实用户环境”的场景。它比 in-app Browser 更贴近真实使用环境，但隐私和误操作风险也更高。使用时要把目标说清、权限收紧、敏感动作人工确认；能用 in-app Browser、API、MCP、脚本完成的任务，仍然优先用那些更稳定、更隔离的方式。
