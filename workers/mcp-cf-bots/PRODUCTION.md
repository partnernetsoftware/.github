# mcp-cf-bots — production checklist

## Required bindings & secrets

| Item | Wrangler / Dashboard |
|------|----------------------|
| `VAULT_TOKEN` | `wrangler secret put VAULT_TOKEN` (admin Bearer) |
| `TOKENS` KV | `[[kv_namespaces]]` in `wrangler.toml` |
| `SESSION_STORE` / `REGISTRY` DO | durable object bindings + migrations applied |
| Optional `ENCRYPTION_KEY` | separate AES key; defaults to `VAULT_TOKEN` |

Run `assertProdEnv` expectations before go-live: all of the above must exist on the target Worker.

## Public endpoints

| Route | Auth | Purpose |
|-------|------|---------|
| `GET /health` | none | Liveness (`ok`, `service`, `version`) |
| `GET /v1/me` | Bearer | Whoami (`admin` or `user` + `owner`) |

All other routes require `Authorization: Bearer <admin or cfb_*>`.

## Hardening (0.6+)

- Constant-time admin token compare (`safeEqual`)
- `Content-Length` cap via `MAX_BODY_BYTES` (default 2MB)
- `site` / `profile` / `owner` format validation
- Security headers on JSON responses (`nosniff`, `no-store`)
- Legacy MCP tool aliases (`session_*` → `sess_*`) on `tools/call` only

## Deploy

```bash
cd workers/mcp-cf-bots
npm ci
npm run typecheck
npm test
npx wrangler deploy --name mcp-cf-bots
```

Post-deploy:

```bash
export MCP_CF_BOTS_URL=https://mcp-cf-bots.<account>.workers.dev
export MCP_CF_BOTS_TOKEN=<admin secret>
./scripts/smoke.sh
```

## Multi-tenant tokens

Issue per-user tokens (admin only):

```bash
./scripts/issue_token.sh <owner> [label]
```

Users get `sess_*` scoped to their `owner`; admin retains `auth_token_*` and cross-tenant access via `owner` arg/header.

## Custom domain

Point your custom MCP hostname to the same Worker as `mcp-cf-bots` so tool names and routes stay in sync with `*.workers.dev`.

## CI

GitHub Actions workflow `.github/workflows/mcp-cf-bots.yml` runs `typecheck` + `vitest` on changes under `workers/mcp-cf-bots/`.
