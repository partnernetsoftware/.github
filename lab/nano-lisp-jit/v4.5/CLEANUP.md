# v4.5 清洗与反思（SSOT）

> **继续开发前**：先跑本节「一轮清洗」，再读 [`REFLECTION.md`](REFLECTION.md) §三十五。

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
| L7 | `v45.*.continue.100` | 扩展活图 Wave34–63 | **分卷签收**，≠ v4.5 DONE |

`v45-entry.evidence` 为 **append-only**（同键可出现多次）；审计用 canonical：

```bash
bash lab/nano-lisp-jit/scripts/v45-evidence-canonical.sh
# → lab/nano-lisp-jit/.build/v45-entry.evidence.canonical
```

## 日常收敛链（推荐顺序 · 2026-05-26 更新）

```bash
# v4.5 目标 daily（默认 · 快 seed ~1s）
bash lab/nano-lisp-jit/scripts/v45-wave63-nano-lisp-com-native-bootstrap-converge.sh

COM=lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-nano-lisp-com-native.lisp

# /goal 总签收（慢 · 完整链）
bash lab/nano-lisp-jit/scripts/v45-wave21-onion-tdd-tree-mindmap-100-converge.sh

# 最快：canonical + wave53 快收敛 + 证据核对
bash lab/nano-lisp-jit/scripts/v45-cleanup-reflect.sh
```

| 脚本 | 用途 |
|------|------|
| **`v45-wave63-nano-lisp-com-native-bootstrap-converge.sh`** | **v4.5 目标轨 · nano-lisp.com 原生 bootstrap** |
| `v45-wave62-nano-lisp-com-host-only-converge.sh` | Wave62 COM 统一复核（`retired/scripts/`） |
| `v45-wave60-ci-shell-retire-converge.sh` | Wave60 `physical.zero_cpysh=1` 复核（`retired/scripts/`） |
| `v45-wave56-zero-cpysh-target-converge.sh` | Wave56 四轨 rollup 复核 |
| `v45-wave55-tools-py-plan-only-converge.sh` | 消 py 复核 |
| `v45-wave50-lispjit-codegen-dedicated-converge.sh` | 154KB codegen 独立活图 |
| `v45-wave49-endgame-honest-rollup-converge.sh` | Wave44–48 rollup + 诚实终局 |
| `v45-wave21-*` | /goal 26/26 总签收 |
| `v45-wave34-*` | runner 广面（历史子集） |
| `v45-wave33~21` | 工厂/codegen 子链，勿单独当终局 |

## 一轮清洗（推荐命令）

```bash
bash lab/nano-lisp-jit/scripts/v45-cleanup-reflect.sh
NANO_V45_FRONTIER=mindmap-frontier-v45-tools-py-retire.json \
  python3 lab/nano-lisp-jit/retired/tools/mindmap-dp-v45.py stats
grep v45.v45.nano_lisp_com_native_bootstrap_continue.100=1 \
  lab/nano-lisp-jit/.build/v45-entry.evidence.canonical
grep v45.physical.zero_cpysh=1 \
  lab/nano-lisp-jit/.build/v45-entry.evidence.canonical
```

产出：`v45.cleanup.reflect=1` · `v45.cleanup.canonical=1`

## 活图

- SSOT 主树：[`mindmap-frontier-v45.json`](mindmap-frontier-v45.json) — **26/26**
- 扩展活图：**29 张**（Wave34–63）
- 当前前沿：`mindmap-frontier-v45-nano-lisp-com-native-bootstrap.json`
- DP：`retired/tools/mindmap-dp-v45.py`（维护层已归档；活图 JSON 直读）

## 仍开卷（清洗后也不混称 /goal）

| 项 | 说明 |
|----|------|
| v4 全图 69 节点 | 独立 SSOT，≠ v45 % |
| 全 monorepo `physical.zero_c` | 见 `HONEST-REMAINING.md` |
| **runner 全量 codegen** | **154KB** · 独立键 · Wave50+ |
| CI `scripts/v45-*.sh` | 用户路径已 plan-only；host 外层仍 .sh |

## 历史（2026-05-24 目录清理）

| 动作 | 前 | 后 |
|------|-----|-----|
| SLICE 文档 | `archive/v4/slices/`（244） | 已归档 |
| `v4/` 活跃 md | ~260 | **14** + INDEX |

证据：`v45.cleanup.ok=1`（早期目录清理）
