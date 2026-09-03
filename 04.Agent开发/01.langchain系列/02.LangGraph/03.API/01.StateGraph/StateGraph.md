# START 与 END



`START` 和 `END` 是 LangGraph 的虚拟节点：

- `START` 表示图入口。
- `END` 表示图结束。

示例：

```python
builder.add_edge(START, "first_node")
builder.add_edge("last_node", END)
```

**路由到 END**

条件边中可以返回 `END` 来结束执行：

```python
def should_continue(state):
    if state["done"]:
        return END
    return "next_node"
```

这在循环 Agent 中非常常见。





# add_node

## **普通添加**

```
workflow.add_node("read_email", read_email)
```



## retry_policy

```
workflow.add_node(
    "search_documentation",
    search_documentation,
    retry_policy=RetryPolicy(max_attempts=3)
)
```





# 并行与聚合

## defer node execution

```python
builder.add_node("audit_node", audit_node, defer=True)
```

**`defer=True`** 的含义是：

只要图中还有其他常规节点（Pending Tasks）在排队或执行，它就会一直待在等待区。



**案例1**

```
builder = StateGraph(AuditState)
builder.add_node("researcher", researcher)
builder.add_node("writer", writer)
builder.add_node("auditor", auditor, defer=True)  # 核心：延迟执行

builder.add_edge(START, "researcher")
builder.add_edge(START, "writer")
builder.add_edge(START, "auditor")  # 虽然从 START 触发，但会等待

builder.add_edge("researcher", END)
builder.add_edge("writer", END)
builder.add_edge("auditor", END)

graph = builder.compile()

执行顺序：
researcher 和 writer 并行执行，两者完成并走向 END。
auditor 被唤醒执行，auditor 走向 END。
```



**案例2**

```
START -> a -> b -> c->end（这是一条很长的串行链路）
分支 2：START -> d-end（d 带有 defer=True）

执行顺序：
a,b,,c,d
原因：d要等待没有其他可执行节点才会被触发。
```



**案例3**

```
builder = StateGraph(MyState)
builder.add_node("node_a", node_a)
builder.add_node("node_b", node_b)
builder.add_node("node_c", node_c)
builder.add_node("aggregator", aggregator, defer=False)  # 👈 默认值

builder.add_edge(START, "node_a")
builder.add_edge(START, "node_b")
builder.add_edge(START, "node_c")
builder.add_edge("node_a", "aggregator")
builder.add_edge("node_b", "aggregator")
builder.add_edge("node_c", "aggregator")
builder.add_edge("aggregator", "final_node")

这个案例中，defer设置为true,false没有区别，都是，都要等待a,b,c都执行完才会被触发aggregator
```



**案例4**

```
START ──┬──> node_a ──┐
        ├──> node_b ──┼──> aggregator ──> final_node ──> END
        ├──> node_c ──┘
        └──> node_d ──> END (独立分支)
        

aggregator的defer=False：只要 node_a, node_b, node_c 跑完，aggregator 就会立刻执行。它根本不在乎 node_d 有没有跑完。

aggregator的defer=True：即使 node_a, node_b, node_c 都跑完了，调度器发现 node_d 还在运行（或者还没被触发），aggregator 就会继续等待，直到 node_d 也彻底执行完毕，它才会被唤醒。
```



#  add_edge

```python
from langgraph.graph import StateGraph, START, END
from typing import TypedDict

class OverAllState(TypedDict):
    username: str
    greeting: str
    output: str

def node_a(state: OverAllState) -> OverAllState:
    return {
        "greeting": "Dear " + state["username"]
    }

def node_b(state: OverAllState) -> OverAllState:
    return {
        "output": state["greeting"] + "，你好！"
    }

builder = StateGraph(state_schema=OverAllState)
builder.add_node("node_a", node_a)
builder.add_node("node_b", node_b)
builder.add_edge(START, "node_a")
builder.add_edge("node_a", "node_b")
builder.add_edge("node_b", END)

graph = builder.compile()
res = graph.invoke({"username": "小黄"})
print(res)

from IPython.display import display

display(graph)
```



# add_sequence

```
builder.add_sequence([node_a, node_b])
```

大致等价于：

```
builder.add_node("node_a", node_a)
builder.add_node("node_b", node_b)
builder.add_edge("node_a", "node_b")
```

# add_conditional_edges

## 语法

