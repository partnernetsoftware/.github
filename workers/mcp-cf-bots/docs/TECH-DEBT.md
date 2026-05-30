# mcp-cf-bots 技术债

> 跟踪 SSOT：[mcp-cf-bots.mindmap](../mcp-cf-bots.mindmap) → `tech_debt` 节点。

| ID | 项 | 状态 | 说明 |
|----|-----|------|------|
| TD-1 | 旧 `MemoryDO`（非 SQLite） | **mitigated** | `memory-do-legacy.ts` stub；绑定已切 `MemorySqliteDO` v4 |
| TD-2 | 旧 DO 数据未自动迁移 | open | 用户需 `mem_put` / `mem_import`；文档见 PRODUCTION |
| TD-3 | Vectorize 孤儿向量 | **mitigated** | `mem_vector_gc` + cron `MEM_CRON_VECTOR_GC`（需 CF API token） |
| TD-4 | Cron 全量 list Vectorize | open | 大索引时 API 分页耗时；可调 `MEM_CRON_OWNER_LIMIT` |
| TD-5 | 删除 `MemoryDO` class | blocked | 需 CF `delete-class` 迁移且确认无存活实例 |
| TD-6 | `mem_search` 无 BM25 | open | 当前 hybrid = Vectorize + SQL LIKE；真 BM25 未接 |
