# fasmgx 清理清单

> 一轮清洗命令：`bash lab/nano-lisp-jit/scripts/v45-cleanup-reflect.sh`

## 保留（工厂真源）

| 路径 | 原因 |
|------|------|
| `lab/nano-lisp-jit/archive/runner/` | 154KB `lispjit.c` 等 TU 真源 |
| `lab/nano-lisp-jit/run.sh` | 维护者全量回归 |
| `lab/nano-lisp-jit/samples/bootstrap-v45-codegen-*.lisp` | codegen 探针 / 矩阵 |
| `lab/nano-lisp-jit/.build/v45-selfhost-next.com` | 代际收敛载体 |
| `lab/nano-lisp-jit/v4.5/mindmap-frontier-v45*.json` | 活图 SSOT（含扩展 8 张） |

## 不归入 fasmgx（避免双真源）

| 路径 | 归属 |
|------|------|
| `samples/bootstrap-v45-onion-tdd*.lisp` | 发行面 /goal |
| `v4.5/mindmap-frontier-v45.json` | /goal 26 节点 |
| `archive/v4/slices/` | 历史 wave 记账 |

## 本目录新增（2026-05-26）

| 动作 | 说明 |
|------|------|
| 建 `fasmgx/` | 工厂续推 SSOT，与 /goal 分卷 |
| 第九张活图 | [`mindmap-frontier-runner-codegen.json`](mindmap-frontier-runner-codegen.json) |
| DP | `FASMGX_FRONTIER=… python3 …/mindmap-dp-v45.py` |

## 证据核对

```bash
bash lab/nano-lisp-jit/scripts/v45-evidence-canonical.sh
grep -E 'goal\.onion_tdd_tree_mindmap|codegen_deep_continue|factory_rollup' \
  lab/nano-lisp-jit/.build/v45-entry.evidence.canonical
```
