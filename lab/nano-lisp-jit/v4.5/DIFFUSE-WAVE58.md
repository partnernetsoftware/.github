# Wave58 — host-sh-retire（物理退 host `.sh` · plan-only 外层终局）

**签收**：`v45.v45.host_sh_retire_continue.100=1` — **历史 `v45-wave*.sh` 迁 `retired/scripts/` + 用户 daily 纯 plan**（**≠ 仓库零 `.sh` · ≠ v4.5 DONE**）。

| 轨 | plan |
|----|------|
| W1 | `host-sh-plan-only-replacement-prove.lisp` |
| W2 | `host-sh-archive-honest.lisp` |
| W3 | `converge-daily-v45-plan-only-outer.lisp` |
| W4 | `selfhost-host-sh-retire-matrix.lisp` |

收敛脚本会执行：`scripts/v45-wave*.sh`（除 wave58）→ `retired/scripts/`

```bash
bash lab/nano-lisp-jit/scripts/v45-wave58-host-sh-retire-converge.sh
grep v45.v45.host_sh_retire_continue.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

**诚实未达**：CI 仍跑 wave58 `.sh` · `tools/*.py` 维护仍在
