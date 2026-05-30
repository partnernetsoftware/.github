# 合并 main + 部署 Cloudflare Worker

## 1. 合并到 `main`

```bash
cd /workspace
git fetch origin main
git checkout main
git pull origin main
git merge origin/cursor/mcp-cf-bots-rename-1c37 -m "Merge mcp-cf-bots: HTTP MCP, sess_*, workers/mcp-cf-bots"
git push origin main
```

或在 GitHub 合并 PR：  
https://github.com/partnernetsoftware/.github/pull/158

## 2. 部署前检查

```bash
test -n "$CLOUDFLARE_API_TOKEN" && echo OK API_TOKEN
test -n "$CLOUDFLARE_ACCOUNT_ID" && echo OK ACCOUNT_ID
```

## 3. 首次 / 升级部署

```bash
cd /workspace/workers/mcp-cf-bots
npm ci
npx wrangler whoami

# Secret（仅首次或轮换）
# openssl rand -base64 32 | npx wrangler secret put VAULT_TOKEN

# 必设 vars（按你的租户改值）
npx wrangler vars put DEFAULT_OWNER cloud-agent
npx wrangler vars put DEFAULT_SESSION_SOURCE browser-use

# 部署（Worker 名默认 mcp-cf-bots，见 wrangler.toml）
npx wrangler deploy --name mcp-cf-bots
```

若线上仍用旧 Worker 名 `session-vault`，可临时：

```bash
npx wrangler deploy --name session-vault
```

迁移完成后把 Cursor MCP URL 指到新 `*.workers.dev` 或自定义域名。

## 4. Smoke test

```bash
export MCP_CF_BOTS_URL="https://mcp-cf-bots.<account>.workers.dev"
export MCP_CF_BOTS_TOKEN="<VAULT_TOKEN>"

curl -sS -X PUT "$MCP_CF_BOTS_URL/v1/session/example.com/default?owner=test" \
  -H "Authorization: Bearer $MCP_CF_BOTS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"storage_state":{"cookies":[],"origins":[]}}'

curl -sS "$MCP_CF_BOTS_URL/v1/sessions?owner=test" \
  -H "Authorization: Bearer $MCP_CF_BOTS_TOKEN"
```

MCP（需 Streamable HTTP Accept 头）：

```bash
curl -sS -X POST "$MCP_CF_BOTS_URL/mcp" \
  -H "Authorization: Bearer $MCP_CF_BOTS_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"curl","version":"0"}}}'
```

## 5. Cursor / Cloud Agent Secrets

| Secret | 值 |
|--------|-----|
| `MCP_CF_BOTS_URL` | `https://<host>`（无尾斜杠） |
| `MCP_CF_BOTS_TOKEN` | 与 `VAULT_TOKEN` 相同 |
| `MCP_CF_BOTS_OWNER` | 与 `DEFAULT_OWNER` 一致 |

`.cursor/mcp.recommended.json` 中 `mcp-cf-bots.url` 须含 `MCP_HTTP_PATH`（默认 `/mcp`）。

## 6. 旧 Worker 清理（可选）

确认新 Worker 与 MCP 正常后，在 Cloudflare Dashboard 删除未使用的 `session-vault` Worker（**DO 数据不可自动迁移**，需先确认无生产数据或接受重新登录存 session）。
