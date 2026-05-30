---
name: mcp-cf-bots-delivery
description: >-
  Methodology for building and operating mcp-cf-bots (Cloudflare Worker MCP): wave roadmap,
  deploy gates, MCP agent guidance, auth/DO ops, integration tests. Use when touching
  workers/mcp-cf-bots, deploying the Worker, MCP 401, mem/sess tools, or when the user mentions
  mcp-cf-bots 路线图、发版、W0、W4、TD、verify-all-urls、cfb token. Stack with engineering-hygiene.
paths:
  - "workers/mcp-cf-bots/**"
  - "AGENTS.md"
  - ".cursor/mcp.json"
  - ".cursor/mcp.recommended.json"
---

# mcp-cf-bots 交付方法学

> 与 [engineering-hygiene](../engineering-hygiene/SKILL.md) **叠加**：卫生管全仓库 diff/SSOT；本 skill 管 **本产品** 的波次、门禁、MCP 行为、运维剧本。

## 方法学总结（反思）

| 原则 | 做法 | 反例 |
|------|------|------|
| **双 SSOT** | 人类读 [INDEX.md](../../workers/mcp-cf-bots/INDEX.md)；机器读 [mcp-cf-bots.mindmap](../../workers/mcp-cf-bots/mcp-cf-bots.mindmap) | 新建 PRODUCTION.md、docs 碎片 |
| **波次顺序** | 先稳态与测试 → 再删不可逆（DO class）→ 再 Agent 体验 → 再可观测 | 未测就删 MemoryDO |
| **门禁链** | `security-check` → typecheck → unit → integration → deploy → `verify-all-urls` | 只 deploy 不验版本 |
| **诊断先于修** | `/health` 200 但 MCP 401 → `diagnose-connection.sh` | 猜 token 或改代码 |
| **Secret 与 Worker 同名** | `wrangler secret put --name $CLOUDFLARE_WORKER_NAME` | secret 打在 wrangler.toml 默认名 |
| **三层 Agent 引导** | `initialize.instructions` + tool `description` + AGENTS/INDEX § Agent（MCP） | 只有 mcp.json URL |
| **记忆边界** | `mem_*` = 用户事实/偏好；规范进 INDEX/skill | `mem_put` 存路线图 |
| **删类前审计** | `POST /v1/mem/migrate-legacy` 看 `legacy_keys: 0` 再 `deleted_classes` | 直接删 DO binding |
| **双入口验收** | workers.dev + 自定义域同版本 | 只验一个 URL |

## 版本线

| 版本 | 含义 |
|------|------|
| **1.0.0** | GA：`api_version=1.0` 冻结；三支柱生产就绪 |
| **1.1.x** | 数字员工记忆智能（见 mindmap `roadmap.v1_1`） |
| **2.0.0** | 仅当破坏性 API 变更 |

## 波次模型（0.9 → 1.0 已完成）

```
W-卫生 → W2 → W3 → 0.9.5(MCP instructions) → 1.0.0(GA) → v1.1 设计/实现
```

| 波次 | 验收标准 |
|------|----------|
| **W2** | `npm run test:integration` 含 FTS + hybrid(mock Vectorize) + sess |
| **W3** | `wrangler` migration `deleted_classes`; 无 `MEMORY_LEGACY` |
| **W4** | `/health` `cf_api_ready: true` → `cron_vector_gc` 可 true |
| **W0** | 每轮 merge main → 全门禁 → deploy → `ALL_URLS_OK` |

当前 phase / TD：读 mindmap `roadmap.active_waves`、`tech_debt`。

## 开做（Open）

1. 读 **INDEX §路线图** + **mindmap** `north_star`、`active_waves`。
2. 确认 `MCP_SERVER_VERSION`（`wrangler.toml`）与 mindmap `current_version` 一致。
3. MCP 相关任务：读 INDEX **§ Agent（MCP）**；连不上走 **§ 连不上 / MCP 401**。
4. 多文件可并行时按 **文件边界** 拆（mem / sess / admin / test），仍遵守 hygiene 最小 diff。

## 做中（During）

### 代码布局

| 区域 | 文件 |
|------|------|
| MCP 协议 | `mcp-server.ts`, `mcp-http.ts`, `mcp-instructions.ts` |
| 记忆 | `mem-*.ts`（勿堆进 `mem-tools.ts`） |
| 会话 | `sess-tools.ts`, `session-do.ts` |
| Admin | **仅** `admin-api.ts` |

### 发版

```bash
cd workers/mcp-cf-bots
./scripts/security-check.sh
npm run typecheck && npm test && npm run test:integration
./scripts/deploy.sh   # 内部 verify-all-urls
```

### 运维剧本（mindmap `ops_playbook`）

```bash
./scripts/diagnose-connection.sh
./scripts/sync-vault-secret.sh && ./scripts/issue_token.sh <owner>
./scripts/sync-cf-api-secrets.sh && ./scripts/check-cf-api.sh
```

## 收尾（Close）

- [ ] INDEX「现状」版本 + 路线图表 + §技术债 与 mindmap 一致（TD-11）
- [ ] mindmap：`last_review`、`last_deploy`、`active_waves` 状态、`tech_debt`
- [ ] 若改 MCP 行为：更新 `mcp-instructions.ts` + 关键 tool `description`
- [ ] `git push origin main`；Cloud Agent 分支 `cursor/<topic>-1c37` 合并后删远程分支（用户要求时）

## MCP：Agent 何时主动调工具

| 用户意图 | 工具 |
|----------|------|
| 记住 / 偏好 / 项目事实 | `mem_put` |
| 续项目 / 回忆此前约定 | `mem_search` → `mem_get` |
| 浏览器登录成功 | `sess_save` |
| 要用已登录站自动化 | `sess_load` |

## Brain / Code（LLM 本质）

| 算子 | 职责 | 工具 |
|------|------|------|
| **Brain** | 多维上下文 **选择+投影** → `ContextBlock[]` | `brain_compose_context`（先调）；`mem_search` 取原始切片 |
| **Code** | **确定性** 读写外部状态 | `mem_*`、`sess_*`；见 `codeOpKind()` |

维定义：`src/context-model.ts`。`mem_put` 用 `kind` + `task/*` key 标注维。

## v1.1 后续

mindmap `v1_1_next`：token 预算、digest cron、search 反馈、put 后 auto-meta。

## 与其它 skill

| Skill | 关系 |
|-------|------|
| **engineering-hygiene** | 必须先遵守；本 skill 是 mcp-cf-bots 专项 |
| **squad-parallel** | 并行 wave 时两者同时启用 |
