# v4 — 终局切片 + 产品轨

**前置**：v3.5-scoped + v3.5-terminal 已签收（见 [`../v3.5/DECISION.md`](../v3.5/DECISION.md)）。

**「全 Lisp」口径**：见 [`LISP-ONLY.md`](LISP-ONLY.md) — v4 **plan 层**可无 `.c` 引用；**runner/codegen 层**仍含 C（slice-2 才攻真 codegen）。

## 范围（首波）

| 轨 | 目标 | 非目标（本波） |
|----|------|----------------|
| **slice** | aarch64 VM/AOT 真 codegen（非 add-emit 硬编码） | 全量 `lispjit.c` 单 TU 替换 |
| **编排** | bootstrap 内 squad 状态机草图（替代 host Python） | 完整分布式多机 |
| **产品** | NDTSV / SQL / qjs 探路文档 | 生产级产品 |

## 小队

```bash
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml resume
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml dispatch --force --include-meta
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml agent-team --auto-exec
```

**签收**：slice-0..8（**`v4-slice8-scoped`** — lowering 表 + add13）— 见 [`SLICE8.md`](SLICE8.md)；小队用 `agent-team` 并行推进，见 [`REFLECTION.md`](REFLECTION.md)。

```bash
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml agent-team --auto-exec --auto-done
```

**小队**：四角色固定进程 — `agent-team --auto-exec --auto-done`（一进程一角色，保持上下文稳定）。

## 证据

- `run.sh` / `build_nano_jit.sh` 不退化
- 新样本只增 `samples/bootstrap-v4-*.lisp`

## Bootstrap 替代 Python squad（草图）

**稳定协议**（少改）：`catalog.yaml` 任务图、`signals.supervisor` 三态出口、`run-loop --role`、leader/follower 分离。见 [`../squad/PROTOCOL.md`](../squad/PROTOCOL.md)。

**替换 host 层**（v4 切片目标）：`tools/squad/*.py` + `squad.sh` + tmux → **同一套 bootstrap / slice runner** 内的 squad 子命令。Python 实现见 `tools/squad/engine/supervisor.py`（`dispatch_wave`、`supervise_tick`、`member_tick`、`run_supervise`）。

### 映射表：Python → bootstrap 步骤

| Python / CLI | 行为 | 拟议 bootstrap 步骤（按落地顺序） |
|--------------|------|-----------------------------------|
| `load catalog` | 读 `catalog.yaml` 角色/任务/门禁 | `(squad-load-catalog "squad/catalog-v4.yaml")` → 内存 catalog 句柄 |
| `assess` | 读证据文件，算 signoff % | `(squad-assess catalog state-db)`；门禁复用现有 `(file-size …)` / `(file-hash …)` / `(grep-results …)` |
| **`dispatch`** | 空闲 worker → pending 任务，`dispatch_assign` | `(squad-dispatch catalog state-db :max-tasks 2)` — 写 `assignments` + 各 role `signal=running` |
| **`signal`** | 写 `signals` 表 | `(squad-signal "supervisor" "standby" :reason "signoff_ready_team_busy")`；`(squad-signal "engineer-b" "running" :task-id "…")` |
| **`run-loop` leader** | `run_supervise` → 循环 `supervise_tick` | `(squad-run-loop :role commander :poll-interval 15 :timeout 7200)` — 内部：assess → dispatch → 更新 `supervisor` |
| **`run-loop` follower** | `member_tick` → 等 leader，不调用 supervise | `(squad-run-loop :role engineer-b …)` — 读 `supervisor`∈{running,standby} 继续；∈{complete,failed,timeout} 退出 |
| `claim` | SQLite `path_locks` + `in_progress` | `(squad-claim state-db role task-id)` — `BEGIN IMMEDIATE` 锁 `touch_paths` |
| `verify` | 跑 `catalog.verify.commands` | `(run-bootstrap-plan "samples/bootstrap-v4-kickoff.lisp")` 或 catalog 内嵌 verify plan |
| `done` | 释放锁、任务 `done`、记 commit | `(squad-done state-db role task-id :commit "abc1234")` |
| `export-json` / `sync-md` | 导出快照、渲染 board | `(squad-export state-db ".squad/state-v4.json")`；`(squad-sync-md board "v4/SQUAD.md")` |

