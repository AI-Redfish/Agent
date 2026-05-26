# Ralph 插件说明

**claude code是否可以通过提示词，持续24h执行?**

Claude Code 的默认行为是“单次运行”模式。它的底层逻辑是：接收指令 → 执行 → 自我评估 → 停止。

当它认为任务“足够好”或者需要人工确认时，就会主动停止。这是一个内置的、结构性的行为，仅靠提示词（如“请持续优化”）很难从根

本上改变，因为它会根据自己的判断来决定何时“完成”，而不是严格遵守你的“不停止”指令。



Ralph 可以把 Claude Code 变成“持续执行”的代理：它会反复检查任务状态、继续推进、失败后重试，更适合耗时较长、步骤较多、需要

尽量少人工盯着的任务。





**适用场景**

- 长时间执行的开发任务
- 需要自动继续推进的多步骤任务
- 希望 Claude 在一次指令后持续工作
- 夜间挂机、批量修复、持续重试类任务



不太适合：

- 单个很小的修改
- 只想临时问一个问题
- 需要你每一步都手动确认的场景



# 原理

技术上，它的本质就是一个 Bash 循环：

```text
while :; do cat PROMPT.md | claude ; done
```

反复给AI同一个指令，直到任务被最终完成。



具体工作流程是这样的：

1. 注入Prompt：喂一个定义了明确成功标准的任务文件
2. 执行任务：Claude修改代码、跑测试
3. 拦截退出：用Stop hook 挡住Claude的“下班”企图
4. 循环重置：如果未达完成条件，重读Prompt，保留文件和Git历史作为上下文，再来一轮

每一轮都能看到上轮变更，AI基于失败经验改进。



# 安装

```
# 添加官方插件市场源，claudecode官方市场本身就有不需要添加。
# /plugin marketplace add claude-plugins-official

# 安装 Ralph 插件。
/plugin install ralph-loop@claude-plugins-official

# Ralph依赖jq这个命令，windows自身没有，让claudeCode安装下。
# 另外，jq命令只在powershell中有，因此windows环境下建议使用powershell。
claudeCode: 我的windows电脑没有jq这个命令，麻烦帮我安装下。

 /ralph-loop:ralph-loop "用Next.js + Tailwind CSS做一个todolist程序，你要写好测试用例，测试用例都通过后，最终网站要能正常使用" --max-iterations 20 --completion-promise "<promise>MISSION_COMPLETE</promise>"

 /ralph-loop:ralph-loop "获取当前时间并输出，直到时间超过21.58。一旦时间抵达输出<promise>Finish<promis>" --completion-promise "Finish" --max-iterations 10
```

两个关键参数： --max-iterations 20：安全阀，防止无限循环烧钱 。没有默认值，建议设置。

--completion-promise：完成契约，Claude 输出这个字符串时循环才停。建议设置。



**参考使用方式**

```
 /ralph-loop:ralph-loop 监听 "logs/app.log 文件。

任务逻辑：
1. 实时监控日志文件的最新内容。
2. 如果检测到 "ERROR" 或 "CRITICAL" 关键词：
   - 立即读取报错堆栈。
   - 分析原因（例如：端口占用、语法错误、超时时间太短）。
   - 自动修改源代码 (app.py) 或配置文件 (config.json) 以修复问题。
   - 执行重启命令 (python app.py)。
3. 如果日志显示 "Server started successfully"，则继续监听，不做操作。

终止条件：
- 如果日志中出现 "Shutting down gracefully" 或 "Service stopped"，说明服务已停止，请结束循环任务。
- 如果连续 5 次尝试修复后服务仍然在 10 秒内崩溃，请停止并报告“无法自动修复”。

现在，请开始后台运行并输出你的修复日志。""
```



 **直接让 Ralph 持续执行一个任务**

```bash
 /ralph-loop:ralph-loop "帮我重构当前项目的登录模块，并在完成后自行运行相关测试。"
```



**用于大任务或长任务**

```bash
 /ralph-loop:ralph-loop "为当前仓库补齐 README、接入测试、修复 lint 报错，并在完成后汇总改动。"
```

这类任务非常适合 Ralph，因为它不是一步就结束，而是会持续推进多个阶段。



# 推荐提示词写法

为了让 Ralph 更稳定，建议你的任务描述写得更明确一些。

**模板 1：开发任务**

```text
请在当前项目中实现 xxx 功能。
要求：
1. 先分析相关代码结构
2. 再完成实现
3. 完成后运行相关测试
4. 若测试失败则继续修复
5. 最后总结改动点
```

**模板 2：修 Bug**

```text
请定位并修复当前项目中的 xxx 问题。
要求：
1. 先复现问题
2. 找到根因
3. 修复后执行验证
4. 如果验证失败则继续迭代
5. 最后说明原因与修改文件
```

**模板 3：批量整理**

```text
请整理当前仓库。
要求：
1. 修复明显报错
2. 删除无用代码
3. 补充缺失文档
4. 运行可执行的检查命令
5. 输出最终结果
```
