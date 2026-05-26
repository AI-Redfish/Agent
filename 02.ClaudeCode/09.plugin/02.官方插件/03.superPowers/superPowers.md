# superPowers

`superPowers` 是 Claude Code 的一组工作流增强技能集合，核心目标不是单纯“增加命令”，而是把一套更规范的开发流程教给 Claude，例如先做需求澄清、系统化调试、TDD、并行分工、代码评审与完成前验证等。

**参考链接**

- 插件页：<https://claude.com/plugins/superpowers>
- 项目仓库：<https://github.com/obra/superpowers>
- 文章链接：<https://gitcode.com/GitHub_Trending/su/superpowers?utm_source=csdn_github_accelerator&isLogin=1&from_link=3f88cd364a02cb16d58e5ca0cd850ae8>



对于简单修改，superPowers插件会导致执行过慢。

**建议仅针对复杂场景安装此插件**。



# 安装与更新

**安装**

可在 Claude Code 插件市场中安装 `superpowers`。

**更新**

```bash
/plugin update superpowers
```



**使用方式**

安装后不一定需要你手动记住全部技能名。通常有两种使用方式：

- 由 Claude 根据当前任务自动匹配合适技能
- 你显式要求 Claude 使用某个 skill

例如，当任务涉及新增功能、调试问题、编写计划、代码评审时，Claude 可能会主动触发对应 skill。



# **主要能力**

从公开资料可确认，`superPowers` 提供的是一组可被 Claude 调用的技能（skills），常见能力包括：

- `brainstorming`：在编写代码前激活。通过提问完善初步想法，探索替代方案，分模块呈现设计方案供验证。保存设计文档。
- `using-git-worktrees`：需要隔离工作区时，指导使用 worktree 进行独立开发
- `writing-plans` / `executing-plans`：基于获批的设计方案激活。将工作分解为小型任务（每个 2-5 分钟）。每项任务包含确切的文件路径、完整代码和验证步骤。
- **subagent-driven-development（子代理驱动开发）** 或 **executing-plans（执行计划）** - 基于计划激活。为每个任务分配全新的子代理，并进行两阶段审查（首先检查是否符合规范，然后检查代码质量）；或者批量执行，并设置人工检查点。
- `test-driven-development`： 在实施过程中激活。强制遵循 RED-GREEN-REFACTOR（红-绿-重构）流程：编写失败的测试，观察其失败，编写最小化代码，观察测试通过，提交代码。删除测试编写前的代码。
- `systematic-debugging`：遇到 bug、失败测试、异常输出时，要求先定位根因再修复
- `requesting-code-review` / `receiving-code-review`：在完成实现后请求审查，或在收到 review 意见后按流程处理
- `verification-before-completion`：在声称“已完成”“已修复”前，先运行验证命令并基于结果结论化
- `writing-skills`：用于创建、修改和验证新的 skill
- finishing-a-development-branch（完成开发分支） - 在任务完成时激活。验证测试，提供操作选项（合并/创建 PR/保留/丢弃），清理工作树。



## brainstorming







