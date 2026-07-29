# Skills

Skills 可以理解成一组可复用的专业能力包。

它不是直接增加一个固定工具，而是把：

- 专门提示词
- 领域知识
- 参考文档
- 脚本或模板

按目录打包起来，在需要时再按需加载给 Agent。


# Skills 是什么

**核心思想**

- 平时不把所有知识一次性塞进上下文
- 只有在任务相关时，才加载对应 skill
- 用渐进式披露（progressive disclosure）减少上下文膨胀


# 和工具的区别

| 对比项 | Skills | Tools |
| :-- | :-- | :-- |
| 本质 | 专业能力包 | 可执行函数 |
| 重点 | 提供知识、提示、流程 | 执行动作 |
| 典型内容 | prompt、文档、模板、脚本 | 查询、写文件、调 API |
| 适合问题 | “怎么做更好” | “帮我做这个动作” |


**理解**

- Tool 更像“手”
- Skill 更像“经验包”


# Skills 的目录结构

官方常见结构是一个目录下放多个 skill 文件夹，每个 skill 文件夹至少有一个 `SKILL.md`。

```text
skills/
├── sql-assistant/
│   ├── SKILL.md
│   ├── template.sql
│   └── notes.md
├── docs-search/
│   ├── SKILL.md
│   └── examples.md
```


**常见组成**

- `SKILL.md`：技能说明、适用条件、使用方法
- 额外脚本：具体可执行逻辑
- 额外文档：知识资料
- 模板资源：SQL 模板、提示词模板、输出模板


# Skills 怎么工作

Deep Agents / Agent 系统通常不会在启动时把所有 skill 全量读入上下文，而是：

1. 先读取各个 `SKILL.md` 的基础信息
2. 接到任务后判断哪个 skill 相关
3. 只有命中时，再读取 skill 的完整内容和附加资源


这就是 Skills 模式最大的价值：

- 节省上下文
- 避免主 Agent 知识过载
- 支持不同团队分别维护不同能力


# Skills 适合什么时候用

## 适合

- 单个 Agent 需要很多专业能力
- 各能力之间主要是知识差异，不一定要拆成多个子 Agent
- 不同团队维护不同领域能力
- 希望按需加载长提示词或长文档


**典型场景**

- SQL 助手
- 法务审阅助手
- 多技术栈代码助手
- 多业务域知识助手


## 不太适合

- 只是单个简单函数调用
- 必须严格隔离上下文和执行链路
- 需要并行调用多个专门执行单元

这种情况通常更适合：

- `tools`
- `subagents`
- `router`


# Skills 和多 Agent 的关系

LangChain 在 multi-agent 里把 Skills 当成一种模式。


**它的特点**

- 仍然是单 Agent 主导
- 不切换控制权
- 不一定生成新的子 Agent
- 只是按需加载专业上下文


# 什么时候选 Skills，什么时候选 Subagents

| 场景 | 更适合 Skills | 更适合 Subagents |
| :-- | :-- | :-- |
| 只需要补专业知识 | 是 | 否 |
| 需要完全独立上下文 | 否 | 是 |
| 需要并行处理 | 否 | 是 |
| 只是按需加载提示词/文档 | 是 | 否 |
| 需要专门执行单元 | 否 | 是 |


# 基本实现思路

LangChain 文档里的 Skills 模式，本质上是用一个工具来按需加载 skill 内容。

```python
from langchain.tools import tool
from langchain.agents import create_agent

@tool
def load_skill(skill_name: str) -> str:
    """加载指定 skill 的说明和上下文"""
    ...

agent = create_agent(
    model="gpt-4.1",
    tools=[load_skill],
    system_prompt=(
        "你可以在需要时使用 load_skill 加载专业能力。"
    ),
)
```


**本质**

- skill 先不进上下文
- Agent 判断需要时，再通过工具加载


# Skills 的优点

- 降低初始上下文长度
- 专业知识按需加载
- 更方便团队分工维护
- 比完整多 Agent 更轻量


# Skills 的缺点

- 本质上还是单 Agent
- skill 加载后，后续上下文可能继续变长
- 不适合特别强的隔离和并行场景


# 使用建议

1. skill 适合封装“知识 + 规则 + 模板”，不只是堆文档。
2. `SKILL.md` 要写清楚什么时候用，不然 Agent 不知道该不该加载。
3. skill 内容尽量聚焦一个主题，不要做成“大杂烩”。
4. 如果一个能力需要独立状态、独立工具集，优先考虑 subagent。
5. skill 适合做按需增强，不适合替代整个 Agent 架构。
