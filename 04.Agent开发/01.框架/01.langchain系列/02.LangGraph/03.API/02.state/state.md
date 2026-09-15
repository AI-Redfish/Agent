# 状态定义

状态的定义实际上是在声明状态的Schema，后者是状态字段的完整描述。

官方推荐了三种定义Schema的方式：TypedDict、dataclass、Pydantic

## TypedDict-推荐

```python
from langgraph.graph import StateGraph, START, END
from typing import TypedDict, Annotated
from operator import add

class OverAllState(TypedDict):
    logs: Annotated[list[str], add]
    cur_id: str

def node_1(state: OverAllState) -> OverAllState:
    pre_id = state["cur_id"]
    return {
        "logs": ["node_1 运行完毕"],
        "cur_id": pre_id + ", node_1"
    }

def node_2(state: OverAllState) -> OverAllState:
    pre_id = state["cur_id"]
    return {
        "logs": ["node_2 运行完毕"],
        "cur_id": pre_id + ", node_2"
    }

builder = StateGraph(state_schema=OverAllState)
builder.add_node("node_1", node_1)
builder.add_node("node_2", node_2)
builder.add_edge(START, "node_1")
builder.add_edge("node_1", "node_2")
builder.add_edge("node_2", END)

graph = builder.compile()

print(graph.invoke({"cur_id": "start"}))
```

输出

```json
{ "logs": ["node_1 运行完毕", "node_2 运行完毕"], "cur_id": "start, node_1, node_2" }
```

## dataclass

属性调用方式由`['字段名']`变为`.字段名`。

```python
from langgraph.graph import StateGraph, START, END
from typing import Annotated
from dataclasses import dataclass
from operator import add

@dataclass
class OverAllState:
    logs: Annotated[list[str], add]
    cur_id: str

def node_1(state: OverAllState) -> OverAllState:
    pre_id = state.cur_id
    return {
        "logs": ["node_1 运行完毕"],
        "cur_id": pre_id + ", node_1"
    }

def node_2(state: OverAllState) -> OverAllState:
    pre_id = state.cur_id
    return {
        "logs": ["node_2 运行完毕"],
        "cur_id": pre_id + ", node_2"
    }

builder = StateGraph(state_schema=OverAllState)
builder.add_node("node_1", node_1)
builder.add_node("node_2", node_2)
builder.add_edge(START, "node_1")
builder.add_edge("node_1", "node_2")
builder.add_edge("node_2", END)

graph = builder.compile()

print(graph.invoke({"cur_id": "start"}))
```

输出

```json
{ "logs": ["node_1 运行完毕", "node_2 运行完毕"], "cur_id": "start, node_1, node_2" }
```

## Pydantic

Pydantic模型的字段访问方式和dataclass相同。

```python
from langgraph.graph import StateGraph, START, END
from typing import Annotated
from pydantic import BaseModel
from operator import add

class OverAllState(BaseModel):
    logs: Annotated[list[str], add]
    cur_id: str

def node_1(state: OverAllState) -> OverAllState:
    pre_id = state.cur_id
    return {
        "logs": ["node_1 运行完毕"],
        "cur_id": pre_id + ", node_1"
    }

def node_2(state: OverAllState) -> OverAllState:
    pre_id = state.cur_id
    return {
        "logs": ["node_2 运行完毕"],
        "cur_id": pre_id + ", node_2"
    }

builder = StateGraph(state_schema=OverAllState)
builder.add_node("node_1", node_1)
builder.add_node("node_2", node_2)
builder.add_edge(START, "node_1")
builder.add_edge("node_1", "node_2")
builder.add_edge("node_2", END)

graph = builder.compile()

print(graph.invoke({"cur_id": "start"}))
```

输出

```json
{ "logs": ["node_1 运行完毕", "node_2 运行完毕"], "cur_id": "start, node_1, node_2" }
```



# State Reducer

State Reducer 是 LangGraph 中用于合并状态更新的核心机制。在 LangGraph 的 `StateGraph` 中，每个节点可以读取和写入共享状态，而 Reducer 定义了如何将多个节点对同一状态键的更新合并