### 分 slice 落地顺序

```text
slice S0 — 只读 + 证据（无 SQLite）
  (squad-load-catalog …)
  (squad-assess …)          ; 等价 assess，输出 percent/ready
  (file-hash ".build/results.txt") …

slice S1 — signals 内存表（单进程 smoke）
  (squad-signal "supervisor" "running")
  (squad-signal-read "supervisor") → "running"

slice S2 — state.db 持久化（FFI sqlite 或后续 .lbin 快照）
  (squad-open-db ".squad/state-v4.db")
  (squad-dispatch …)        ; 替代 cmd_dispatch + dispatch_wave
  (squad-claim …)           ; 替代 path_locks

slice S3 — run-loop 单 tick（--once）
  (squad-supervise-tick …)  ; leader 一拍：assess + dispatch + supervisor 信号
  (squad-member-tick …)     ; follower 一拍：await_leader | claim | work

slice S4 — 完整 run-loop + agent-team
  4× `(squad-run-loop :role …)` 并行（替代 tmux + squad.sh）
  commander 持 standby 至任务全 done 再 `(squad-signal "supervisor" "complete")`

slice S5 — 与构建图合一
  工单内嵌 verify plan：`(run-bootstrap-plan "samples/bootstrap-v4-<task>.lisp")`
  `(squad-done …)` 仅在 plan exit 0 后调用
```

### leader / follower 信号（与 Python 一致）

| `signals.supervisor` | follower 行为 |
|----------------------|---------------|
| `running` | 继续 `member_tick`；可 claim/work |
| `standby` | signoff 已过仍有任务；**禁止**自行 complete 退出 |
| `complete` | `stand_down`，退出 run-loop |
| `failed` / `timeout` | 全队 halt |

### 样本命名（本轨）

| 样本 | 覆盖 |
|------|------|
| `samples/bootstrap-v4-squad-assess.lisp` | S0：catalog 门禁 + file-hash |
| `samples/bootstrap-v4-squad-dispatch.lisp` | catalog 契约 smoke |
| `samples/bootstrap-v4-squad-s2-state.lisp` | **S2**：`state-v4.db` + JSON 导出 |
| `samples/bootstrap-v4-squad-run-loop-once.lisp` | host CLI 入口 smoke |
| `samples/bootstrap-v4-squad-s3-supervise-once.lisp` | **S3**：leader 单 tick |
| `samples/bootstrap-v4-squad-s3-member-once.lisp` | **S3**：follower 单 tick |
| `samples/bootstrap-v4-squad-s4-agent-team.lisp` | **S4**：agent-team 契约 |
| `samples/bootstrap-v4-squad-s5-verify-plan.lisp` | **S5**：verify-before-done 样本 |
| `samples/bootstrap-v4-codegen-kickoff.lisp` | **S6**：emit 路径锚点 + add7 回归 |
| `samples/bootstrap-v4-slice7-add11.lisp` | **S7**：`add-exit-v1` profile + 5+6→11 |

**反思 / 调整**：[`REFLECTION.md`](REFLECTION.md)（小队实践 + wave11+ 双轨策略）。

首波 **不实现** SQLite FFI；S0–S1 用 checked-in plan + 现有 runner 断言 stdout/exit，与 [`bootstrap-v4-kickoff.lisp`](../samples/bootstrap-v4-kickoff.lisp) 同模式。

### 与 host 并行的迁移策略

1. **v4 kickoff 波**：host `squad.sh --catalog catalog-v4.yaml` 仍为真相源（本任务之前的运行方式）。
2. **每个 S*n* 样本绿**：对应 Python 子命令可标记 `@deprecated`，但 catalog 字段不变。
3. **终局**：Cloud Agent 只跑 `(squad-run-loop :role engineer-b)`（Lisp 二进制），不再 `python3 squad_cli.py`。
