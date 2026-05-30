# 部署状态（Agent 可代劳）

目录索引：[INDEX.md](../INDEX.md)

## 当前线上

| 项 | 值 |
|----|-----|
| Worker | `mcp-cf-bots` |
| URL | `$MCP_CF_BOTS_URL`（自定义域名或 `*.workers.dev`） |
| MCP | `$MCP_CF_BOTS_URL/mcp` |
| Secret | `VAULT_TOKEN`（Cloud Agent：`SESSION_VAULT_TOKEN`） |
| Vars | `DEFAULT_OWNER=cloud-agent`，`DEFAULT_SESSION_SOURCE=browser-use` |

Smoke：`MCP_CF_BOTS_URL=... ./scripts/smoke.sh`；MCP `initialize` 应含 `serverInfo.auth`。

## Cursor MCP

见仓库 [`.cursor/mcp.json`](../../.cursor/mcp.json)：`url` 为 `${env:MCP_CF_BOTS_URL}/mcp`。

Secrets：`MCP_CF_BOTS_URL`、`MCP_CF_BOTS_TOKEN`（兼容 `SESSION_VAULT_*`）。

## 重新部署

```bash
cd /workspace/workers/mcp-cf-bots
npm ci && npm test && npx wrangler deploy --name mcp-cf-bots
```
