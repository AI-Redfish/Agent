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

## “**与**”触发

**等待所有上游分支到达**

这是多分支汇聚中**最常见**的情况。

**`LangGraph`** 的计算图是在一系列超步中完成的，如果能看到每个节点实例运行时的超步编号，则节点执行顺序一目了然。

**`LangGraph`** 的节点可以通过名为 **`config`** 的有名参数获取运行时配置

**`config`** 的元数据中记录了当前节点所在的 **`SuperStep`** 序号，可以通过下面的方式获取：

```python
config["metadata"]["langgraph_step"]
```

**详见下文。**

**示例如下**

```python
from typing import TypedDict
from langgraph.graph import StateGraph, START, END
from langchain_core.runnables import RunnableConfig

from loguru import logger

class EmptyState(TypedDict):
    pass

def node_a(state: EmptyState, config: RunnableConfig) -> EmptyState:
    cur_step = config["metadata"]["langgraph_step"]
    logger.info("cur_step: {}, node_a 被触发", cur_step)
    return {}

def node_b(state: EmptyState, config: RunnableConfig) -> EmptyState:
    cur_step = config["metadata"]["langgraph_step"]
    logger.info("cur_step: {}, node_b 被触发", cur_step)
    return {}

def node_c(state: EmptyState, config: RunnableConfig) -> EmptyState:
    cur_step = config["metadata"]["langgraph_step"]
    logger.info("cur_step: {}, node_c 被触发", cur_step)
    return {}

def node_d(state: EmptyState, config: RunnableConfig) -> EmptyState:
    cur_step = config["metadata"]["langgraph_step"]
    logger.info("cur_step: {}, node_d 被触发", cur_step)
    return {}

def node_e(state: EmptyState, config: RunnableConfig) -> EmptyState:
    cur_step = config["metadata"]["langgraph_step"]
    logger.info("cur_step: {}, node_e 被触发", cur_step)
    return {}

builder = StateGraph(state_schema=EmptyState)
builder.add_node("node_a", node_a)
builder.add_node("node_b", node_b)
builder.add_node("node_c", node_c)
builder.add_node("node_d", node_d)
builder.add_node("node_e", node_e)

builder.add_edge(START, "node_a")
builder.add_edge("node_a", "node_b")
builder.add_edge("node_a", "node_c")
builder.add_edge("node_b", "node_d")
builder.add_edge(["node_c", "node_d"], "node_e")

graph = builder.compile()
graph.invoke({})

from IPython.display import display
display(graph)
```

**运行结果如下**

```json
2026-06-05 14:55:01.705 | INFO     | __main__:node_a:12 - cur_step: 1, node_a 被触发
2026-06-05 14:55:01.708 | INFO     | __main__:node_b:17 - cur_step: 2, node_b 被触发
2026-06-05 14:55:01.710 | INFO     | __main__:node_c:22 - cur_step: 2, node_c 被触发
2026-06-05 14:55:01.713 | INFO     | __main__:node_d:27 - cur_step: 3, node_d 被触发
2026-06-05 14:55:01.714 | INFO     | __main__:node_e:32 - cur_step: 4, node_e 被触发
```

由运行结果可知：

* **`node_a`** 在第 1 个超步执行；
* **`node_b`** 和 **`node_c`** 在第 2 个超步并行执行；
* **`node_d`** 在第 3 个超步执行；
* **`node_e`** 在第 4 个超步执行。

虽然 **`node_c`** 在第 2 个超步已经执行完成，但是 **`node_e`** 并不会立刻触发。
因为这里使用的是：

```python
builder.add_edge(["node_c", "node_d"], "node_e")
```

这表示 **`node_e`** 需要等待 **`node_c`** 和 **`node_d`** 两个上游节点全部完成后，才会被触发一次。

因此，这种写法对应的是 **“与”触发**：等待所有上游分支到达方可触发。

## “**或**”触发

任意上游分支到达即可触发

另一种情况是：多个上游分支分别连接到同一个下游节点，但它们之间没有显式的同步等待关系。

**示例如下**

