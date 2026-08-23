

# 概述

这是一个为 DeepSeek Harness Web GUI 设计的网页预览与元素批注插件。它的主要功能包括：

- **网页预览**：在 DSH 内直接打开并预览 Agent 提供的链接页面。
- **元素批注**：悬停高亮并点选页面元素，为多个目标添加修改意见。
- **实时视觉调整**：在发送给 AI 前，可临时调整元素的文本、颜色、尺寸、间距等样式，并即时预览效果。
- **AI 协作**：将你的批注意见作为上下文发送给 Agent，让 AI 根据可视化反馈直接修改当前工作区中的前端源码。



# 安装



**官方地址**

https://github.com/CanglongCl/dsh-web-review



```
pnpm dsh plugin --profile web add @canglongcl/dsh-web-review
```

