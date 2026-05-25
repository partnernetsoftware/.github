# v4 slice-4 — squad S4 agent-team（scoped）

**前置**：[`SLICE3.md`](SLICE3.md)、[`LISP-ONLY.md`](LISP-ONLY.md)。

## 目标

| 轨 | 交付 | 非目标 |
|----|------|--------|
| **S4 host** | `agent-team` 四角色 `run-loop`（tmux） | Lisp 并行 4× `squad-run-loop` |
| **S4 follower** | `team_ready` → `stand_down`（不等 `standby`） | 长驻生产编排 |
| **S4 leader** | signoff 100% + 任务全 terminal → `supervise --once` → `complete` | 无限叠 `wave` |
| **样本** | `bootstrap-v4-squad-s4-agent-team.lisp` | |

## 四角色流程（host）

```bash
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml resume --reason slice4
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml dispatch --force --include-meta
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml agent-team --auto-exec --auto-done
# 收尾：指挥长单独 run-loop 至 complete，或 supervise --once 当 team_ready
```

## run.sh 门禁

- `squad-v4-commander-complete-smoke` — 全任务 done + signoff ready 时 `supervise --once` → `outcome=complete`
- `run-bootstrap-v4-squad-s4-agent-team-plan` — S4 plan 样本
- `run-bootstrap-v4-slice4-evidence-plan` — 写入 `.build/v4-slice4.evidence`

## 证据

`.build/v4-slice4.evidence`（`v4.slice4=1`）

## 签收

`catalog-v4` → `signoff.id=v4-slice4-scoped`。
