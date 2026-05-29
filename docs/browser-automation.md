# Cloud Agent 浏览器方案

## 推荐（默认）

| 层级 | 工具 | 用途 |
|------|------|------|
| **控制浏览器** | [Playwright MCP](https://github.com/microsoft/playwright-mcp) | Cursor 里点选、填表、读页面、多步流程 |
| **跨会话登录态** | session-vault MCP（远程 HTTP） | `browser_session_save` / `load`、cookie、`storage_state` |

Playwright 比 Python **browser-use** 更适合日常 Agent：**更快、更稳、token 更省**；browser-use 留给「开放式目标、让模型自己规划每一步」的场景。

## Cursor MCP 配置

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"]
    },
    "session-vault": {
      "url": "https://<your-mcp-host>/mcp",
      "headers": {
        "Authorization": "Bearer <VAULT_TOKEN>",
        "X-Session-Vault-Owner": "cloud-agent"
      }
    }
  }
}
```

保存后重连两个 MCP。

## 典型流程

1. **playwright**：`browser_navigate` → `https://claude.ai/code`（或先注入 cookie，见下）
2. 你 **Take Control** 完成首次登录（或已有 vault 数据则跳过）
3. **playwright**：导出 cookie / `storage_state`（或 Console 跑 `workers/session-vault/snippets/capture-cookies.js`）
4. **session-vault MCP**：`browser_session_save`（site / profile / cookies）
5. 新 Agent：**vault** `browser_session_load` → **playwright** 打开同 URL → 已登录

## CLI 备选（无 MCP 时）

```bash
export SESSION_VAULT_URL SESSION_VAULT_TOKEN SESSION_VAULT_OWNER=cloud-agent
pip install playwright && playwright install chromium

# 登录后保存（含 HttpOnly）
python3 tools/session_vault_browser_cookies.py capture \
  --url https://claude.ai/code --site claude.ai --profile code

# 下次恢复
python3 tools/session_vault_browser_cookies.py apply \
  --url https://claude.ai/code --site claude.ai --profile code
```

## 何时用 browser-use（Python）

- 任务描述模糊：「帮我在三个网站比价」
- 需要多 Tab、自主规划、长链推理  
- 接受更慢、更高 LLM 成本  

仓库未默认安装 `browser-use`；需要时：`pip install browser-use`。

## 桌面 Chrome（Cloud Agent VM）

Cursor 桌面已带 Chrome（`DISPLAY=:1`）。Playwright MCP 默认起**独立** Chromium；要与桌面共用配置需 CDP（`--remote-debugging-port=9222`），当前 Agent shell 常连不上该端口，故优先 **vault + Playwright 新 context** 续会话。
