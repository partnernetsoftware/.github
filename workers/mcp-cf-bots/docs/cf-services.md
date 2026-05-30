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

## 推荐（mem_search 语义检索）

| 层级 | 服务 | `/health` 显示 | 说明 |
|------|------|----------------|------|
| 1 | **Workers AI** | `rag: true`, `rag_backend: do_embed` | 已默认部署；embedding 存 MemoryDO，适合中小规模 |
| 2 | **+ Vectorize** | `rag_backend: vectorize` | 加速器；大规模检索更快 |

**启用 Vectorize（加速器）** — API Token 需含 **Vectorize Edit** + **Workers Scripts Edit**：

```bash
cd workers/mcp-cf-bots
./scripts/setup-rag.sh
```

脚本会：创建索引 `mcp-cf-bots-mem`（768 维）→ 解开 `wrangler.toml` 里 `[[vectorize]]` → 再 deploy。

若 Cloud Agent 的 `CLOUDFLARE_API_TOKEN` 无 Vectorize 权限，请在本机 Dashboard 创建 Token 后执行上述命令。

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
