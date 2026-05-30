# mcp-cf-bots

Cloudflare **HTTP MCP + REST**：跨 Agent 会话（`sess_*`）、记忆 RAG（`mem_*`，v0.8 SQLite + hybrid）、多用户 token（`auth_token_*`）。记忆 API 见 [`docs/mem-roadmap.md`](docs/mem-roadmap.md)。

**目录索引（SSOT）→ [INDEX.md](INDEX.md)** — 文件树、模块职责、文档与脚本一览；改仓库请先更新索引。

```bash
cd workers/mcp-cf-bots && npm ci && npm run typecheck && npm test
npx wrangler deploy --name mcp-cf-bots
```
