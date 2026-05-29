# mcp.dataxwin.com

Session 保险箱（OAuth / cookie / Playwright `storageState`）实现位于 monorepo 根目录：

| 路径 | 说明 |
|------|------|
| [`workers/session-vault/`](../../workers/session-vault/) | Cloudflare Worker + Durable Objects |
| [`products/session_vault_mcp.py`](../../products/session_vault_mcp.py) | stdio MCP（推荐） |

部署与 MCP 配置见 [`workers/session-vault/README.md`](../../workers/session-vault/README.md)。
