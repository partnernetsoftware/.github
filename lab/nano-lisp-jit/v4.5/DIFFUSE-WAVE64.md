# Wave64 — archive-c-factory-retire（runner C 物理退仓 · 用户 plan 零 archive/c）

**签收**：`v45.v45.archive_c_factory_retire_continue.100=1` — **Wave63 rollup + `archive/c/runner` C 迁 `retired/`**（**≠ 全 monorepo 零 C · ≠ v4.5 DONE**）。

| 轨 | plan |
|----|------|
| W1 | `archive-c-factory-retire-prove.lisp` |
| W2 | `archive-c-factory-honest-retire.lisp` |
| W3 | `converge-daily-v45-lisp-only-factory.lisp` |
| W4 | `selfhost-archive-c-factory-retire-matrix.lisp` |

收敛脚本会执行：`archive/c/runner` → `retired/archive-c/runner` + symlink · `scripts/v45-wave63*.sh` → `retired/scripts/`

```bash
bash lab/nano-lisp-jit/scripts/v45-wave64-archive-c-factory-retire-converge.sh
grep v45.v45.archive_c_factory_retire_continue.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

**诚实未达**：`archive/c/factory/` 工厂 lisp 仍在 · CI `run.sh` 仍引用 archive · bootstrap promote 仍种子
