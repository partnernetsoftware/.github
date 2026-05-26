# Wave56 — zero-cpysh-target（v4.5 四轨 rollup · 诚实 gap）

**签收**：`v45.v45.zero_cpysh_target_continue.100=1` — **Wave52–55 物理四轨 rollup + gap 锚**（**≠ `physical.zero_cpysh=1` · ≠ v4.5 DONE**）。

| 轨 | plan |
|----|------|
| W1 | `physical-zero-cpysh-target-rollup.lisp` |
| W2 | `physical-zero-cpysh-honest-gap.lisp` |
| W3 | `converge-daily-v45-target.lisp` |
| W4 | `selfhost-zero-cpysh-target-matrix.lisp` |

```bash
bash lab/nano-lisp-jit/scripts/v45-wave56-zero-cpysh-target-converge.sh
grep v45.v45.zero_cpysh_target_continue.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

**诚实 gap**：`lispjit.c` · host `.sh` · `tools/*.py` — 见 W2
