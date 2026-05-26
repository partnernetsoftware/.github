# Wave57 — lispjit-c-delete（真 zero_c 轨 · archive 迁出）

**签收**：`v45.v45.lispjit_c_delete_continue.100=1` — **active `lispjit.c` 迁 `retired/` + Lisp 15link 替代绿**（**≠ 全 archive 零 C · ≠ v4.5 DONE**）。

| 轨 | plan |
|----|------|
| W1 | `runner-lispjit-c-lisp-replacement-prove.lisp` |
| W2 | `lispjit-c-archive-honest.lisp` |
| W3 | `converge-daily-v45-zero-c.lisp` |
| W4 | `selfhost-lispjit-c-delete-matrix.lisp` |

收敛脚本会执行：`archive/c/runner/lispjit.c` → `retired/lispjit.c.archived`

```bash
bash lab/nano-lisp-jit/scripts/v45-wave57-lispjit-c-delete-converge.sh
grep v45.v45.lispjit_c_delete_continue.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

**诚实未达**：`archive/c/runner/*.c` 其它文件 · host `.sh` · `tools/*.py`
