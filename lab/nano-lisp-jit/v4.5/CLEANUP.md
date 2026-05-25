# v4.5 清洗与反思（SSOT）

> **继续开发前**：先跑本节「一轮清洗」，再读 [`REFLECTION.md`](REFLECTION.md) §二十二。

## 证据键分层（避免误读 100%）

| 层级 | 键 | 含义 | 能声称什么 |
|------|-----|------|------------|
| L0 | `scoped.100` · `release.100` | 发行面 plan/com | scoped 洋葱绿 |
| L1 | `tier5.100` · `physical.zero_c=1` | 发行面树零 C | **≠** 全 monorepo 零 C |
| L2 | `goal.mindmap_tree.100` | 7 节点树 | 仅 Wave17 |
| L3 | `goal.onion_mindmap.unified.100` | 14 节点 | Wave18 子终局 |
| L4 | `selfhost.100` | S5+T3+代际 | 自举卷 |
| L5 | `goal.lisp_selfhost.unified.100` | 20 节点 | Wave20 |
| **L6** | **`goal.onion_tdd_tree_mindmap.100`** | **26 节点 + boundary** | **/goal 总签收** |

`v45-entry.evidence` 为 **append-only**（同键可出现多次）；审计用 canonical：

```bash
bash lab/nano-lisp-jit/scripts/v45-evidence-canonical.sh
# → lab/nano-lisp-jit/.build/v45-entry.evidence.canonical
```

## 日常唯一收敛链（不要混用旧 wave）

```bash
bash lab/nano-lisp-jit/scripts/v45-wave21-onion-tdd-tree-mindmap-100-converge.sh
# 内嵌：wave20 → wave19 → wave18 → … → wave3
```

| 脚本 | 状态 |
|------|------|
| `v45-wave17-*` · `v45-wave18-*` | 子集；已被 wave21 链覆盖 |
| `v45-wave20-*` | 自举专卷；wave21 已内嵌 |
| **`v45-wave21-*`** | **/goal 日常真源** |

## 一轮清洗（推荐命令）

```bash
bash lab/nano-lisp-jit/scripts/v45-cleanup-reflect.sh
python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
grep v45.goal.onion_tdd_tree_mindmap.100=1 \
  lab/nano-lisp-jit/.build/v45-entry.evidence.canonical
```

产出：`v45.cleanup.reflect=1` · `v45.cleanup.canonical=1`

## 活图

- SSOT：[`mindmap-frontier-v45.json`](mindmap-frontier-v45.json)
- 终局：**26/26** `done`（layer 0–13）
- DP：`tools/mindmap-dp-v45.py ready|stats`

## 仍开卷（清洗后也不混称 /goal）

| 项 | 说明 |
|----|------|
| v4 全图 69 节点 | 独立 SSOT，≠ v45 % |
| S4/S5 plan 内 `archive/runner/lispjit.c` | 工厂路径；日常 host 不 cc |
| 全 monorepo `physical.zero_c` | 见 `HONEST-REMAINING.md` |

## 历史（2026-05-24 目录清理）

| 动作 | 前 | 后 |
|------|-----|-----|
| SLICE 文档 | `archive/v4/slices/`（244） | 已归档 |
| `v4/` 活跃 md | ~260 | **14** + INDEX |

证据：`v45.cleanup.ok=1`（早期目录清理）
