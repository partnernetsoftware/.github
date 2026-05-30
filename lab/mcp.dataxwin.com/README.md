# [REDACTED]

Cloudflare 上的 MCP 机器人服务（**mcp-cf-bots**）：OAuth / cookie / Playwright `storageState` 等。

| 路径 | 说明 |
|------|------|
| [`workers/session-vault/`](../../workers/session-vault/) | Cloudflare Worker + Durable Objects（部署名 `mcp-cf-bots`） |
| [`products/mcp_cf_bots_mcp.py`](../../products/mcp_cf_bots_mcp.py) | stdio MCP（推荐） |

部署与 MCP 配置见 [`workers/session-vault/README.md`](../../workers/session-vault/README.md)。