```python
from typing import TypedDict
from langgraph.graph import StateGraph, START, END
from langchain_core.runnables import RunnableConfig

from loguru import logger

class EmptyState(TypedDict):
    pass

def node_a(state: EmptyState, config: RunnableConfig) -> EmptyState:
    cur_step = config["metadata"]["langgraph_step"]
    logger.info("cur_step: {}, node_a 被触发", cur_step)
    return {}

def node_b(state: EmptyState, config: RunnableConfig) -> EmptyState:
    cur_step = config["metadata"]["langgraph_step"]
    logger.info("cur_step: {}, node_b 被触发", cur_step)
    return {}

def node_c(state: EmptyState, config: RunnableConfig) -> EmptyState:
    cur_step = config["metadata"]["langgraph_step"]
    logger.info("cur_step: {}, node_c 被触发", cur_step)
    return {}

def node_d(state: EmptyState, config: RunnableConfig) -> EmptyState:
    cur_step = config["metadata"]["langgraph_step"]
    logger.info("cur_step: {}, node_d 被触发", cur_step)
    return {}

def node_e(state: EmptyState, config: RunnableConfig) -> EmptyState:
    cur_step = config["metadata"]["langgraph_step"]
    logger.info("cur_step: {}, node_e 被触发", cur_step)
    return {}

builder = StateGraph(state_schema=EmptyState)
builder.add_node("node_a", node_a)
builder.add_node("node_b", node_b)
builder.add_node("node_c", node_c)
builder.add_node("node_d", node_d)
builder.add_node("node_e", node_e)

builder.add_edge(START, "node_a")
builder.add_edge("node_a", "node_b")
builder.add_edge("node_a", "node_c")
builder.add_edge("node_b", "node_d")

# 独立触发：node_c 完成后可以触发 node_e
builder.add_edge("node_c", "node_e")
# 独立触发：node_d 完成后可以触发 node_e
builder.add_edge("node_d", "node_e")

graph = builder.compile()
graph.invoke({})

from IPython.display import display
display(graph)
```

**运行结果如下**

```json
2026-06-05 15:09:11.715 | INFO     | __main__:node_a:12 - cur_step: 1, node_a 被触发
2026-06-05 15:09:11.720 | INFO     | __main__:node_b:17 - cur_step: 2, node_b 被触发
2026-06-05 15:09:11.723 | INFO     | __main__:node_c:22 - cur_step: 2, node_c 被触发
2026-06-05 15:09:11.729 | INFO     | __main__:node_d:27 - cur_step: 3, node_d 被触发
2026-06-05 15:09:11.729 | INFO     | __main__:node_e:32 - cur_step: 3, node_e 被触发
2026-06-05 15:09:11.732 | INFO     | __main__:node_e:32 - cur_step: 4, node_e 被触发
```



从运行结果可以看出，**`node_e`** 被触发了两次：

1. **`node_c`** 在第 2 个超步执行完成后，触发 **`node_e`** 在第 3 个超步执行；
2. **`node_d`** 在第 3 个超步执行完成后，再次触发 **`node_e`** 在第 4 个超步执行。

原因是这里使用了两条独立的边：

```python
builder.add_edge("node_c", "node_e")
builder.add_edge("node_d", "node_e")
```

这表示 **`node_c`** 和 **`node_d`** 都可以分别触发 **`node_e`**，它们之间没有同步等待关系。

因此，这种写法对应的是 **独立触发**，也可以类比为 **“或”触发**。

需要特别注意：

```python
builder.add_edge(["node_c", "node_d"], "node_e")
```

和

```python
builder.add_edge("node_c", "node_e")
builder.add_edge("node_d", "node_e")
```

不是等价写法。

前者表示 **等待多个上游全部完成后才触发一次**；
后者表示 **多个上游分支分别独立触发下游节点**。



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
builder.add_node("aggregator", aggregator, defer=true)  # 👈 默认值

builder.add_edge(START, "node_a")
builder.add_edge(START, "node_b")
builder.add_edge(START, "node_c")
builder.add_edge("node_a", "aggregator")
builder.add_edge("node_b", "aggregator")
builder.add_edge("node_c", "aggregator")
builder.add_edge("aggregator", "final_node")

a,b,c斗完成，aggregator才会执行。
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