```python
def add_conditional_edges(
    self,
    source: str,
    path: Callable[..., Hashable | Sequence[Hashable]]
    | Callable[..., Awaitable[Hashable | Sequence[Hashable]]]
    | Runnable[Any, Hashable | Sequence[Hashable]],
    path_map: dict[Hashable, str] | list[str] | None = None,
) -> Self:
```

不考虑 **`self`**，核心参数有三个：

- **`source`**：条件分支的起始节点；
- **`path`**：路由规则，是一个可执行对象，通常是函数
- **`path_map`**：路由规则的返回值到真实节点名之间的映射关系。

其中，**`path`** 的返回值表示跳转的目标节点，可以是：

- 字符串或特殊对象 **`END`** 表示的单个目标；
- 字符串或特殊对象 **`END`** 表示的多个目标组成的序列，即路由到多个节点。

**`path_map`** 

- 可以省略，即取默认值 **`None`**，此时 **`path`** 返回值中出现的字符串必须是合法的节点名称。

- 可以是字典，维护 **`path`** 返回值和真实节点的映射。

- 也可以是列表，如下

  ```python
  path_map=["node_a", "node_b", "node_c"]
  ```

  相当于

  ```python
  path_map={
      "node_a": "node_a",
      "node_b": "node_b",
      "node_c": "node_c",
  }
  ```

  





## **无pathMap**

```
def route_by_intent(state):
    if state["intent"] == "search":
        return "search_node"
    if state["intent"] == "tool":
        return "tool_node"
    return "chat_node"

builder.add_conditional_edges("classify_intent", route_by_intent)
```

## 有pathMap

```
# Fail,Pass为上一个节点的返回值。
# improve_joke和End为下一个节点。
workflow.add_conditional_edges(
    "generate_joke", check_punchline, {"Fail": "improve_joke", "Pass": END}
)
```

**详细案例**

```
from typing_extensions import Literal
from langchain.messages import HumanMessage, SystemMessage


# Schema for structured output to use as routing logic
class Route(BaseModel):
    step: Literal["poem", "story", "joke"] = Field(
        None, description="The next step in the routing process"
    )


# Augment the LLM with schema for structured output
router = llm.with_structured_output(Route)


# State
class State(TypedDict):
    input: str
    decision: str
    output: str


# Nodes
def llm_call_1(state: State):
    """Write a story"""

    result = llm.invoke(state["input"])
    return {"output": result.content}


def llm_call_2(state: State):
    """Write a joke"""

    result = llm.invoke(state["input"])
    return {"output": result.content}


def llm_call_3(state: State):
    """Write a poem"""

    result = llm.invoke(state["input"])
    return {"output": result.content}


def llm_call_router(state: State):
    """Route the input to the appropriate node"""

    # Run the augmented LLM with structured output to serve as routing logic
    decision = router.invoke(
        [
            SystemMessage(
                content="Route the input to story, joke, or poem based on the user's request."
            ),
            HumanMessage(content=state["input"]),
        ]
    )

    return {"decision": decision.step}


# Conditional edge function to route to the appropriate node
def route_decision(state: State):
    # Return the node name you want to visit next
    if state["decision"] == "story":
        return "llm_call_1"
    elif state["decision"] == "joke":
        return "llm_call_2"
    elif state["decision"] == "poem":
        return "llm_call_3"


# Build workflow
router_builder = StateGraph(State)

# Add nodes
router_builder.add_node("llm_call_1", llm_call_1)
router_builder.add_node("llm_call_2", llm_call_2)
router_builder.add_node("llm_call_3", llm_call_3)
router_builder.add_node("llm_call_router", llm_call_router)

# Add edges to connect nodes
router_builder.add_edge(START, "llm_call_router")
router_builder.add_conditional_edges(
    "llm_call_router",
    route_decision,
    {  # Name returned by route_decision : Name of next node to visit
        "llm_call_1": "llm_call_1",
        "llm_call_2": "llm_call_2",
        "llm_call_3": "llm_call_3",
    },
)
router_builder.add_edge("llm_call_1", END)
router_builder.add_edge("llm_call_2", END)
router_builder.add_edge("llm_call_3", END)

# Compile workflow
router_workflow = router_builder.compile()

# Show the workflow
display(Image(router_workflow.get_graph().draw_mermaid_png()))

# Invoke
state = router_workflow.invoke({"input": "Write me a joke about cats"})
print(state["output"])
```



## 路由到多个节点

