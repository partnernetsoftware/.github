# mem_* 记忆 RAG（规划）

> **状态：未实现**。开工前以 [INDEX.md](../INDEX.md) 为准登记新模块。

## 目标

在现有 `sess_*`（浏览器/CLI 凭据）之上，为 Agent 提供**可检索的长期记忆**：

- `mem_put` / `mem_get` — 结构化条目（事实、偏好、任务上下文）
- `mem_search` — 语义检索（RAG），返回相关片段 + 引用 id
- `mem_list` / `mem_delete` — 按 owner 命名空间管理

与 `sess_*` 相同的多租户模型：`owner` 由 Bearer（admin 或 `cfb_*`）隔离。

## 拟议架构（草案）

```
MCP tools (mem_*)
    → mem-tools.ts          # 与 sess-tools 对称
    → memory-do.ts          # 或 Vectorize + KV 元数据
    → embed-client.ts       # Workers AI / 外部 embedding API
```

存储选型（待决）：

| 方案 | 优点 | 风险 |
|------|------|------|
| DO + 本地向量 | 与现有模式一致 | DO 存储上限、检索性能 |
| Vectorize | 原生 ANN | 绑定与成本 |
| R2 + 批处理索引 | 便宜大容量 | 延迟、实现复杂 |

## 依赖

- [INDEX.md](../INDEX.md) 模块表已稳定
- `sess_*` / `auth_*` 测试与 CI 绿
- 本文件在实现时改为「已实现」并链接 API 说明

## 非目标（首版）

- 替代 `sess_*` 的加密会话存储
- 全库自动爬取 / 任意文件 ingest（可后续迭代）
