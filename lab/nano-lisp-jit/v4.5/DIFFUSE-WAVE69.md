# Wave69 — run-sh-archive-honest（run.sh 工厂面诚实分层 · 用户 COM+plan 不依赖）

**签收**：`v45.v45.run_sh_archive_honest_continue.100=1` — **Wave68 rollup + run.sh 工厂面显式分层**（**≠ 删 run.sh · ≠ v4.5 DONE**）。

| 轨 | plan |
|----|------|
| W1 | `run-sh-factory-honest-prove.lisp` |
| W2 | `run-sh-archive-honest.lisp` |
| W3 | `converge-daily-v45-factory-honest-terminal.lisp` |
| W4 | `selfhost-run-sh-archive-honest-matrix.lisp` |

收敛（`retired/scripts/` · 用户路径纯 COM+plan）写入：`v45.honest.run_sh_factory_only=1` · `v45.honest.archive_symlink_ci_only=1`

```bash
bash lab/nano-lisp-jit/retired/scripts/v45-wave69-run-sh-archive-honest-converge.sh
grep v45.v45.run_sh_archive_honest_continue.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

**诚实未达**：`run.sh` 仍读 `archive/c/` symlink · `retired/` 全历史 · genesis 锚点仍在
