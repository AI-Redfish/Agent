# 记忆索引

> 热记忆，每次对话注入。只放索引，不放正文。硬上限 2000 字符。

## 控制入口

会话开始、切换工作空间或重建上下文后检查 `BOOTSTRAP.md`：未执行只问缺项，确认答案落盘并同步索引后标记完成；已完成跳过。`prompts/` 按 `AGENTS.md` 触发，不当作温记忆。`archive/` 仅用户要求恢复／审计时读。

## 温记忆目录

路径相对 `.agents/memory/`，每项给出读取场景。已读且未变更的正文可在当前上下文内复用。

**稳定型**
- `preferences.md` — 场景偏好／Markdown 规范；写文档、查资料或命中偏好场景前读。
- `user-profile.md` — 身份、背景、习惯；个性化建议或涉及用户背景前读。
- `user-feedback.md` — 用户纠正与期望；每个任务开始、用户纠正行为时读。
- `references.md` — 外部资料摘要与出处；调研、技术选型、复用资料前读。

**演进型**
- `project.md` — 项目约定、环境、输出目录；项目任务开始及选择命令／沉淀目录前读。
- `learnings/learnings.md` — 有效做法；选择实现方法、重复操作、技能候选评估前读。
- `learnings/errors.md` — 坑、原因、正确做法；排错、重试、易错操作前读。
- `learnings/feature-requests.md` — 能力缺口；需求规划、能力缺口评估、技能检索前读。

新增正文使用英文小写 kebab-case，登记「内容 + 何时读」；控制文件和归档不补为温记忆索引。

## 冷记忆检索入口

历史全文与摘要存在 `.agents/history/memory.db`。

- `search_summary(关键词)` — 先搜摘要
- `search_history(关键词)` — 摘要不够再搜原始历史
- `get_summary(daily, YYYY-MM-DD)` — 取某天快照

**什么时候搜**：用户提到「之前」「上次」「以前定过」，或当前判断需要历史依据时。

检索自动写 `search_log`，轻整理据此判断同主题命中 ≥3 次后的晋级。

## 技能在哪

技能不进索引。需要时列 `.agents/skills/`；来源和适用场景见各技能的 `SKILL.md`。

## Skill 获取协议

**触发**（满足任一）：同类步骤重复 ≥ 3 次；现有技能覆盖不到且预判会复用；用户明确要求。
**不触发**：一次性任务；内置工具能直接做完的。

**来源**（按优先级）：
1. `npx skills add https://github.com/vercel-labs/skills --skill find-skills`
2. https://github.com/AI-Redfish/skill
3. https://github.com/heilcheng/awesome-agent-skills/blob/main/README.zh-CN.md
4. https://skills.sh/ ／ https://skillsmp.com/ ／ https://agentskill.sh/
5. https://smithery.ai/skills
6. Claw Hub

**流程**：检索 → 读 `SKILL.md` → 过 `.agents/memory/prompts/skillguard.md` 扫描 → 写入 `.agents/skills/<名称>/`（`SKILL.md` 里记下来源 URL）。
**只装运行必需文件。首次安装前向用户确认。**
**沉淀或完善技能，交给 `skill-creator-plus` 走流程**——它是造技能的元技能（评审门 ≥95% + 测试门）。**不要自己手写 skill 骨架。**

**维护手段**：宿主提供技能读写工具；写入限定在 `.agents/skills/<名称>/` 内，落盘前过扫描。删除技能须人工确认；安全扫描失败按安全闸门处理。

**主动修补**：

```text
在使用技能并发现它过时、不完整或错误时，立即修补它，
不要等着被要求。不维护的技能会变成负担。
```
