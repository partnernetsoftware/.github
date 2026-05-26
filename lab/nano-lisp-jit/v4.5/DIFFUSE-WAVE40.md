# Wave40 — 日常入口 `converge-daily-plan.lisp`（替代外层 `.sh`）

> 用户日常：`$COM run-bootstrap-plan bootstrap-v45-converge-daily-plan.lisp`

| 轨 | 节点 | plan | 后台 |
|----|------|------|------|
| W1 | `v45-dp-converge-daily` | `converge-daily-plan.lisp` | engineer-a |
| W2 | `v45-dp-entry-anchor` | `daily-entry-anchor.lisp` | engineer-b |
| W3 | `v45-dp-squad-verify` | `squad-plan-verify.lisp` | engineer-a |
| W4 | `v45-dp-selfhost-daily` | `selfhost-daily-matrix.lisp` | engineer-b |

```bash
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-plan.lisp
bash lab/nano-lisp-jit/scripts/v45-wave40-daily-plan-converge.sh
grep v45.v45.daily_plan_continue.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

证据：`v45.converge.daily_plan=1` · `v45.entry.daily_converge=1`

**诚实未达**：CI/host 外层仍保留 `scripts/v45-*.sh` 作编排
