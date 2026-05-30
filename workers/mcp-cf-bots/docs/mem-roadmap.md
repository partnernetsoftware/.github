# mem_* 记忆 RAG

> **状态：已实现（v0.7.0）**。索引见 [INDEX.md](../INDEX.md)。

## MCP 工具

| 工具 | 说明 |
|------|------|
| `mem_put` | 写入 `key` + `content`（可选 `tags`） |
| `mem_get` | 按 key 读取全文 |
| `mem_delete` | 删除 |
| `mem_list` | 列表（可选 `tag` 过滤） |
| `mem_search` | 语义检索（Vectorize+AI）或关键词回退 |

## REST

| 方法 | 路径 |
|------|------|
| GET | `/v1/mem` |
| GET/PUT/DELETE | `/v1/mem/:key` |
| POST | `/v1/mem/search` body `{ "query", "top_k" }` |

## Cloudflare 绑定

见 [cf-services.md](cf-services.md)。

## 后续可改进

- 分块 ingest（长文自动 chunk + 多向量）
- 过期时间 `expires_at` 与定时清理
- Hybrid 检索（BM25 + 向量）
- `mem_import` 批量导入
