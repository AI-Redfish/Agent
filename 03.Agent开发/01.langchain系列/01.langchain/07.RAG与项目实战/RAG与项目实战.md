# RAG 基础

## RAG

RAG 是 Retrieval-Augmented Generation，意思是“检索增强生成”。

它先从知识库检索相关资料，再让模型基于资料回答。



**执行流程**

```
文档加载 -> 文档切分 -> Embedding -> 向量存储 -> 检索 -> 拼接上下文 -> 模型回答
```



## 文档加载与切分

把原始文档加载为 Document，再切分成适合检索的小块。



**使用**

```
from langchain_community.document_loaders import TextLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter

loader = TextLoader('docs/readme.txt', encoding='utf-8')
docs = loader.load()

splitter = RecursiveCharacterTextSplitter(chunk_size=800, chunk_overlap=100)
chunks = splitter.split_documents(docs)
```



## 向量存储与检索

使用 Embedding 模型把文本转为向量，并写入向量库。



**使用**

```
from langchain_chroma import Chroma
from langchain_openai import OpenAIEmbeddings

embeddings = OpenAIEmbeddings()

vector_store = Chroma(
    collection_name='docs',
    embedding_function=embeddings,
)

vector_store.add_documents(chunks)
retriever = vector_store.as_retriever(search_kwargs={'k': 4})
docs = retriever.invoke('LangChain Agent 是什么？')
```



# RAG Agent

## 检索工具

把检索器封装成工具，让 Agent 在需要时主动查知识库。



**使用**

```
from langchain_core.tools import tool

@tool
def search_docs(query: str) -> str:
    """从知识库检索相关文档。"""
    docs = retriever.invoke(query)
    return '\n\n'.join(doc.page_content for doc in docs)
```



# 项目案例

## 智能客服

智能客服通常由 FAQ/RAG、业务接口、人工介入组成。



**典型链路**

```
用户问题 -> Agent -> FAQ/RAG 工具 -> 业务查询工具 -> 人工介入 -> 客服回复
```



**关键点**

- FAQ 用 RAG。
- 订单、物流、售后走业务接口。
- 退款、赔付、删除数据走人工确认。



## 个人知识库

个人知识库适合整理本地文档、技术笔记、项目资料。



**关键点**

- 文档路径、标题、URL、页码写入 metadata。
- 回答中展示引用来源。
- 定期增量更新索引。
- 私人知识库注意权限和数据安全。



## 多工具个人助手

个人助手可以组合日程、天气、搜索、计算器、知识库、邮件等工具。



**关键点**

- 查询类工具可直接执行。
- 修改、发送、删除类工具需要确认。
- 用户偏好保存到 Store。
- 多轮上下文使用 Checkpointer。



**建议**

- 文档切分大小会直接影响召回质量。
- 召回结果要保留来源，便于校验。
- 没有检索到依据时，应说明资料不足。
- 表格、代码、长文档要单独设计切分策略。



# 参考链接

## 教程来源

- https://www.runoob.com/langchain/langchain-rag-overview.html
- https://www.runoob.com/langchain/langchain-document-loaders.html
- https://www.runoob.com/langchain/langchainrag-agent.html
- https://www.runoob.com/langchain/langchain-project-customer-service.html
- https://www.runoob.com/langchain/langchain-project-knowledge-qa.html
- https://www.runoob.com/langchain/langchain-project-personal-assistant.html