## 定义Reducer函数

Reducer 本质上是一个二元合并函数，用于定义当同一个字段产生多个更新值时，LangGraph 应该如何将这些值合并为一个最终结果。

函数签名：`(Value, Value) -> Value`

示例代码如下：

```python
def my_reducer(left: list[str], right: list[str]) -> list[str]:
    return left + right

left = ['a', 'b']
right = ['c']
print(my_reducer(left, right))
```

其中，`my_reducer` 用于处理 `list[str]` 类型的数据。它接收两个列表参数：

- `left`：当前已累计的状态值；
- `right`：本次待合并的新值。

函数内部通过 `left + right` 将两个列表合并，并返回合并后的结果。

因此，该 Reducer 的作用是：当某个状态字段存在多次列表更新时，将这些列表内容追加合并，而不是直接覆盖原值。

运行结果如下

```
['a', 'b', 'c']
```

## Reducer关联状态字段

```python
Annotated[Type, reducer_function]
```

其中：

- `Type`：表示状态字段的数据类型；
- `reducer_function`：表示该字段对应的 Reducer 函数。

示例代码如下：

```
from typing import TypedDict, Annotated

class OverAllState(TypedDict):
    logs: Annotated[list[str], my_reducer]
    cur_id: str
```



## 内置Reducer函数

 **operator.add**

`operator.add` 是 Python 内置的加法操作函数，底层由 C 实现

它接收两个参数，等价于 `a（第一个参数）+b（第二个参数）`

代码如下

```python
from operator import add

print(f"{add(1,2) = }")
print(f"{add([1,2], [3,4]) = }")
print(f"{add(['a','b'], ['c']) = }")
```

输出如下

```
add(1,2) = 3
add([1,2], [3,4]) = [1, 2, 3, 4]
add(['a','b'], ['c']) = ['a', 'b', 'c']
```

 **langgraph.graph.message.add_messages**

`add_messages` 是 LangGraph 中专用于合并消息列表的 Reducer 函数，常用于维护对话历史类的状态字段。其函数签名如下：

- 若 `right` 中的某条消息的 `id` 在 `left` 中不存在，则将该消息追加到结果列表末尾；
- 若 `right` 中的某条消息的 `id` 与 `left` 中已有消息的 `id` 相同，则使用 `right` 中的新消息替换 `left` 中的旧消息。



## 默认行为

如果某个 State 字段没有显式定义 `Reducer`，LangGraph 会使用默认的状态更新行为：后一次更新值会覆盖该字段原有的状态值。

换句话说，当节点返回的更新结果中包含某个字段时，如果该字段没有配置 Reducer，LangGraph 不会对新旧值进行追加、合并或累加，而是直接使用本次返回的新值替换原来的旧值。

# 节点中访问State

## 节点中读取State

节点函数的第一个参数通常是当前运行图的状态对象，也就是 `State`。

```
def node(state: StateSchema):
    ...
```

其中，`state` 表示当前节点执行时可以访问到的全局状态快照。节点可以通过读取 `state` 中的字段获取上游节点写入的数据，并基于这些数据完成当前节点的业务逻辑。

示例代码如下：

```python
from langgraph.graph import StateGraph, START, END
from typing import TypedDict, Annotated
from operator import add

class OverAllState(TypedDict):
    logs: Annotated[list[str], add]
    id: str

def node_a(state: OverAllState):
    for k, v in state.items():
        print(f"k: {k}, v: {v}")

builder = StateGraph(state_schema=OverAllState)
builder.add_node("node_a", node_a)
builder.add_edge(START, "node_a")
builder.add_edge("node_a", END)

graph = builder.compile()
result = graph.invoke({"logs": ["START"], "id": "start"})
```

输出如下

```
k: logs, v: ['START']
k: id, v: start
```

## 节点更新State

在 LangGraph 中，节点函数通常不需要返回更新后的完整状态，只需要返回本节点对状态

的局部更新。

- 对于节点没有返回的字段，LangGraph 会保留其原有状态值；

