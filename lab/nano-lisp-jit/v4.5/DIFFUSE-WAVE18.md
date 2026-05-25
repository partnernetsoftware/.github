# Wave18 — mindmap 统一扩展（L4–L7 · 14 节点全 done）

在 Wave17 `goal.mindmap_tree.100` 基础上，把 v4 DP 层 **boot/bare/core/selfhost** 迁入 v45 洋葱树。

| 轨 | 节点 |
|----|------|
| W1 | `v45-mm-boot-com` |
| W2 | `v45-mm-bare-loader` |
| W3 | `v45-mm-verify-core-slice` |
| W4 | `v45-mm-selfhost-next` |
| L5 | `v45-mm-onion-terminal` |
| L6 | `v45-mm-unified-tree` |
| L7 | **`v45-goal-onion-mindmap-unified`** |

```bash
bash lab/nano-lisp-jit/scripts/v45-wave18-mindmap-unified-converge.sh
grep v45.goal.onion_mindmap.unified.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

证据：`v45.mindmap.nodes_done=14` · `v45.goal.onion_mindmap.unified.100=1`
