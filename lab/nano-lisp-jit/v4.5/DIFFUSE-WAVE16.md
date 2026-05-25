# Wave16 — 洋葱 TDD × mindmap 树（四轨并发）

| 轨 | plan | 耦合 |
|----|------|------|
| W1 | `mindmap-verify-smoke` | 洋葱圈1 VM |
| W2 | `mindmap-com-lbin` | v4 `com-lbin-in-ape` |
| W3 | `mindmap-ir-exit` | IR 表 + slice |
| W4 | `mindmap-onion-ring` | `onion-lisp-only` 键 |

L2：`mindmap-onion-tree` · 回写 `mindmap-frontier-v45.json`

```bash
bash lab/nano-lisp-jit/scripts/v45-wave16-mindmap-converge.sh
```
