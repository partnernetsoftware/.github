# mem_* 记忆 RAG

> **状态：v0.8.0（P0/P1）**。索引见 [INDEX.md](../INDEX.md)。

## MCP 工具

| 工具 | 说明 |
|------|------|
| `mem_put` | 写入 `key` + `content`（自动分块；可选 `tags`、`expires_at`） |
| `mem_get` | 按 key 读取全文（多 chunk 拼接） |
| `mem_delete` | 删除 key 及 Vectorize chunk 向量 |
| `mem_list` | 列表（可选 `tag` 过滤） |
| `mem_search` | Hybrid RRF（Vectorize + DO 关键词；无 Vectorize 时 `do_embed` 回退） |
| `mem_import` | 批量导入 `[{ key, content, tags?, expires_at? }]` |
| `mem_reindex` | **Admin**：从 DO 导出 chunk 重建 Vectorize |
| `mem_stats` | **Admin**：DO 内 keys/chunks/bytes |

## REST

| 方法 | 路径 |
|------|------|
| GET | `/v1/mem` |
| GET/PUT/DELETE | `/v1/mem/:key` |
| POST | `/v1/mem/search` body `{ "query", "top_k" }` |
| POST | `/v1/mem/import` body `{ "entries": [...] }` |
| GET | `/v1/mem/stats?owner=`（admin） |
| POST | `/v1/mem/reindex` body `{ "owner"? }`（admin） |

## 存储架构

| 层 | 职责 |
|----|------|
| **MemoryDO (SQLite)** | 全文 chunk、可选 DO 内 embedding、配额、`expires_at` + alarm 清理 |
| **Vectorize** | 检索加速器（按 chunk 向量，metadata: owner/key/mem_id） |
| **Workers AI** | `@cf/baai/bge-base-en-v1.5` embedding |

可选 `MEM_ENCRYPT=true`：DO 内 content 以 `enc:` 前缀 AES 静态加密（密钥同 vault）。

## wrangler vars（默认）

- `MEM_CHUNK_CHARS=1500`
- `MAX_MEM_KEYS=2000`、`MAX_MEM_BYTES=8000000`
- `MAX_MEM_CHUNK_BYTES=32000`

## Cloudflare 绑定

见 [cf-services.md](cf-services.md)。部署需 wrangler migration `v4`（`MemorySqliteDO` / `new_sqlite_classes`）。旧 `MemoryDO`（非 SQLite）实例不会自动迁移；可用 `mem_import` 或 `mem_reindex` 前重新 `mem_put`。同 owner 下旧 JSON blob 会在新 DO 首次访问时从 `memories` 键迁移。
