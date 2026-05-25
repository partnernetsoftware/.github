# Wave20 — 洋葱×mindmap×lisp 完全自举统一（L8–L10 · 20 节点）

在 Wave19 `v45.selfhost.100=1` + Wave18 `goal.onion_mindmap.unified.100` 之上，把自举卷 **耦合进活图**。

| 轨 | 节点 |
|----|------|
| W1 | `v45-sh-lisp-only-chain` |
| W2 | `v45-sh-next-matrix` |
| W3 | `v45-sh-gen2-onion`（`v45-w19-lisp-gen2.com` 跑 `onion-tdd`） |
| W4 | `v45-sh-w3-regenesis` |
| L9 | `v45-sh-selfhost-terminal` |
| L10 | **`v45-goal-lisp-selfhost-unified`** |

```bash
bash lab/nano-lisp-jit/scripts/v45-wave20-lisp-selfhost-unified-converge.sh
grep v45.goal.lisp_selfhost.unified.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
```

证据：`v45.mindmap.nodes_done=20` · `v45.goal.lisp_selfhost.unified.100=1`
