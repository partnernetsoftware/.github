# 多用户（per-user token）

## 模型

| 凭据 | 角色 | 能力 |
|------|------|------|
| `VAULT_TOKEN`（Secret） | **admin** | 任意 `owner`、签发/吊销用户 token |
| `cfb_…`（KV 存储） | **user** | 仅自己的 `owner` 命名空间，不能窥探他人 |

数据隔离：`vault/{owner}/{site}/{profile}`（与原先一致）。

## 给用户发 token（你做管理员）

```bash
export MCP_CF_BOTS_URL=https://mcp-cf-bots.kcc668.workers.dev
export MCP_CF_BOTS_TOKEN="$SESSION_VAULT_TOKEN"   # admin secret

./workers/mcp-cf-bots/scripts/issue_token.sh alice "Alice Cursor"
# 响应里的 token 只显示一次，交给用户
```

或 MCP（admin 连接）：`auth_token_create(owner="alice", label="...")`

## 用户 Cursor / Cloud Agent 配置

```json
{
  "mcpServers": {
    "mcp-cf-bots": {
      "url": "https://mcp-cf-bots.kcc668.workers.dev/mcp",
      "headers": {
        "Authorization": "Bearer <cfb_user_token>"
      }
    }
  }
}
```

**不要**再传 `X-Cf-Bots-Owner`（owner 已绑定在 token 上）。

## 管理

- `GET /v1/admin/tokens?owner=alice` — 列表
- `DELETE /v1/admin/tokens/{id}` — 吊销
- MCP：`auth_token_list` / `auth_token_revoke`

## 你的 Cloud Agent

可继续使用 **admin** `SESSION_VAULT_TOKEN`（全权限 + 可代用户签发 token）。  
若要演示多租户，再配一个仅含用户 token 的 MCP 配置即可。
