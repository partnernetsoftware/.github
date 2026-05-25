# 洋葱 TDD × tree-mind-map 耦合（v4.5 SSOT）

> **活图**：[`mindmap-frontier-v45.json`](mindmap-frontier-v45.json) · **DP**：`tools/mindmap-dp-v45.py`  
> **洋葱真源**：[`ONION-TDD.md`](ONION-TDD.md)

## 扩散循环（广度 × 并发）

```text
读 frontier-v45 → DP ready ≤4 槽 → 四轨 bootstrap 并行 → 一次 wave16/17 converge → 回写 evidence
```

```bash
python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py ready
bash lab/nano-lisp-jit/scripts/v45-wave17-goal-mindmap-100-converge.sh
```

## 洋葱圈 ↔ mindmap 层

| 洋葱圈 | mindmap layer | v45 节点 |
|--------|---------------|----------|
| 0 seed | L0 gate | `v45-onion-gate` |
| 1 VM | L1 | `v45-mindmap-verify-smoke` |
| 2 AOT/APE | L1 | `v45-mindmap-com-lbin` · `v45-mindmap-ir-exit` |
| 3 build | L2 | `v45-mindmap-onion-tree` |
| 5 DONE | L3 | `v45-goal-mindmap-tree` |

## 证据键（goal 100%）

| 键 | 含义 |
|----|------|
| `v45.mindmap.tree.coupled=1` | 洋葱 + frontier 耦合落地 |
| `v45.mindmap.parallel=4` | 四轨并发绿 |
| `v45.goal.mindmap_tree.100=1` | **本 /goal 卷 100%** |

前置：`v45.tier5.100=1` · `v45.scoped.100=1`
