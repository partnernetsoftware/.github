---
name: engineering-hygiene
description: >-
  Default engineering habit for this repo: clean diffs, reuse abstractions, single-doc SSOT,
  roadmap alignment. Use when starting or finishing any coding/docs/refactor task, when touching
  workers/mcp-cf-bots, products/, lab/, tools/, or when the user mentions 清洁、抽象、复用、卫生、
  路线图、走弯路、INDEX、mindmap. Agent must apply open → during → close checklist every round.
paths:
  - "**/*"
  - "AGENTS.md"
  - "skills/**"
  - "workers/**"
  - "products/**"
  - "lab/**"
  - "tools/**"
  - "docs/**"
---

# Engineering hygiene（清洁 · 抽象 · 复用）

## 铁律（Agent 每轮必做）

1. **先找 SSOT，再改代码** — 产品目录有 `INDEX.md` / `*.mindmap` 的，先读再动手。
2. **做中复用** — 第二遍相同逻辑必须抽模块/函数；禁止复制粘贴一整段实现。
3. **收尾刷新路线图** — 有 mindmap `roadmap` 的，更新 `last_review`、阶段状态、`tech_debt`；版本与 `wrangler` / `package.json` 对齐。
4. **文档不扩散** — 不新建散落 `.md`；能合并进现有 INDEX 就只改 INDEX + mindmap。
5. **不走 mem 存规范** — 工程习惯以本 skill + INDEX 为准；`mem_*` 只存用户事实/偏好，不存流程规范。

## 开做（Open）

| 检查 | 动作 |
|------|------|
| 范围 | 用户本轮目标一句话；对照路线图当前 phase，**P1 未启动则不偷做 P1** |
| SSOT | `workers/mcp-cf-bots` → [INDEX.md](../../workers/mcp-cf-bots/INDEX.md) + [mcp-cf-bots.mindmap](../../workers/mcp-cf-bots/mcp-cf-bots.mindmap) |
| 多产品 | 根 [AGENTS.md](../../AGENTS.md)；专项 skill（squad / longrun）若适用则 **先读 skill** |
| 分支 | Cloud Agent 用 `cursor/<topic>-1c37`；合并前 typecheck/test |

## 做中（During）

| 原则 | 做法 |
|------|------|
| **最小 diff** | 只改达成目标所需文件；不顺手「整理」无关代码 |
| **抽象** | 第三处重复 → 提取共享模块；命名与邻接文件一致 |
| **联系上下文** | 每轮回复开头心里对齐：路线图阶段、TD 状态、是否偏离 north_star |
| **mcp-cf-bots** | `mem-put` / `mem-cron` 等已分层；新能力放对应 `mem-*.ts`，勿堆进 `mem-tools.ts` |

## 收尾（Close）

| 检查 | 动作 |
|------|------|
| 测试 |  touched 包内 `npm run typecheck` / `npm test`（或项目约定命令） |
| 文档 | 更新 INDEX + mindmap `roadmap` / `tech_debt`；**不**新增 PRODUCTION.md、docs/*.md |
| 部署 | 若发 Worker： `./scripts/deploy.sh`；`/health` 版本号一致 |
| 路线图 | mindmap → `roadmap.end_of_round_checklist` 逐项过一遍 |
| 提交 | 清晰 commit message；push；需要时更新 PR |

## 产品速查（mcp-cf-bots）

| 项 | 位置 |
|----|------|
| 路线图 | INDEX §路线图 · mindmap `roadmap` |
| 当前版本 | `wrangler.toml` → `MCP_SERVER_VERSION` |
| P1 | **deferred** — 见 INDEX「P1 启动条件」 |
| 运维 | cron、`mem_migrate_legacy`、`mem_vector_gc` |

## 与其它 skill 关系

| Skill | 关系 |
|-------|------|
| **squad-parallel** | 并行 wave 时 **叠加** 本 skill；squad 管角色，本 skill 管 diff/SSOT |
| **nano-lisp-jit-v4-longrun** | longrun 管 state/gate；本 skill 管仓库卫生与文档 SSOT |

## 禁止

- 用 `mem_put` 代替 INDEX / skill 存工程规范  
- 未读路线图就启动 P1 大特性  
- 一轮结束不更新 mindmap `last_review`（有该产品时）
