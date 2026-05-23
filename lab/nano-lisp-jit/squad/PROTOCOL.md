# Squad 协议：状态机 + CLI（替代 .md 派单）

## 问题（.md 耦合）

| .md 派单 | 后果 |
|----------|------|
| 多人改 `SQUAD.md` | 冲突、状态过期 |
| 无锁 | A/B 同改 `nano_cc.c` |
| 100% 靠 prose | 指挥长/审查员标准不一致 |
| AI 读长文 | 信号噪声大 |

## 三层耦合（推荐）

```text
catalog.yaml       ← 契约（角色、任务、门禁）           【少改】
.squad/state.db    ← 运行时真相 + 锁（SQLite WAL）      【CLI 独占写】
.squad/state.json  ← 导出快照（export-json / assess 后）
*.md               ← 叙事；派单板由 sync-md 生成
```

**为何 SQLite 而非 JSON 文件锁**：`claim` / `dispatch` 用 `BEGIN IMMEDIATE` + `path_locks` 主键；冲突时 `SQLITE_BUSY` 指数退避重试，避免两工程兵覆盖同一 `touch_paths`。

## 角色微工作流

```bash
# 仓库根（有 .squadrc.yaml）
tools/squad/squad.sh workflow-run commander
tools/squad/squad.sh workflow-run worker --as-role engineer-a
```

### 审查员 R

1. `squad verify`（catalog.verify.commands）
2. `squad assess` → SQLite `meta.last_assess` + 导出 `state.json`
3. `squad reflect --gate <id> --status warn --note "..."`
4. `squad sync-md --targets board,reflection`

### 指挥长 C

**推荐**：`squad supervise`（while 循环，见 `catalog.supervisor`）

1. `squad supervise` — 每 tick：`assess` → 若 ready 则 **complete** 退出
2. 否则检查 worker `failed`/`timeout` 信号 → **failed** 退出
3. 否则 `dispatch` 空闲工程兵 → `sleep poll_interval` 直至全局超时 → **timeout**
4. 每轮结束可 `squad sync-md --targets board`

单 tick（Agent 轮询）：`squad supervise --once`（exit 2=继续，0=complete，1=failed，3=timeout）

### 信号（signals 表）

```bash
squad signal engineer-a running --task-id L2-companion
squad signal engineer-a complete --task-id L2-companion
squad fail engineer-a L2-companion --reason "verify fail"
squad task-timeout engineer-a L2-companion
```

### 指挥长 C（旧：手动 assess/dispatch，仅调试）

1. `squad assess` → exit 0 则 `squad halt`
2. 否则 `squad dispatch --max-tasks 2`
3. `squad sync-md --targets squad-board`
4. 通知 A/B：`squad status --role engineer-a`

### 工程兵 A|B

0. `squad worker-tick engineer-a` → 按 `action` 执行（while 直到 idle/complete 或 halt）

1. `squad status --role engineer-a`
2. `squad claim engineer-a <task_id>`  # SQLite 锁 touch_paths
3. 按 `catalog.tasks.<id>.touch_paths` 改代码 + 洋葱验收
4. `squad verify` → `squad done engineer-a <task_id> --commit $(git rev-parse --short HEAD)`
5. 指挥长再跑 `squad assess`

## 入口

```bash
tools/squad/squad.sh assess      # 读 catalog + 证据，写 state.db
tools/squad/squad.sh dispatch
tools/squad/squad.sh export-json # 可选：给人看 state.json
```

## AI / Cloud Agent 约定

- **禁止**直接改 `<!-- SQUAD_STATE_BEGIN -->` 块；只改 `state.json` 后 `sync-md`
- **派单**只认 `state.assignments` 与 `catalog.yaml`
- **完成**必须 `squad done` + `verify` 通过，否则 assess 不涨