```
def router(state: OverAllState) -> Sequence[Literal["node_a", "node_b", "node_c"]]:
    if "诗" in state["content_type"]:
        return ["node_a", "node_c"]
    return ["node_b", "node_c"]

builder = StateGraph(state_schema=OverAllState)
builder.add_node("node_a", node_a)
builder.add_node("node_b", node_b)
builder.add_node("node_c", node_c)
builder.add_conditional_edges(
    START,
    router
)
```



## 路由函数不要做副作用

路由函数最好只做判断，不要调用外部 API、写数据库或修改 state。副作用应该放在节点里。

# Command

## 基本作用

`Command` 允许一个节点同时完成两件事：

1. 更新 state。
2. 指定下一步跳转到哪个节点。

适合把“节点逻辑”和“路由决策”放在同一个函数中。

示意：

```python
from langgraph.types import Command


def classify(state) -> Command:
    if "退款" in state["question"]:
        return Command(
            update={"intent": "refund"},
            goto="refund_node",
        )
    return Command(
        update={"intent": "general"},
        goto="general_node",
    )
```

## 使用建议

适合使用 `Command` 的场景：

- 节点内部已经得出下一步，不想再写独立路由函数。
- 需要同时更新状态并跳转。
- 子图需要跳转回父图。
- interrupt 恢复后需要继续控制流程。

不建议滥用：

- 简单固定流程用普通边即可。
- 简单分支用条件边更清晰。
- 如果所有节点都用 `Command`，图结构会变得不直观。



## 完整案例

```
from langgraph.graph import StateGraph, START, END
from langgraph.types import Command
from typing import TypedDict

# 1. 定义状态
class State(TypedDict):
    value: str

# 2. 定义节点
def node_a(state: State):
    # 节点 A 返回 Command，直接跳转到 node_c，并更新状态
    return Command(
        update={"value": "从A跳过来"},
        goto="node_c"  # 跳到 node_c
    )

def node_b(state: State):
    # 节点 B 返回 Command，直接跳转到 END
    return Command(
        update={"value": "从B跳过来"},
        goto=END  # 跳到结束
    )

def node_c(state: State):
    print(f"node_c 收到: {state['value']}")
    return {"value": state['value'] + "，处理完毕"}

# 3. 构建图
builder = StateGraph(State)

# 添加所有节点
builder.add_node("node_a", node_a)
builder.add_node("node_b", node_b)
builder.add_node("node_c", node_c)

# 设置入口
builder.add_edge(START, "node_a")

# 关键：从 node_a 走完直接结束（但实际上 node_a 自己用 Command 跳转了）
# 这里只是为了让图有边连接
builder.add_edge("node_a", END)      # 这条边会被 Command 覆盖
builder.add_edge("node_c", END)      # node_c 结束后结束

# 编译
graph = builder.compile()

# 4. 运行
result = graph.invoke({"value": "初始值"})
print(f"最终状态: {result}")
```



# Send-编排器工作器

**使用场景**

需要同时处理多个相同任务，且任务数量未知。

多个任务处理技术后对结果进行合并。



**组成部分**

| 角色             | 英文   | 中文含义        | 职责                                     |
| :--------------- | :----- | :-------------- | :--------------------------------------- |
| **Orchestrator** | 编排器 | 乐队指挥/编舞师 | 负责**规划、协调、分配**任务，不亲自干活 |
| **Worker**       | 工作器 | 工人/执行者     | 负责**具体执行**分配到的子任务           |
| **Synthesizer**  | 合成器 | 合成/整合者     | 负责**汇总、拼接**所有结果               |



## 案例

