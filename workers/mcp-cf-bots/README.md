# mcp-cf-bots

Cloudflare 上的 **HTTP MCP + REST**：跨 Agent 会话（`sess_*`）、多用户 token（`auth_token_*`）、后续 `mem_*`。

**本目录为唯一 SSOT**（Worker 源码、脚本、文档、片段）。

## 目录树

```
workers/mcp-cf-bots/
├── src/                    # Worker（wrangler 打包）
│   ├── index.ts            # 入口：鉴权 → MCP / REST
│   ├── auth.ts             # admin + 用户 token（KV）
│   ├── admin-api.ts        # /v1/admin/tokens
│   ├── config.ts           # Env / Origin / MCP 元信息
│   ├── mcp-http.ts         # Streamable HTTP MCP
│   ├── mcp-server.ts       # sess_* / auth_* 工具
│   ├── vault-api.ts        # REST /v1/session
│   ├── session-do.ts       # SessionStoreDO 加密存储
│   ├── sess-tools.ts       # MCP sess_* 实现
│   ├── registry-do.ts      # 列表索引 DO
│   ├── crypto.ts           # AES-GCM
│   ├── kinds.ts            # oauth / cookies / storage_state / config
│   └── env.d.ts
├── tools/                  # Python REST 客户端（非 MCP）
│   ├── _client.py          # 共享 REST 客户端
│   ├── claude_code.py      # CLI 凭据 capture/restore
│   └── browser_cookies.py  # Playwright cookie
├── scripts/                # Shell
│   ├── claude_worker.sh    # restore + claude
│   └── issue_token.sh      # admin 签发用户 token
├── snippets/               # 浏览器 Console（不进 Worker 包）
│   ├── capture-cookies.js
│   └── apply-cookies.js
├── docs/
│   ├── deploy.md           # 部署与线上 URL
│   ├── multi-user.md       # 多用户 token
│   ├── browser-automation.md
│   ├── claude-orchestrator.md
│   └── claude-code-session-reuse.md
├── mcp.recommended.json    # Cursor 远程 MCP 示例
├── wrangler.toml
├── package.json
└── .dev.vars.example
```

## 快速开始

```bash
cd workers/mcp-cf-bots
npm ci
npx wrangler deploy --name mcp-cf-bots
```

详见 [docs/deploy.md](docs/deploy.md)、[docs/multi-user.md](docs/multi-user.md)。

## 常用命令

| 用途 | 命令 |
|------|------|
| 派 Claude 工人 | `workers/mcp-cf-bots/scripts/claude_worker.sh -p "..."` |
| 存 CLI 登录态 | `python3 workers/mcp-cf-bots/tools/claude_code.py capture` |
| 签发用户 token | `workers/mcp-cf-bots/scripts/issue_token.sh <owner> [label]` |
| 浏览器 cookie | `python3 workers/mcp-cf-bots/tools/browser_cookies.py capture ...` |

## 环境变量

| 变量 | 说明 |
|------|------|
| `MCP_CF_BOTS_URL` | Worker 根 URL（无尾 `/`） |
| `MCP_CF_BOTS_TOKEN` | admin `VAULT_TOKEN` 或用户 `cfb_…` |
| `MCP_CF_BOTS_OWNER` | 租户 id（admin 可覆盖；用户 token 已绑定） |

兼容旧名：`SESSION_VAULT_*`。

## MCP

- 端点：`$MCP_CF_BOTS_URL/mcp`
- 工具：`sess_save` / `sess_load` / `sess_put` / …；admin 另有 `auth_token_*`
- 配置示例：[mcp.recommended.json](mcp.recommended.json)

## 文档

见 [docs/](docs/)。
