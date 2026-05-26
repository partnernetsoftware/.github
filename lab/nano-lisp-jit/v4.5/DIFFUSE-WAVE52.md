# Wave52 — physical-zero-cpysh-continue（v4.5 物理续推）

**签收**：`v45.v45.physical_zero_cpysh_continue.100=1` — **扩展活图续推**；**≠ v4.5 目标达成**。

v4.5 真目标：**用户路径 plan 内零 `.c` / `.sh` / `.py`**，终局态仓库无残留。Wave51 仅为扩展活图 rollup，**禁止**混称 v4.5 DONE。

| 轨 | plan |
|----|------|
| W1 | `physical-zero-cpysh-inventory.lisp` |
| W2 | `physical-zero-cpysh-honest-anchor.lisp` |
| W3 | `converge-daily-zero-cpysh.lisp` |
| W4 | `selfhost-zero-cpysh-matrix.lisp` |

```bash
bash lab/nano-lisp-jit/scripts/v45-wave52-physical-zero-cpysh-continue-converge.sh
grep v45.v45.physical_zero_cpysh_continue.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

**用户日常入口**：`converge-daily-zero-cpysh.lisp`（plan-only · 无 `.sh` 步骤）

**诚实未达**：`archive/c/runner/lispjit.c` ~154KB · CI `scripts/v45-*.sh` · `tools/*.py`