- 对于节点返回的字段，LangGraph 会根据该字段是否配置了 `Reducer` 来决定如何合并更新值。
  - 如果字段配置了 `Reducer`，则使用对应的 `Reducer` 函数将旧值和新值合并；
  - 如果字段没有配置 `Reducer`，则按照默认规则使用节点返回的新值覆盖原值。



### Overwrite绕过Reducer

在前面的示例中，如果某个状态字段定义了 `Reducer`，那么节点返回该字段的更新值时，LangGraph 默认会通过对应的 `Reducer` 将新值与已有状态值进行合并。

在某些场景下，我们可能并不希望继续执行 `Reducer` 的聚合逻辑，而是希望本次更新直接覆盖旧值。这时可以使用 `Overwrite`。

需要注意的是，`Overwrite` 只影响当前这一次更新，并不会修改状态字段本身的 `Reducer` 定义。后续节点如果继续正常返回该字段的更新值，仍然会按照原来的 `Reducer` 逻辑进行合并。

示例代码如下：

```python
from langgraph.graph import StateGraph, START, END
from langgraph.types import Overwrite
from typing import TypedDict, Annotated
from operator import add

class OverAllState(TypedDict):
    logs: Annotated[list[str], add]
    id: str

def node_a(state: OverAllState):
    return {
        "logs": ["node_a"],
        "id": "node_a"
    }

def node_b(state: OverAllState):
    return {
        "logs": Overwrite(["node_b"]),
        "id": "node_b"
    }

def node_c(state: OverAllState):
    return {
        "logs": ["node_c"],
        "id": "node_c"
    }

builder = StateGraph(state_schema=OverAllState)
builder.add_node("node_a", node_a)
builder.add_node("node_b", node_b)
builder.add_node("node_c", node_c)
builder.add_edge(START, "node_a")
builder.add_edge("node_a", "node_b")
builder.add_edge("node_b", "node_c")
builder.add_edge("node_c", END)

graph = builder.compile()
result = graph.invoke({"logs": ["START"], "id": "start"})
print('=' * 30, '-> result <-', '=' * 30)
print(result)
```

输出如下

```
============================== -> result <- ==============================
{'logs': ['node_b', 'node_c'], 'id': 'node_c'}
```

上述代码中：

- `logs` 字段绑定了 `operator.add()` 函数
  - 如果没有 `Overwrite`，则最终输出的 `logs` 的值应为 `['START', 'node_a', 'node_b', 'node_c']`
  - `node_b` 返回更新时，用 `Overwrite` 包裹了 `logs` 字段的值，那么当前状态的 `logs` 会被 `["node_b"]` 覆盖，因此最终输出的 `logs` 字段值变成了 `['node_b', 'node_c']`
- `id` 字段按照默认行为，保留最后一次更新的值。

# Multi Schema用法

## 案例

下面通过一个简单案例说明四类状态的定义和使用。

```python
from typing import TypedDict
from langgraph.graph import StateGraph, START, END

class InputState(TypedDict):
    username: str

class OutputState(TypedDict):
    graph_output: str

class OverAllState(TypedDict):
    nickname: str
    username: str
    graph_output: str

class PrivateState(TypedDict):
    greeting: str

def node_1(state: InputState) -> OverAllState:
    # 向全局状态写入数据
    return {
        "nickname": "Dear " + state["username"]
    }

def node_2(state: OverAllState) -> PrivateState:
    # 从全局状态读取数据，写入私有状态
    return {
        "greeting": state["nickname"] + ", 早上好~"
    }

def node_3(state: PrivateState) -> OutputState:
    # 从私有状态读取数据，写入输出状态
    return {
        "graph_output": state["greeting"] + " 很高兴认识你！"
    }

builder = StateGraph(OverAllState,input_schema=InputState,output_schema=OutputState)
builder.add_node("node_1", node_1)
builder.add_node("node_2", node_2)
builder.add_node("node_3", node_3)
builder.add_edge(START, "node_1")
builder.add_edge("node_1", "node_2")
builder.add_edge("node_2", "node_3")
builder.add_edge("node_3", END)

graph = builder.compile()
print(graph.invoke({"username":"小黄"}))
```

