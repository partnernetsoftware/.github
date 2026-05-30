# 部署状态（Agent 可代劳）

## 当前线上

| 项 | 值 |
|----|-----|
| Worker | `mcp-cf-bots` |
| URL | `https://mcp-cf-bots.kcc668.workers.dev` |
| MCP | `https://mcp-cf-bots.kcc668.workers.dev/mcp` |
| Secret | `VAULT_TOKEN`（已与仓库 Cloud Agent `SESSION_VAULT_TOKEN` 同步） |
| Vars | `DEFAULT_OWNER=cloud-agent`，`DEFAULT_SESSION_SOURCE=browser-use` |

Smoke test：`./scripts/smoke.sh`（`GET /health`、可选 `GET /v1/me`）；MCP `initialize` 应返回 `serverInfo.auth`。

## 你无需本地操作

Cloud Agent 环境里已有 `SESSION_VAULT_TOKEN` 时，Agent 用 wrangler 写入 Worker secret 即可。

## 仅当你换 token 时

```bash
cd /workspace/workers/mcp-cf-bots
printf '%s' "$NEW_TOKEN" | npx wrangler secret put VAULT_TOKEN --name mcp-cf-bots
```

并同步更新 Cursor **Secrets** 里的 `MCP_CF_BOTS_TOKEN`。

## Cursor MCP（复制即用）

```json
{
  "mcpServers": {
    "mcp-cf-bots": {
      "url": "https://mcp-cf-bots.kcc668.workers.dev/mcp",
      "headers": {
        "Authorization": "Bearer ${env:MCP_CF_BOTS_TOKEN}",
        "X-Cf-Bots-Owner": "${env:MCP_CF_BOTS_OWNER}"
      }
    }
  }
}
```

Cloud Agent Secrets（若尚未改名，可继续用旧名，工具脚本兼容）：

| 推荐名 | 可与旧名等价 |
|--------|----------------|
| `MCP_CF_BOTS_URL` | `SESSION_VAULT_URL` → 填上表 URL（无 `/mcp` 后缀） |
| `MCP_CF_BOTS_TOKEN` | `SESSION_VAULT_TOKEN` |
| `MCP_CF_BOTS_OWNER` | `SESSION_VAULT_OWNER` → `cloud-agent` |

## 重新部署代码

```bash
cd /workspace/workers/mcp-cf-bots
npm ci
npx wrangler deploy --name mcp-cf-bots
```

含 DO 迁移 `v2`：`SessionVaultDO` → `SessionStoreDO`（wrangler 自动执行）。

## 合并 main

已在 `main`；日常 `git pull` 后按上节 deploy 即可。
