# 记忆索引

> 热记忆，每次对话注入。只放索引，不放正文。硬上限 2000 字符。

## 温记忆目录

**稳定型（按需读）**
- `偏好设置记忆.md` — 按场景生效的偏好 + Markdown 笔记格式规范
- `用户相关记忆.md` — 用户是谁、背景、风格、习惯
- `用户反馈记忆.md` — 用户纠正过什么、期望怎么表现
- `参考文档记忆.md` — 外部资料摘要 + 出处链接

**演进型（项目任务开始时读）**
- `项目相关记忆.md` — 本项目约定、环境事实、沉淀输出目录约定
- `learnings/learnings.md` — 验证过有效的做法
- `learnings/errors.md` — 踩过的坑 + 原因 + 正确做法
- `learnings/feature-requests.md` — 现有能力覆盖不到、需要补的东西

## 冷记忆检索入口

历史全文与摘要存在 `.agents/history/memory.db`。

- `search_summary(关键词)` — 先搜摘要
- `search_history(关键词)` — 摘要不够再搜原始历史
- `get_summary(daily, YYYY-MM-DD)` — 取某天快照

**什么时候搜**：用户提到「之前」「上次」「以前定过」，或当前判断需要历史依据时。

每次检索会自动记一条 `search_log`——这是「同一主题命中 ≥ 3 次就提炼进温记忆」的判定依据。

## 技能在哪

**技能不进索引**——数量会长，热记忆的 2000 字符容不下。技能见 `.agents/skills/`，需要时列目录。每个技能自己的来源、适用场景写在它的 `SKILL.md` 里。

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

**流程**：检索 → 读 `SKILL.md` → 过 `.agents/prompts/skillguard.md` 扫描 → 写入 `.agents/skills/<名称>/`（`SKILL.md` 里记下来源 URL）。
**只装运行必需文件。首次安装前向用户确认。**
**沉淀或完善技能，交给 `skill-creator-plus` 走流程**——它是造技能的元技能（评审门 ≥95% + 测试门）。**不要自己手写 skill 骨架。**

**维护手段**：宿主提供 `skill_create` / `skill_patch` / `skill_delete` / `skill_write_file` / `skill_delete_file`。写操作一律限定在 `.agents/skills/<名称>/` 内，不允许越界写；落盘前过扫描。**删除技能走人工确认**（不同于 SkillGuard 命中的自动删除）。

**主动修补**：

```text
在使用技能并发现它过时、不完整或错误时，立即修补它，
不要等着被要求。不维护的技能会变成负担。
```
