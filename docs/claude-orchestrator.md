# 中台 + Claude Code 工人

## 角色

| 角色 | 谁 | 做什么 |
|------|-----|--------|
| **中台** | Cursor Cloud Agent | 拆任务、调 vault、启动/监控 `claude`、汇总结果 |
| **工人** | Claude Code CLI | 写代码、跑命令、改仓库 |
| **保险箱** | **mcp-cf-bots** MCP | 存工人登录态（你只登录一次） |

你不应手动跑 `capture` / `restore`；中台在每个新会话自动做完再派活。

## 中台标准流程

1. **首次**（你 Take Control 登录一次 `claude` 后告诉中台「已登录」）  
   → 中台：`python3 tools/session_vault_claude_code.py capture`（或 MCP `sess_put`）

2. **每次派活**  
   → 中台：`tools/claude_worker.sh -p "具体任务"`  
   → 内部：`restore` ← vault → `claude` 执行

3. **跨会话**  
   Secrets 只需 `MCP_CF_BOTS_URL` + `MCP_CF_BOTS_TOKEN`；工人凭据只在 vault。

## 示例

```bash
/workspace/tools/claude_worker.sh -p "在 workers/session-vault 加单元测试，不要改 API 行为"
```

## 和你无关的命令

- 不必配置 `CLAUDE_CODE_OAUTH_TOKEN` Secret（除非不用 vault）
- 不必记 `capture` / `restore`；只说「用 claude 做 XXX」

## 浏览器 / 网页登录

网页（claude.ai）与 CLI 工人分开：网页 cookie 用 `sess_save`；CLI 用 `cli.claude` vault 键。