**`Command`** 是 **`LangGraph`** 中用于控制图执行的多功能原语，它的构造器可以接受四个参数，并记录在同名类属性中：

- **`update`**：更新图状态，效果等同于节点直接返回状态更新字典；
- **`goto`**：指定节点执行完成后的跳转目标，可用于运行时条件分支。当需要同时更新状态并控制跳转时，比单独使用条件边更合适；
- **`graph`**：存在子图时，用于指定跳转发生在哪一层图中，例如从子图跳转到父图；
- **`resume`**：用于恢复被中断的图执行，常见于 **`human-in-the-loop`** 场景。



## 基本使用

与 **`add_conditional_edges()`** 相比，**`Command`** 更适合“状态更新”和“控制流跳转”需要放在同一个节点返回值中的场景。

例如，一个节点既要更新状态，又要根据当前状态决定下一步跳转目标，就可以返回：

```python
return Command(
    update={"foo": "bar"},
    goto="next_node"
)
```

以上同时完成两件事：

1. 更新 state。
2. 指定下一步跳转到哪个节点。



**案例**

```python
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









# Send

**`Send`** 结合 **`add_conditional_edges()`** 使用，可以用于动态扇出任务

所谓**扇出（Fan-out）**，是指一个上游节点像扇子一样，向外分发出多个下游任务。例如，根据一个主题，同时生成诗、词、笑话三个任务；又如，根据一个列表，为列表中的每个元素动态启动一个处理任务。

具体来说，路由函数可以返回一个 **`Send`** 实例序列。每个 **`Send`** 实例都描述了一次独立的任务分发：

- 分发到哪个下游节点；
- 给这个下游节点传入什么私有状态。

运行时，**`LangGraph`** 会根据返回的每个 **`Send`** 实例创建对应的任务。这些任务通常会在同一个超步中并行执行。



## 写入不同字段

**实例如下**

```python
from langgraph.graph import StateGraph, START, END
from typing import TypedDict,Literal
from collections.abc import Sequence
from langchain_deepseek import ChatDeepSeek
from langchain.messages import HumanMessage
from langchain.chat_models import init_chat_model
from langgraph.types import Send

import os

from dotenv import load_dotenv

load_dotenv()

api_key = os.getenv("OPENAI_API_KEY")
model_name = os.getenv("OPENAI_MODEL")  
base_url = os.getenv("OPENAI_BASE_URL")  
model_provider = os.getenv("MODEL_PROVIDER")  

# 创建模型（使用 init_chat_model）
model = init_chat_model(
    model=model_name,
    model_provider=model_provider,
    api_key=api_key,
    base_url=base_url,
    temperature=0,
    max_tokens=None,
    timeout=None,
    max_retries=2
)

CONTENT_TYPES = ["poem", "ci_poem", "joke"]


class OverAllState(TypedDict):
    topic: str
    poem: str
    ci_poem: str
    joke: str

class WorkerState(TypedDict):
    """
    私有状态，只对 Worker 节点可用
    """
    content_type: Literal["poem", "ci_poem", "joke"]
    prompt: str

class InputState(TypedDict):
    topic: str

class OutputState(TypedDict):
    poem: str
    ci_poem: str
    joke: str

def worker_node(state: WorkerState) -> OutputState:
    content_type = state["content_type"]
    prompt = state["prompt"]

    content = model.invoke([HumanMessage(prompt)]).content
    return {
        content_type: content
    }

def router(state: InputState) -> Sequence[Send]:
    prompt = "请生成关于 {} 的 {}"
    english2chinese = {
        "poem": "一首诗",
        "ci_poem": "一首词",
        "joke": "一个笑话"
    }

    topic = state["topic"]

    return [Send(
            "worker_node",
            {
                "content_type": content_type,
                "prompt": prompt.format(topic, english2chinese[content_type]),
            }
        ) for content_type in CONTENT_TYPES
    ]

builder = StateGraph(state_schema=OverAllState, input_schema=InputState, output_schema=OutputState)
builder.add_node("worker_node", worker_node)
builder.add_conditional_edges(
    START,
    router,
    path_map=["worker_node"]
)
builder.add_edge("worker_node", END)

