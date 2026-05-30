# Wave35 — `*.lisp` → `nano-lisp.com`（plan 面零 c/sh/py）

在 Wave34 之上，用 **mindmap 广度 + 四轨并发** 收束「仅 com + lisp」发行面。

| 轨 | 节点 | plan（规划） |
|----|------|----------------|
| W1 | `v45-lco-converge-lisp` | `bootstrap-v45-converge-lisp-only.lisp`（收敛迁入 plan） |
| W2 | `v45-lco-onion-default` | `bootstrap-v45-onion-lisp-only.lisp`（主洋葱） |
| W3 | `v45-lco-com-name` | `bootstrap-v45-nano-lisp-com-output.lisp`（产物路径） |
| W4 | `v45-lco-next-verify` | `bootstrap-v45-selfhost-next-lisp-only-verify.lisp` |
| T | `v45-lco-terminal` | `bootstrap-v45-mindmap-lisp-com-only-tree.lisp` |
| G | `v45-lco-goal` | `bootstrap-v45-goal-v45-lisp-com-only-100.lisp` |

```bash
bash lab/nano-lisp-jit/scripts/v45-wave35-lisp-com-only-converge.sh
grep v45.v45.lisp_com_only_continue.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

证据：`v45.lisp_com.output_named=1` · `v45.lisp_com.next_onion_lisp_only=1`

**诚实未达**：`.com` 体内 C codegen · 物理删 `archive/c/runner`
