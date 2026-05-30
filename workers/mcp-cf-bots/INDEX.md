# mcp-cf-bots 索引（SSOT）

> **维护规则**：新增/移动/删除本目录下任何文件时，**先更新本文件**，再改代码。README 只保留一句话 + 链到此处。

HTTP MCP + REST on Cloudflare Workers：`sess_*` 会话、`mem_*` 记忆 RAG、`auth_token_*` 多租户。

## 文档

| 文件 | 用途 |
|------|------|
| [README.md](README.md) | 入口摘要 |
| [PRODUCTION.md](PRODUCTION.md) | 上线清单、绑定、冒烟 |
| [docs/README.md](docs/README.md) | 文档子目录说明 |
| [docs/deploy.md](docs/deploy.md) | 部署、URL、Secrets |
| [docs/multi-user.md](docs/multi-user.md) | 用户 token `cfb_*` |
| [docs/browser-automation.md](docs/browser-automation.md) | Playwright + MCP |
| [docs/claude-orchestrator.md](docs/claude-orchestrator.md) | 派 Claude 工人 |
| [docs/claude-code-session-reuse.md](docs/claude-code-session-reuse.md) | CLI 跨会话 |
| [docs/mem-roadmap.md](docs/mem-roadmap.md) | `mem_*` API 与后续改进 |
| [docs/cf-services.md](docs/cf-services.md) | 需开通的 CF 服务与 Token 权限 |

## 配置与运维

| 文件 | 用途 |
|------|------|
| [wrangler.toml](wrangler.toml) | Worker 名、DO/KV、vars |
| [package.json](package.json) | npm 脚本、版本 |
| [mcp.recommended.json](mcp.recommended.json) | Cursor 远程 MCP 示例 |
| [.dev.vars.example](.dev.vars.example) | 本地 secret 模板 |
| [scripts/smoke.sh](scripts/smoke.sh) | 部署后 `/health`、`/v1/me` |
| [scripts/setup-rag.sh](scripts/setup-rag.sh) | Vectorize 索引 + 部署（语义检索） |
| [scripts/issue_token.sh](scripts/issue_token.sh) | admin 签发用户 token |
| [scripts/claude_worker.sh](scripts/claude_worker.sh) | restore vault + `claude` |

## 客户端（非 Worker 包）

| 路径 | 用途 |
|------|------|
| [tools/_client.py](tools/_client.py) | 共享 REST 客户端 |
| [tools/claude_code.py](tools/claude_code.py) | CLI 凭据 capture/restore |
| [tools/browser_cookies.py](tools/browser_cookies.py) | Playwright cookie |
| [snippets/capture-cookies.js](snippets/capture-cookies.js) | 浏览器 Console 导出 |
| [snippets/apply-cookies.js](snippets/apply-cookies.js) | 浏览器 Console 注入 |

## 测试

| 路径 | 用途 |
|------|------|
| [test/unit.test.ts](test/unit.test.ts) | vitest（validate、aliases、http-util） |
| [vitest.config.ts](vitest.config.ts) | 测试配置 |

## `src/` 模块图

| 模块 | 职责 |
|------|------|
| [index.ts](src/index.ts) | 路由：`/`、`/health` → 鉴权 → MCP / REST |
| [status-board.ts](src/status-board.ts) | 公开 `GET /` 状态播报 |
| [cf-analytics.ts](src/cf-analytics.ts) | 可选 CF GraphQL 24h 用量 |
| [health.ts](src/health.ts) | `GET /health`、`GET /v1/me` |
| [http-util.ts](src/http-util.ts) | JSON 响应、错误码、`safeEqual` |
| [validate.ts](src/validate.ts) | body 上限、key/owner、`requireSiteProfile` |
| [config.ts](src/config.ts) | Env、Origin、MCP 元信息 |
| [auth.ts](src/auth.ts) | admin + KV 用户 token |
| [owner-scope.ts](src/owner-scope.ts) | MCP 租户解析 |
| [admin-api.ts](src/admin-api.ts) | REST `/v1/admin/tokens` + `auth_token_*` |
| [mcp-http.ts](src/mcp-http.ts) | Streamable HTTP、`MCP-Session-Id` |
| [mcp-server.ts](src/mcp-server.ts) | JSON-RPC（薄层） |
| [tool-defs.ts](src/tool-defs.ts) | MCP 工具 schema |
| [tool-aliases.ts](src/tool-aliases.ts) | 旧工具名 → `sess_*` |
| [sess-tools.ts](src/sess-tools.ts) | `sess_*` 工具实现 |
| [mem-tools.ts](src/mem-tools.ts) | `mem_*` 工具实现（分块、hybrid、import） |
| [mem-config.ts](src/mem-config.ts) | chunk 大小、配额、`MEM_ENCRYPT` |
| [mem-chunk.ts](src/mem-chunk.ts) | 长文分块 |
| [mem-hybrid.ts](src/mem-hybrid.ts) | RRF 混合检索 |
| [mem-crypto.ts](src/mem-crypto.ts) | 可选 DO 静态加密 |
| [mem-embed.ts](src/mem-embed.ts) | Workers AI embedding + Vectorize |
| [mem-rest.ts](src/mem-rest.ts) | REST `/v1/mem` |
| [memory-do.ts](src/memory-do.ts) | `MemorySqliteDO` SQLite chunks + 过期 alarm |
| [memory-store.ts](src/memory-store.ts) | Memory DO id / stub |
| [vault-api.ts](src/vault-api.ts) | REST `/v1/session`、`/v1/sessions` |
| [session-store.ts](src/session-store.ts) | DO id + `sessionStub` |
| [session-meta.ts](src/session-meta.ts) | meta 字段从 args 构建 |
| [registry-client.ts](src/registry-client.ts) | 列表 DO fetch |
| [session-do.ts](src/session-do.ts) | `SessionStoreDO` 加密 blob |
| [registry-do.ts](src/registry-do.ts) | 按 owner 索引 site/profile |
| [crypto.ts](src/crypto.ts) | AES-GCM |
| [kinds.ts](src/kinds.ts) | `storage_state` / `oauth` / … |
| [env.d.ts](src/env.d.ts) | `Env` 类型 |

## API 速查

| 类型 | 路径 / 工具 |
|------|-------------|
| 公开 | `GET /`（状态页）、`GET /health` |
| 鉴权 | `GET /v1/me`，Bearer admin 或 `cfb_*` |
| MCP | `POST {MCP_HTTP_PATH}`（默认 `/mcp`） |
| REST 会话 | `GET/PUT/DELETE /v1/session/:site/:profile`，`GET /v1/sessions` |
| REST admin | `GET/POST /v1/admin/tokens`，`DELETE /v1/admin/tokens/:id` |
| MCP 工具 | `sess_*`、`mem_*`，admin：`auth_token_*`、`mem_reindex`、`mem_stats`；旧 sess 名见 [tool-aliases.ts](src/tool-aliases.ts) |
| REST 记忆 | `GET /v1/mem`，`PUT/GET/DELETE /v1/mem/:key`，`POST /v1/mem/search|import`，admin：`GET /v1/mem/stats`，`POST /v1/mem/reindex` |

## 环境变量（客户端）

| 变量 | 说明 |
|------|------|
| `MCP_CF_BOTS_URL` | Worker 根 URL |
| `MCP_CF_BOTS_TOKEN` | Bearer（admin 或 `cfb_*`） |
| `MCP_CF_BOTS_OWNER` | 租户（用户 token 已绑定） |

兼容：`SESSION_VAULT_*`。