graph = builder.compile()
res = graph.invoke({"topic": "布偶狗"})
print(res)
```

在这个案例中，**`router()`** 并没有直接返回某一个固定的下游节点名称，而是返回了多个 **`Send`** 实例：

```python
[ 
    Send("worker_node", {"content_type": "poem", ...}), 
    Send("worker_node", {"content_type": "ci_poem", ...}), 
    Send("worker_node", {"content_type": "joke", ...}), 
]
```

因此，运行时会动态创建三个指向 **`worker_node`** 的任务。三个任务执行的是同一个节点函数，但它们接收到的私有状态不同，所以可以分别生成**诗、词和笑话**。

**输出如下**

```json
{
  "poem": "## 《布偶狗》\n\n它曾蜷在藤椅里数谷粒，\n一只耳朵垂向磨损的地板。\n现在檐角的水滴是它的心跳，\n牵动穿珠眼珠转动。\n\n穿碎花裙的小女孩，\n用膝盖丈量过它的静默。\n她松开橡皮筋的午后，\n线缝里渗出稚嫩的气流。\n\n有人将米尺抖成琴弦，\n折叠的假寐里，\n它代替远方的稻草人，\n在积雨的布纹中扎根。\n\n田野在练习告别，\n而它守着发芽的梯田。\n当月光填满每道接缝，\n皮毛间涌出成群的往事。",
  "ci_poem": "《临江仙·布偶狗》\n绒作皮毛棉作骨，琉璃眸底春凝。\n也无吠影也无惊。倚床垂耳听，抱主索糖迎。\n\n不向残羹争冷炙，旧衾犹带余馨。\n学人解语却无声。偶沾星与月，懒问雨和晴。\n\n注：我以布偶狗为题，通过“绒作皮毛棉作骨”等句，以拟人手法赋予玩偶灵性。下阕“不向残羹争冷炙”暗喻玩偶超然物外的品性，末句“偶沾星与月”更添空灵意境，将玩偶与自然意象相融，表达出静默相伴的永恒温馨。",
  "joke": "# 布偶狗的笑话\n\n有一天，一只布偶狗走进一家宠物店，对店主说：\n\n“老板，我想买一只真正的狗朋友。”\n\n店主看了看它，好奇地问：“你不是狗吗？”\n\n布偶狗叹了口气，说：“唉，我是布偶做的，只能陪主人睡觉和卖萌，但我不会汪汪叫，也不会摇尾巴，更不会追球。每次主人想带我出去散步，我只能在包里安静地坐着，感觉自己特别没用。”\n\n店主笑了笑，说：“那你想要什么样的狗朋友？”\n\n布偶狗眼睛一亮：“我想要一只真正的狗，可以带着我去跑、去叫、去玩！我要学习怎么当一只好狗！”\n\n店主想了想，指着一只活泼的小金毛说：“那这只怎么样？它精力旺盛，可以教你很多。”\n\n布偶狗激动地冲过去，结果因为自己是布做的，腿太软，直接摔了个跟头，四脚朝天躺在地上。\n\n小金毛跑过来，闻了闻它，然后叼起它的棉花尾巴，一路拖到了狗窝里。\n\n布偶狗挣扎着喊：“等等！我还没学会怎么站起来！”\n\n小金毛歪了歪头，汪汪了两声，像是说：“没事，我先教你躺平。”\n\n从此以后，布偶狗成了小金毛最好的“垫子”——每天被压在身下睡觉，还觉得特别温暖。\n\n布偶狗心想：“原来，当一只合格的布偶狗朋友，最重要的技能是——当沙发。” 🛋️🐾"
}
```



此处图结构能成功渲染的关键，是在 **`path_map`** 中显式声明了可能被路由到的下游节点：

```python
path_map=["worker_node"]
```

因为 **`Send`** 的目标和数量可以运行时动态决定。通过 **`path_map`** 声明候选下游节点后。

补充说明：如果多个并行任务写入同一个状态字段，通常需要为该字段定义 reducer，用于合并多个任务的输出。本例中三个任务分别写入 **`poem`**、**`ci_poem`**、**`joke`** 三个不同字段，因此不会发生同一字段的并发合并问题。





## 写入相同字段









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







