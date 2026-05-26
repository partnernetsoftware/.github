# Wave65 — ci-sh-final-retire（CI 工具 .sh 终局退 retired · 用户路径纯 plan）

**签收**：`v45.v45.ci_sh_final_retire_continue.100=1` — **Wave64 rollup + CI 工具 sh 迁 retired**（**≠ 零 wave converge .sh · ≠ v4.5 DONE**）。

| 轨 | plan |
|----|------|
| W1 | `ci-sh-final-retire-prove.lisp` |
| W2 | `ci-sh-final-archive-honest.lisp` |
| W3 | `converge-daily-v45-plan-only-final.lisp` |
| W4 | `selfhost-ci-sh-final-retire-matrix.lisp` |

收敛脚本会执行：CI 工具 `v45-*.sh`（除 wave65）→ `retired/scripts/` · `v45-wave64*.sh` → `retired/scripts/`

```bash
bash lab/nano-lisp-jit/scripts/v45-wave65-ci-sh-final-retire-converge.sh
grep v45.v45.ci_sh_final_retire_continue.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

**诚实未达**：wave65 converge `.sh` 壳仍在 · `archive/c/factory/` 仍在 · bootstrap promote 仍种子
