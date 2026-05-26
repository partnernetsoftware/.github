# 下一步：洋葱 TDD × tree-mind-map（Wave34 · fasmgx）

> **前置**：/goal **26/26** · Wave33 `codegen_deep_continue.100` · 诚实未达见 [`../lab/nano-lisp-jit/v4.5/HONEST-REMAINING.md`](../lab/nano-lisp-jit/v4.5/HONEST-REMAINING.md)

## 目标（Wave34）

在 **selfhost-next.com** 上把 codegen 从「四轨探针」扩到 **runner 广面**（模块表 + emit 宽表 + ir-facade 复核），仍 **不改** `/goal` 26 节点。

| 轨 | 规划 plan | 节点 id |
|----|-----------|---------|
| W1 | `bootstrap-v45-codegen-runner-module-table.lisp`（待建） | `v45-rc-module-table` |
| W2 | `bootstrap-v45-codegen-runner-emit-broad.lisp`（待建） | `v45-rc-emit-broad` |
| W3 | `bootstrap-v45-codegen-ir-facade-next.lisp`（待建） | `v45-rc-ir-facade` |
| W4 | `bootstrap-v45-codegen-lispjit-modules-subset.lisp`（待建） | `v45-rc-modules-subset` |
| R | `bootstrap-v45-runsh-slim-terminal.lisp`（已有） | 发行锚 |
| T | `bootstrap-v45-mindmap-runner-codegen-tree.lisp`（待建） | `v45-rc-terminal` |
| G | `bootstrap-v45-goal-v45-runner-codegen-continue-100.lisp`（待建） | `v45-rc-goal` |

## 扩散循环（同 Wave27–33）

```text
读 fasmgx/mindmap-frontier-runner-codegen.json
  → DP ready ≤4
  → 四轨 bootstrap 并行（host + next）
  → v45-wave34-runner-codegen-continue-converge.sh（待实现）
  → evidence: v45.v45.runner_codegen_continue.100=1
```

## DP

```bash
FASMGX_FRONTIER=mindmap-frontier-runner-codegen.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py ready
```

## 签收键（规划）

| 键 | 含义 |
|----|------|
| `v45.mindmap.runner_codegen.nodes_done` / `nodes_total` | 活图 **7/7** |
| `v45.codegen.runner_broad_profiles=4` | next 四轨广面绿 |
| `v45.v45.runner_codegen_continue.100=1` | Wave34 卷签收 |

## 禁止混称

- **≠** `goal.onion_tdd_tree_mindmap.100` 重开
- **≠** 154KB 全 C 替代（广面探针绿后仍写诚实未达）
- **≠** 物理删 `run.sh`

## 收敛链顺序（实现 Wave34 时）

1. `v45-wave33-codegen-deep-continue-converge.sh`
2. 新建四轨 plan + matrix + rollup lisp
3. `v45-wave34-runner-codegen-continue-converge.sh`
4. 更新 `run.sh` gate · `catalog-v45.yaml` 默认指向 wave34