```
from typing import Annotated, List
import operator


# Schema for structured output to use in planning
class Section(BaseModel):
    name: str = Field(
        description="Name for this section of the report.",
    )
    description: str = Field(
        description="Brief overview of the main topics and concepts to be covered in this section.",
    )


class Sections(BaseModel):
    sections: List[Section] = Field(
        description="Sections of the report.",
    )


# Augment the LLM with schema for structured output
planner = llm.with_structured_output(Sections)


from langgraph.types import Send


# Graph state
class State(TypedDict):
    topic: str  # Report topic
    sections: list[Section]  # List of report sections
    completed_sections: Annotated[
        list, operator.add
    ]  # All workers write to this key in parallel
    final_report: str  # Final report


# Worker state
class WorkerState(TypedDict):
    section: Section
    completed_sections: Annotated[list, operator.add]


# Nodes
def orchestrator(state: State):
    """Orchestrator that generates a plan for the report"""

    # Generate queries
    report_sections = planner.invoke(
        [
            SystemMessage(content="Generate a plan for the report."),
            HumanMessage(content=f"Here is the report topic: {state['topic']}"),
        ]
    )

    return {"sections": report_sections.sections}


def llm_call(state: WorkerState):
    """Worker writes a section of the report"""

    # Generate section
    section = llm.invoke(
        [
            SystemMessage(
                content="Write a report section following the provided name and description. Include no preamble for each section. Use markdown formatting."
            ),
            HumanMessage(
                content=f"Here is the section name: {state['section'].name} and description: {state['section'].description}"
            ),
        ]
    )

    # Write the updated section to completed sections
    return {"completed_sections": [section.content]}


def synthesizer(state: State):
    """Synthesize full report from sections"""

    # List of completed sections
    completed_sections = state["completed_sections"]

    # Format completed section to str to use as context for final sections
    completed_report_sections = "\n\n---\n\n".join(completed_sections)

    return {"final_report": completed_report_sections}


# Conditional edge function to create llm_call workers that each write a section of the report
def assign_workers(state: State):
    """Assign a worker to each section in the plan"""

    # Kick off section writing in parallel via Send() API
    return [Send("llm_call", {"section": s}) for s in state["sections"]]


# Build workflow
orchestrator_worker_builder = StateGraph(State)

# Add the nodes
orchestrator_worker_builder.add_node("orchestrator", orchestrator)
orchestrator_worker_builder.add_node("llm_call", llm_call)
orchestrator_worker_builder.add_node("synthesizer", synthesizer)

# Add edges to connect nodes
orchestrator_worker_builder.add_edge(START, "orchestrator")
orchestrator_worker_builder.add_conditional_edges(
    "orchestrator", assign_workers, ["llm_call"]
)
orchestrator_worker_builder.add_edge("llm_call", "synthesizer")
orchestrator_worker_builder.add_edge("synthesizer", END)

# Compile the workflow
orchestrator_worker = orchestrator_worker_builder.compile()

# Show the workflow
display(Image(orchestrator_worker.get_graph().draw_mermaid_png()))

# Invoke
state = orchestrator_worker.invoke({"topic": "Create a report on LLM scaling laws"})

from IPython.display import Markdown
Markdown(state["final_report"])
```





# draw_mermaid

获取对应的mermaid图表示。

```
from typing_extensions import TypedDict
from langgraph.graph import StateGraph, START, END


class State(TypedDict):
    topic: str
    joke: str


def generate_joke(state: State):
    return {"joke": f"这是一个关于 {state['topic']} 的笑话。"}


builder = StateGraph(State)
builder.add_node("generate_joke", generate_joke)
builder.add_edge(START, "generate_joke")
builder.add_edge("generate_joke", END)

graph = builder.compile()
result = graph.invoke({"topic": "LangGraph"})

print(result)

# 获取图的mermaid图表示
raw_mermaid = graph.get_graph().draw_mermaid()
print(raw_mermaid)
```





# draw_mermaid_png

Langgraph也支持将mermaid转换为图片字节流

```python
png_bytes = graph.get_graph().draw_mermaid_png()
```

`draw_mermaid_png()`底层会先调用`draw_mermaid()`得到mermaid语法的图表代码，然后调用在线服务渲染为mermaid图片。

默认的mermaid在线渲染服务链接为：https://mermaid.ink，由于网络问题可能存在渲染失败的情况，通常重试即可成功。

可以通过`draw_mermaid_png()`的`base_url`参数替换可用的mermaid在线渲染服务。



**输出图片**

```
from typing_extensions import TypedDict
from langgraph.graph import StateGraph, START, END


class State(TypedDict):
    topic: str
    joke: str


def generate_joke(state: State):
    return {"joke": f"这是一个关于 {state['topic']} 的笑话。"}


builder = StateGraph(State)
builder.add_node("generate_joke", generate_joke)
builder.add_edge(START, "generate_joke")
builder.add_edge("generate_joke", END)

graph = builder.compile()
result = graph.invoke({"topic": "LangGraph"})

print(result)

# 获取图的mermaid图表示
raw_mermaid = graph.get_graph().draw_mermaid()
print(raw_mermaid)

# 假设你已经有了 png_bytes
png_bytes = graph.get_graph().draw_mermaid_png()

# 写入文件（二进制模式）
with open("my_graph.png", "wb") as f:
    f.write(png_bytes)
```







