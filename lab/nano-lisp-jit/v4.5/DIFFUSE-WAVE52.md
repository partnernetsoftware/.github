# Wave52 — v5-open-maintenance（v4.5 后维护轨）

**签收**：`v45.v45.v5_open_maintenance_continue.100=1` — **v4.5 DONE 状态维护 + v5 诚实开卷**（≠ 154KB 物理 DONE）。

| 轨 | plan |
|----|------|
| W1 | `v45-done-state-rollup.lisp` |
| W2 | `v5-open-honest-anchor.lisp` |
| W3 | `converge-daily-v45-maintenance.lisp` |
| W4 | `selfhost-v5-open-matrix.lisp` |

```bash
bash lab/nano-lisp-jit/scripts/v45-wave52-v5-open-maintenance-converge.sh
grep v45.v45.v5_open_maintenance_continue.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

**用户日常入口（维护）**：`converge-daily-v45-maintenance.lisp`

**下一开卷（v5 物理轨）**：154KB 全 Lisp codegen · `nano-lisp.com` 硬切 · CI plan-only
