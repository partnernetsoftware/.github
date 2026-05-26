# 洋葱 TDD × tree-mind-map 耦合（v4.5 SSOT）

> **活图**：[`mindmap-frontier-v45.json`](mindmap-frontier-v45.json) · **DP**：`tools/mindmap-dp-v45.py`  
> **洋葱真源**：[`ONION-TDD.md`](ONION-TDD.md)

## 扩散循环（广度 × 并发）

```text
读 frontier-v45 → DP ready ≤4 槽 → 四轨 bootstrap 并行 → 一次 wave16/17 converge → 回写 evidence
```

```bash
python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py ready
bash lab/nano-lisp-jit/scripts/v45-wave21-onion-tdd-tree-mindmap-100-converge.sh
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
| `v45.goal.mindmap_tree.100=1` | Wave17 基础树 100% |
| `v45.goal.onion_mindmap.unified.100=1` | **Wave18 全 frontier 14/14** |
| `v45.selfhost.100=1` | Wave19 完全自举 |
| `v45.goal.lisp_selfhost.unified.100=1` | Wave20 洋葱×mindmap×自举 20/20 |
| `v45.goal.onion_tdd_tree_mindmap.100=1` | **Wave21 /goal 总签收 26/26** |
| `v45.mindmap.nodes_done` / `nodes_total` | 活图覆盖率（终局 **26**） |
| `v45.mindmap.codegen.nodes_done` / `nodes_total` | **扩展活图**（Wave27 · 终局 **7**） |
| `v45.mindmap.factory.nodes_done` / `nodes_total` | **工厂物理活图**（Wave28 · **7**） |
| `v45.mindmap.selfhost_deep.nodes_done` / `nodes_total` | **selfhost 深度**（Wave29 · **7**） |
| `v45.mindmap.goal_factory.nodes_done` / `nodes_total` | **/goal×工厂**（Wave30 · **7**） |
| `v45.mindmap.boundary_next.nodes_done` / `nodes_total` | **边界代际**（Wave31 · **7**） |
| `v45.mindmap.rollup.nodes_done` / `nodes_total` | **工厂 rollupy**（Wave32 · **7**） |
| `v45.mindmap.codegen_deep.nodes_done` / `nodes_total` | **codegen 代际**（Wave33 · **7**） |
| `v45.mindmap.runner_codegen.nodes_done` / `nodes_total` | **runner 广面**（Wave34 · **7**） |

前置：`v45.tier5.100=1` · `v45.scoped.100=1` · `/goal` 26/26

## 扩展活图（工厂 codegen · Wave27+）

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-codegen.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
bash lab/nano-lisp-jit/scripts/v45-wave27-codegen-coupled-converge.sh
```

## 扩展活图（工厂物理 · Wave28+）

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-factory.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
bash lab/nano-lisp-jit/scripts/v45-wave28-factory-physical-continue-converge.sh
```

## 扩展活图（selfhost 深度 · Wave29+）

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-selfhost-deep.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
bash lab/nano-lisp-jit/scripts/v45-wave29-selfhost-deep-continue-converge.sh
```

## 扩展活图（/goal×工厂 · Wave30+）

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-goal-factory.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
bash lab/nano-lisp-jit/scripts/v45-wave30-goal-factory-unified-converge.sh
```

## 扩展活图（边界代际 · Wave31+）

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-boundary-next.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
bash lab/nano-lisp-jit/scripts/v45-wave31-terminal-continue-converge.sh
```

## 扩展活图（工厂 rollupy · Wave32+）

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-rollup.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
bash lab/nano-lisp-jit/scripts/v45-wave32-factory-rollup-continue-converge.sh
```

## 扩展活图（codegen 代际深潜 · Wave33+）

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-codegen-deep.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
bash lab/nano-lisp-jit/scripts/v45-wave33-codegen-deep-continue-converge.sh
```

## 扩展活图（runner 广面 · Wave34+）

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-runner-codegen.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
bash lab/nano-lisp-jit/scripts/v45-wave34-runner-codegen-continue-converge.sh
```

| 键 | 活图 |
|----|------|
| `v45.mindmap.runner_codegen.nodes_done` / `nodes_total` | **7** · `mindmap-frontier-v45-runner-codegen.json` |
| `v45.v45.runner_codegen_continue.100=1` | Wave34 |

## 日常（/goal 终局）

```bash
bash lab/nano-lisp-jit/scripts/v45-wave21-onion-tdd-tree-mindmap-100-converge.sh
python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
grep v45.goal.onion_tdd_tree_mindmap.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

## 合并 main（2026-05-25）

进度：[`EVAL.md`](EVAL.md) · 反思：[`REFLECTION.md`](REFLECTION.md) §二十二 · 清洗：[`CLEANUP.md`](CLEANUP.md)
