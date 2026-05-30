# Cloudflare 需开通的服务

`mem_*` 分两层：**记忆存储**（必开）与 **语义 RAG**（推荐）。

## 必开（mem_put / get / list / delete）

| 服务 | 用途 | 你怎么开 |
|------|------|----------|
| **Workers** | 跑 `mcp-cf-bots` | 已有 |
| **Durable Objects** | `MEMORY_STORE` 按 owner 存记忆 | 随 Worker 部署；wrangler 迁移 `v3` |
| **Workers KV** | 用户 token `TOKENS` | 已有 |
| **Secrets** | `VAULT_TOKEN` | 已有 |

部署：`cd workers/mcp-cf-bots && npx wrangler deploy`

## 推荐（mem_search 向量语义检索）

| 服务 | 用途 | 你怎么开 |
|------|------|----------|
| **Workers AI** | 文本 embedding（`@cf/baai/bge-base-en-v1.5`） | Dashboard → **Workers AI** → 启用 |
| **Vectorize** | 向量索引 `mcp-cf-bots-mem` | 见下方一键脚本 |

```bash
cd workers/mcp-cf-bots
chmod +x scripts/setup-rag.sh
./scripts/setup-rag.sh
```

### API Token 权限（若用 `CLOUDFLARE_API_TOKEN`）

Wrangler 部署 / 建索引需要 token 含：

- Account — **Workers Scripts** Edit
- Account — **Workers KV** Edit
- Account — **Workers R2**（可选）
- Account — **Vectorize** Edit
- Account — **Workers AI** Read（或 Account AI 相关）
- Account — **Durable Objects** Edit

在 https://dash.cloudflare.com/profile/api-tokens 编辑或新建 **Custom token**。

## 未开 RAG 时

`/health` 显示 `"rag": false`；`mem_search` 自动退化为 **关键词匹配**（仍可用，精度较低）。

## 公开状态页 `/`

无需鉴权。HTML 播报；`/?format=json` 为 JSON。

可选 secrets（24h Worker 请求量 / CPU，缓存 5 分钟）：

```bash
npx wrangler secret put CF_ACCOUNT_ID --name mcp-cf-bots   # Cloudflare 账号 ID
npx wrangler secret put CF_API_TOKEN --name mcp-cf-bots    # Analytics Read
```

DO/KV/Vectorize **存储占用**不在 GraphQL 此接口内，见 Dashboard → Workers → 对应服务。

## 验证

```bash
curl -s "$MCP_CF_BOTS_URL/health"
# features.memory=true, features.rag=true 为满血
```
