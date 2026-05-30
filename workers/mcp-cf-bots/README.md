# mcp-cf-bots

Cloudflare Worker（`workers/mcp-cf-bots/`）+ HTTP MCP `POST $MCP_HTTP_PATH`。

## 源码文件（Worker 打包）

| 文件 | 必需 | 作用 |
|------|------|------|
| `src/index.ts` | ✓ | 入口：鉴权、MCP / REST 路由 |
| `src/config.ts` | ✓ | 从 `Env` 读配置（无 TS 硬编码默认值） |
| `src/mcp-http.ts` | ✓ | Streamable HTTP MCP |
| `src/mcp-server.ts` | ✓ | `sess_*` 工具 + JSON-RPC |
| `src/vault-api.ts` | ✓ | REST + 工具实现 |
| `src/session-vault-do.ts` | ✓ | 会话 DO（加密） |
| `src/registry-do.ts` | ✓ | 索引 DO |
| `src/crypto.ts` | ✓ | AES-GCM |
| `src/kinds.ts` | ✓ | 类型 / `SESSION_KINDS` |
| `src/env.d.ts` | ✓ | `Env` 类型 |

**不进入 Worker 包**（可选）：

| 文件 | 说明 |
|------|------|
| `snippets/*.js` | 浏览器 Console 抓/恢复 cookie，人工用 |
| `.dev.vars.example` | 本地 `wrangler dev` 模板 |

已删除：`products/*_mcp.py|ts`（stdio 客户端不需要）。

## 环境变量

### Secrets（`wrangler secret put`）

| 名 | 说明 |
|----|------|
| `VAULT_TOKEN` | REST / MCP `Authorization: Bearer` |
| `ENCRYPTION_KEY` | 可选；未设则用 `VAULT_TOKEN` 派生 AES 密钥 |

### Vars（`wrangler.toml` `[vars]` 或 Dashboard）

| 名 | 必需 | 说明 |
|----|------|------|
| `MCP_HTTP_PATH` | ✓ | MCP 路径，默认 `/mcp` |
| `MCP_SERVER_NAME` | ✓ | `initialize` 里的服务名 |
| `MCP_SERVER_VERSION` | ✓ | 版本 |
| `MCP_SERVER_DESCRIPTION` | ✓ | 描述 |
| `MCP_PROTOCOL_VERSION` | ✓ | 如 `2024-11-05` |
| `OWNER_HEADER` | ✓ | 主 owner 头，默认 `X-Cf-Bots-Owner` |
| `DEFAULT_OWNER` | 生产建议 ✓ | 无 header/`?owner=`/工具参数时的租户 |
| `DEFAULT_SESSION_SOURCE` | 生产建议 ✓ | `sess_save` 未传 `source` 时写入 |
| `MCP_ALLOWED_ORIGINS` | 可选 | 逗号分隔 Origin 白名单；未设则 https + Cursor IDE + localhost |

本地开发：复制 `.dev.vars.example` → `.dev.vars`。

### Cursor / 工具侧（非 Worker）

| 名 | 说明 |
|----|------|
| `MCP_CF_BOTS_URL` | Worker 根 URL |
| `MCP_CF_BOTS_TOKEN` | 同 `VAULT_TOKEN` |
| `MCP_CF_BOTS_OWNER` | 与 `DEFAULT_OWNER` 对齐 |

旧名 `SESSION_VAULT_*` 在 `tools/*.py` 中仍可作为回退。

合并与上线步骤见 **[DEPLOY.md](./DEPLOY.md)**。

## 部署

```bash
cd /workspace/workers/mcp-cf-bots
npm install
export CLOUDFLARE_API_TOKEN=... CLOUDFLARE_ACCOUNT_ID=...
npx wrangler secret put VAULT_TOKEN
npx wrangler vars put DEFAULT_OWNER cloud-agent
npx wrangler vars put DEFAULT_SESSION_SOURCE browser-use
npx wrangler deploy --name mcp-cf-bots
```

## Cursor MCP

```json
{
  "mcpServers": {
    "mcp-cf-bots": {
      "url": "https://<host>/mcp",
      "headers": {
        "Authorization": "Bearer ${env:MCP_CF_BOTS_TOKEN}",
        "X-Cf-Bots-Owner": "${env:MCP_CF_BOTS_OWNER}"
      }
    }
  }
}
```

`url` 路径须与 Worker 上 `MCP_HTTP_PATH` 一致。

## REST

| 方法 | 路径 |
|------|------|
| PUT/GET/DELETE | `/v1/session/{site}/{profile}` |
| GET | `/v1/sessions` |

Owner：`?owner=`、owner 请求头、或 `DEFAULT_OWNER`。

## MCP 工具

`sess_save` | `sess_load` | `sess_meta` | `sess_put` | `sess_get` | `sess_delete` | `sess_list`

## 辅助 REST 脚本（非 MCP）

- `tools/session_vault_claude_code.py`
- `tools/session_vault_browser_cookies.py`
- `tools/claude_worker.sh`
