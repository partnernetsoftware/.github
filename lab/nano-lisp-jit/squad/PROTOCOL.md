# Squad 协议：状态机 + CLI（替代 .md 派单）

## 问题（.md 耦合）

| .md 派单 | 后果 |
|----------|------|
| 多人改 `SQUAD.md` | 冲突、状态过期 |
| 无锁 | A/B 同改 `nano_cc.c` |
| 100% 靠 prose | 指挥长/审查员标准不一致 |
| AI 读长文 | 信号噪声大 |

## 演进笔记（非当下实现）

当前 squad 是 **host 造工具**：Python（`squad_cli.py` / SQLite）+ shell（`squad.sh` / tmux）。  
**终局**：nano lisp 工具链成熟后，用 **同一套 bootstrap / slice runner** 实现派单、锁、`run-loop` 与 leader 信号，**不再依赖** host Python/shell 编排层。v3.5 先用 host 工具验证协议；协议（catalog + signals + leader/follower）应保持稳定，便于移植到 `.lisp`。

**v4 步骤列表**（dispatch / signals / run-loop → bootstrap 子命令、slice S0–S5）：[`v4/README.md` §Bootstrap 替代 Python squad](../v4/README.md#bootstrap-替代-python-squad草图)。

---

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

### 全队：同一工具 `run-loop`（禁止每角色一套脚本/py）

```bash
tools/squad/squad.sh run-loop --role commander    # 唯一 leader
tools/squad/squad.sh run-loop --role engineer-a   # follower：等 leader 信号
tools/squad/squad.sh run-loop --role engineer-b
tools/squad/squad.sh run-loop --role reviewer
tools/squad/squad.sh agent-team                   # tmux 起 4 条 run-loop
```

### 指挥长 C（leader）

- 只有 commander 跑 `run-loop` 时进入 **supervise** 分支，写 `signals.supervisor`
- `running` → 波次中；`standby` → 门禁已过但任务未清空；`complete|failed|timeout` → 全队退出
- **禁止** 在 `assess.ready` 时立刻 `complete`（`team_mode`）；须任务全 done 且指派清空后 `release_team`

### 队员 A/B/R（follower）

- **同一** `run-loop`，内部 `member_tick`；**禁止** 调用 `supervise`
- 无任务时 `action=await_leader`，在 while 里 sleep，直到 `supervisor` 为 `complete|failed|timeout`
- `supervisor.auto_exec: true`（或 CLI `--auto-exec`）：tick 内自动 `claim`、跑 `verify`（持 `.squad/verify.lock`）；verify 通过时 stderr 打印建议的 `done` 命令，不自动提交

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

0. `squad run-loop --role engineer-a`（或 Cloud Agent 常驻此一条命令）

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