输出如下

```json
{ "graph_output": "Dear 小黄, 早上好~ 很高兴认识你！" }
```

## 状态类型

`LangGraph` 支持在一个图中使用多个状态 Schema，用于区分图的外部输入、外部输出、内部共享状态以及节点间的临时状态。

常见状态类型可以分为以下几类：

- 全局状态 / 内部状态：图内部主要使用的状态，创建 `StateGraph` 时传递给 `state_schema` 参数。它通常包含图运行过程中需要读写的大部分字段。
- 输入状态：图对外接收输入时使用的状态，创建 `StateGraph` 时传递给 `input_schema` 参数。它用于约束调用图时允许传入哪些字段。
- 输出状态：图最终对外返回结果时使用的状态，创建 `StateGraph` 时传递给 `output_schema` 参数。它用于约束图运行结束后只返回哪些字段。
- 私有状态：图内部节点之间传递的临时状态，通常不作为图的输入，也不作为图的最终输出。它可以通过节点函数的入参类型注解声明，并在节点返回值中写入。

需要注意，输入状态和输出状态主要面向图的边界，即“图如何接收外部输入”和“图如何返回外部结果”；而全局状态和私有状态主要面向图内部节点之间的数据传递。



## 设计规范

**输入状态和输出状态通常应是全局状态的子集**

输入状态描述图对外需要接收的数据，输出状态描述图最终需要返回的数据。

通常情况下，它们都应该是全局状态的一部分。

如：

```python
class InputState(TypedDict):
    username: str

class OutputState(TypedDict):
    graph_output: str

class OverAllState(TypedDict):
    username: str
    nickname: str
    graph_output: str
```

其中，`InputState` 和 `OutputState` 的所有字段均存在于 `OverAllState` 中。

**私有状态和全局状态应尽量避免字段重名**

私有状态的定位是图内部某些节点之间传递的临时字段。如果私有状态字段和全局状态字段重名，虽然某些情况下程序仍然可以运行，但容易让人误以为该字段是全局共享字段，从而造成理解混乱。
因此，推荐让私有状态字段和全局状态字段保持清晰边界。



**节点函数应明确声明入参状态类型和返回状态类型**
节点函数的第一个参数通常是当前节点可读取的状态。通过类型注解声明该参数，可以明确表达该节点需要读取哪些字段。

同时，给节点函数声明返回状态类型，也可以帮助阅读者理解该节点会更新哪些字段。
例如：

```python
def node_1(state: InputState) -> OverAllState:
    return {
        "nickname": "Dear " + state["username"]
    }
```



节点函数中不应该访问入参状态类型中不存在的字段
节点实际接收到的状态会按照其入参类型进行裁剪。因此，如果节点入参声明为 `InputState`，就不应该在节点内部访问 `InputState` 中不存在的字段。
例如：

```python
def node_1(state: InputState) -> OverAllState:
    return {
        "nickname": state["username"]
    }
```





# 预定义状态

## MessagesState

`LangGraph` 构建的计算图通常会和 `LLM` 结合使用，而 `LLM` 在运行过程中通常需要维护一组消息列表。为了提升开发效率，`LangGraph` 官方提供了一个预定义状态类型：`langgraph.graph.message.MessagesState`。

开发者可以直接继承该状态类型，并在其基础上扩展自定义状态字段。

源码如下：

```python
class MessagesState(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]
```

由此可知，`MessagesState` 只有一个字段：`messages`。

该字段的类型是列表，元素类型为 `AnyMessage`；同时，它通过 `Annotated` 绑定了内置 `Reducer` 函数 `add_messages`。



示例如下：

