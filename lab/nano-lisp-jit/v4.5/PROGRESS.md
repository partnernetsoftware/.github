# v4.5 进度（诚实口径）

## 已签收 ✅（有定义、有证据，可引用）

| 口径 | 键 | 说明 |
|------|-----|------|
| scoped 洋葱 | `v45.scoped.100=1` | `.com` + `bootstrap-v45-*.lisp` |
| 发行面 | `v45.release.100=1` | 上列 + boundary |
| DECISION tier0–4 | `v45.endgame.100=1` | 含 tier3 `lispjit.c` 迁 `archive/runner`、tier4 IR smoke |
| scoped 工厂栈 | `v45.factory.100=1` | **`NANO_V45_SCOPED_ONLY=1` 时** skip v4 墙 |
| 合卷（非物理全仓） | `v45.warehouse.100=1` | = endgame ∧ factory；**≠ 零 `.c`** |

详见 [`HONEST-REMAINING.md`](HONEST-REMAINING.md)。

## 未完成 ❌（禁止写成 100%）

| 项 | 诚实键 |
|----|--------|
| 全仓零 `.c` | 发行面已 `physical.zero_c=1`；全 monorepo 见 `HONEST-REMAINING` |
| 无 env 瘦 `run.sh` | 未达 |
| 全量 runner Lisp codegen | 未达 |

## /goal 已签收 ✅

| 项 | 键 |
|----|-----|
| tier5 发行面 | `v45.tier5.100=1` |
| lisp 自举 | `v45.selfhost.100=1` |
| **总签收** | **`v45.goal.onion_tdd_tree_mindmap.100=1`** · frontier **26/26** |

## 收敛（清洗后日常）

```bash
bash lab/nano-lisp-jit/scripts/v45-cleanup-reflect.sh
# 或完整收敛：v45-wave21-onion-tdd-tree-mindmap-100-converge.sh
grep v45.goal.onion_tdd_tree_mindmap.100=1 \
  lab/nano-lisp-jit/.build/v45-entry.evidence.canonical
```

## Wave

| Wave | 内容 |
|------|------|
| 3–9 | DECISION + 工厂 scoped（见 `DIFFUSE-WAVE*.md`） |
| **10** | [`DIFFUSE-WAVE10.md`](DIFFUSE-WAVE10.md) — 诚实剩余 + `v45-release-run.sh` |
| **11** | [`DIFFUSE-WAVE11.md`](DIFFUSE-WAVE11.md) — tier5 四轨并发；`physical.zero_c` 仍 0 |
| **12** | [`DIFFUSE-WAVE12.md`](DIFFUSE-WAVE12.md) — 16 TU 并行出仓；`ir` 真 `.c`=2 |
| **13** | [`DIFFUSE-WAVE13.md`](DIFFUSE-WAVE13.md) — `ir` 门面零真 `.c` |
| **14–15** | VM emit 四轨 + **tier5 100%** — [`DIFFUSE-WAVE15.md`](DIFFUSE-WAVE15.md) |
| **16–17** | 洋葱×mindmap-tree — [`DIFFUSE-WAVE17.md`](DIFFUSE-WAVE17.md) |
| 18 | `onion_mindmap.unified` — 14/14 [`DIFFUSE-WAVE18.md`](DIFFUSE-WAVE18.md) |
| 19–20 | lisp 自举 + 20 节点 [`DIFFUSE-WAVE19.md`](DIFFUSE-WAVE19.md) [`DIFFUSE-WAVE20.md`](DIFFUSE-WAVE20.md) |
| 21 | /goal 总签收 26/26 [`DIFFUSE-WAVE21.md`](DIFFUSE-WAVE21.md) |
| 22 | 工厂 S4/S5 plan 零 C [`DIFFUSE-WAVE22.md`](DIFFUSE-WAVE22.md) |
| 23 | 继续卷 代际矩阵 + v4 握手 [`DIFFUSE-WAVE23.md`](DIFFUSE-WAVE23.md) |
| **24** | 发行面继续 core/modules 代际 [`DIFFUSE-WAVE24.md`](DIFFUSE-WAVE24.md) |
| **25** | **codegen 探针** lisp slice 四轨 [`DIFFUSE-WAVE25.md`](DIFFUSE-WAVE25.md) |
| **26** | **codegen 扩面** VM emit + next-lo 最小 onion [`DIFFUSE-WAVE26.md`](DIFFUSE-WAVE26.md) |
