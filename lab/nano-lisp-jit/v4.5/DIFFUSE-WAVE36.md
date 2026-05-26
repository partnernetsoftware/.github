# Wave36 — plan 内收敛 + 默认洋葱 + `nano-lisp.com` 矩阵

在 Wave35 之上，用 **mindmap 广度 + 四轨并发** 收束 plan 面收敛（用户路径零 `.sh` 步骤）。

| 轨 | 节点 | plan（规划） |
|----|------|----------------|
| W1 | `v45-pc-converge-all` | `bootstrap-v45-converge-all.lisp`（plan 内链式 verify + selfhost） |
| W2 | `v45-pc-onion-default` | `bootstrap-v45-onion-default-all.lisp`（默认洋葱主路径） |
| W3 | `v45-pc-com-matrix` | `bootstrap-v45-nano-lisp-com-matrix.lisp`（产物矩阵） |
| W4 | `v45-pc-next-verify` | `bootstrap-v45-selfhost-nano-lisp-com-verify.lisp` |
| T | `v45-pc-terminal` | `bootstrap-v45-mindmap-plan-converge-tree.lisp` |
| G | `v45-pc-goal` | `bootstrap-v45-goal-v45-plan-converge-100.lisp` |

```bash
bash lab/nano-lisp-jit/scripts/v45-wave36-plan-converge-converge.sh
grep v45.v45.plan_converge_continue.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

证据：`v45.converge.plan_all=1` · `v45.onion.default_all=1` · `v45.lisp_com.matrix_profiles=4`

**诚实未达**：`.com` 体内 C codegen · 物理删 `archive/c/runner` · 日常仍用 `scripts/v45-*.sh` 作 host 编排