```python
from langchain_deepseek import ChatDeepSeek
from langgraph.graph import StateGraph, START, END
from langgraph.graph.message import MessagesState
from langchain.messages import HumanMessage

from dotenv import load_dotenv
load_dotenv(override=True)

model = ChatDeepSeek(
    model='deepseek-v4-flash',
    extra_body={
        "thinking": {
            "type": "disabled"
        }
    }
)

class OverAllState(MessagesState):
    username: str
    output: str

def node_a(state: OverAllState) -> OverAllState:
    return {
        "messages": [HumanMessage("你好，我是 " + state["username"])]
    }

def llm_node(state: OverAllState) -> OverAllState:
    res = model.invoke(state["messages"])

    return {
        "messages": [res],
        "output": res.content
    }

builder = StateGraph(state_schema=OverAllState)
builder.add_node("node_a", node_a)
builder.add_node("llm_node", llm_node)
builder.add_edge(START, "node_a")
builder.add_edge("node_a", "llm_node")
builder.add_edge("llm_node", END)

graph = builder.compile()
response = graph.invoke({"username": "小黄"})
print(response)
```

输出如下

```json
{
    "messages": [
        HumanMessage(
            content="你好，我是 小黄",
            additional_kwargs={},
            response_metadata={},
            id="155e1ef4-5bbc-4250-b978-62a7a5918cef",
        ),
        AIMessage(
            content="你好呀，小黄！😊 我是DeepSeek，很高兴认识你！有什么我可以帮你的吗？无论是聊天、解答问题、帮你写作、编程，还是其他任何需要，尽管告诉我吧！你名字里的“黄”是哪个黄呀？😄",
            additional_kwargs={
                "refusal": "None",
            },
            response_metadata={
                "token_usage": {
                    "completion_tokens": 57,
                    "prompt_tokens": 10,
                    "total_tokens": 67,
                    "completion_tokens_details": "None",
                    "prompt_tokens_details": {
                        "audio_tokens": "None",
                        "cached_tokens": 0,
                    },
                    "prompt_cache_hit_tokens": 0,
                    "prompt_cache_miss_tokens": 10,
                },
                "model_provider": "deepseek",
                "model_name": "deepseek-v4-flash",
                "system_fingerprint": "fp_8b330d02d0_prod0820_fp8_kvcache_20260402",
                "id": "17d57633-2ffb-4af3-be87-b3d58f9acd2b",
                "finish_reason": "stop",
                "logprobs": "None",
            },
            id="lc_run--019e6890-4544-7212-b4f2-aa20fc079911-0",
            tool_calls=[],
            invalid_tool_calls=[],
            usage_metadata={
                "input_tokens": 10,
                "output_tokens": 57,
                "total_tokens": 67,
                "input_token_details": {
                    "cache_read": 0,
                },
                "output_token_details": {},
            },
        ),
    ],
    "username": "小黄",
    "output": "你好呀，小黄！😊 我是DeepSeek，很高兴认识你！有什么我可以帮你的吗？无论是聊天、解答问题、帮你写作、编程，还是其他任何需要，尽管告诉我吧！你名字里的“黄”是哪个黄呀？😄",
}
```



## AgentState

langchain.agents.middleware.types.AgentState

源码如下

```python
class AgentState(TypedDict, Generic[ResponseT]):
    """State schema for the agent."""

    messages: Required[Annotated[list[AnyMessage], add_messages]]
    jump_to: NotRequired[Annotated[JumpTo | None, EphemeralValue, PrivateStateAttr]]
    structured_response: NotRequired[Annotated[ResponseT, OmitFromInput]]
```



**messages**

```
messages: Required[Annotated[list[AnyMessage], add_messages]]
```

`messages` 用于存储 Agent 运行过程中的消息列表。

该字段和 `MessagesState` 中的 `messages` 字段类似，也使用 `add_messages` 作为 `Reducer`。



**structured_response**

```python
structured_response: NotRequired[Annotated[ResponseT, OmitFromInput]]
```

`structured_response` 用于存储 Agent 最终生成的结构化输出。

当使用 `LangChain Agent` 的结构化输出能力时，例如指定 `response_format`，Agent 最终生成的结构化结果通常会被写入该字段。

其中，`OmitFromInput` 表示该字段不应作为外部输入字段暴露给调用方，而是由 Agent 运行过程中内部生成。

总体来看，`AgentState` 是专门为 LangChain Agent 运行时设计的状态类型。

因此，在普通自定义 `LangGraph` 项目中，一般不建议直接基于 `AgentState` 扩展图状态。





