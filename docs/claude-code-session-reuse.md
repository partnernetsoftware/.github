# Claude Code CLI 跨 Cloud Agent 会话复用

**不增加新的 Cursor MCP。** 继续只用现有的 **session-vault** 远程 MCP 存认证；每个新 VM 会话启动时恢复文件 / 环境变量，再跑 `claude`。

## 原理

| 存储位置（Linux） | 内容 |
|-------------------|------|
| `~/.claude/.credentials.json` | OAuth access / refresh（`claude login` 后） |
| `~/.claude/settings.json` | CLI 设置 |
| `CLAUDE_CODE_OAUTH_TOKEN` | `claude setup-token` 的一年期 token（**最适合无头 Cloud Agent**） |

Vault 里用 `site=cli.claude`、`profile=default`：

- `config`：上述文件的 JSON bundle  
- `oauth`（可选）：`setup-token` 明文 token（仅 vault + Agent Secrets，勿提交 git）

## 一次性：登录后写入 vault

```bash
export SESSION_VAULT_URL SESSION_VAULT_TOKEN SESSION_VAULT_OWNER=cloud-agent

# 方式 A：交互登录后
claude   # 完成浏览器 OAuth
python3 tools/session_vault_claude_code.py capture

# 方式 B：长期 token（推荐 Cloud Agent）
claude setup-token
# 复制输出的 sk-ant-oat01-...
python3 tools/session_vault_claude_code.py capture-token --token 'sk-ant-oat01-...'
# 并把同一 token 写入 Cloud Agent Secret: CLAUDE_CODE_OAUTH_TOKEN
```

也可用已有 MCP 工具（等价）：

- `session_put(site=cli.claude, profile=default, kind=config, data={...bundle...})`

## 每个新 Cloud Agent 会话

在 Agent 启动脚本或第一次跑 CLI 前：

```bash
export SESSION_VAULT_URL SESSION_VAULT_TOKEN SESSION_VAULT_OWNER=cloud-agent
python3 tools/session_vault_claude_code.py restore
eval "$(python3 tools/session_vault_claude_code.py print-env)"  # 若有 setup-token
claude -p "your task"
```

`restore` 会把 bundle 写回 `~/.claude/`（权限 `0600`）。

## 检查

```bash
python3 tools/session_vault_claude_code.py status
```

## 与浏览器 登录（claude.ai）的区别

| | Claude **Code CLI** | 网页 claude.ai |
|--|---------------------|----------------|
| 存什么 | `.credentials.json` / setup-token | `storage_state` / cookies |
| vault site | `cli.claude` | `claude.ai` |
| 工具 | `session_vault_claude_code.py` | `browser_session_save` / JS snippets |

两套互不替代：CLI 续命不用 Playwright；网页登录不用 CLI credentials。

## 安全

- 勿把 token 或 `.credentials.json` 提交仓库  
- 仅 `SESSION_VAULT_TOKEN` 与 `CLAUDE_CODE_OAUTH_TOKEN` 放在 Cloud Agent Secrets  
- `capture-token` 输出勿贴到公开 issue
