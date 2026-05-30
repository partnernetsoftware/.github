# Wave66 — archive-factory-lisp-retire（factory lisp 物理退仓 · 用户 plan 零 archive 路径）

**签收**：`v45.v45.archive_factory_lisp_retire_continue.100=1` — **Wave65 rollup + `archive/c/factory` 迁 `retired/`**（**≠ 零 wave converge .sh · ≠ v4.5 DONE**）。

| 轨 | plan |
|----|------|
| W1 | `archive-factory-lisp-retire-prove.lisp` |
| W2 | `archive-factory-lisp-honest-retire.lisp` |
| W3 | `converge-daily-v45-zero-archive-path.lisp` |
| W4 | `selfhost-archive-factory-lisp-retire-matrix.lisp` |

收敛脚本会执行：`archive/c/factory` → `retired/archive-c/factory` + symlink · `v45-wave65*.sh` → `retired/scripts/`

```bash
bash lab/nano-lisp-jit/scripts/v45-wave66-archive-factory-lisp-retire-converge.sh
grep v45.v45.archive_factory_lisp_retire_continue.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

**诚实未达**：wave66 converge `.sh` 壳仍在 · CI `run.sh` 经 symlink 仍读 archive · bootstrap promote 仍种子
