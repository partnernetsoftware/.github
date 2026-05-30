# Wave37 — plan 面零 `.sh` 编排 + `nano-lisp.com` 统一

在 Wave36 之上，用 **mindmap 广度 + 四轨并发** 收束 plan 面编排（squad + verify 矩阵 + 产物名）。

| 轨 | 节点 | plan（规划） |
|----|------|----------------|
| W1 | `v45-zs-squad-plan` | `bootstrap-v45-converge-squad-plan.lisp`（squad dispatch/assess） |
| W2 | `v45-zs-com-canonical` | `bootstrap-v45-nano-lisp-com-canonical.lisp`（产物名统一） |
| W3 | `v45-zs-verify-matrix` | `bootstrap-v45-verify-matrix-plan.lisp`（verify 迁入 plan） |
| W4 | `v45-zs-selfhost-matrix` | `bootstrap-v45-selfhost-lisp-com-matrix.lisp` |
| T | `v45-zs-terminal` | `bootstrap-v45-mindmap-zero-sh-tree.lisp` |
| G | `v45-zs-goal` | `bootstrap-v45-goal-v45-zero-sh-continue-100.lisp` |

```bash
bash lab/nano-lisp-jit/scripts/v45-wave37-zero-sh-converge.sh
grep v45.v45.zero_sh_continue.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

证据：`v45.converge.squad_plan=1` · `v45.lisp_com.canonical=1` · `v45.verify.matrix_plan=1`

**诚实未达**：`.com` 体内 C codegen · host 日常仍用 `scripts/v45-*.sh` 作外层编排
