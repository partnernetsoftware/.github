# v4.5 并行推进（扩散全局 · 精细并发）

> 方法继承 [`v4/PARALLEL.md`](../v4/PARALLEL.md)；载体改为 **`.com` + `bootstrap-v45-*.lisp`**，不新增 plan 内 `.sh`。

## 硬约束

```text
① 扩散 — 同一 wave 内四轨同时铺开 touch_paths（≤4 并发槽）
② 收敛 — 一次 com-only 矩阵（或轻量 v45-com-verify.sh）
③ 洋葱修 — 内圈 genesis/compare → VM boundary → 文档/证据
```

**禁止**：按单 op / 单 sample 顺序碎补；禁止两轨同改 `run.sh` 同一 case 块。

## 四轨（wave1 · 已登记 catalog-v45）

| 轨 | 角色 | 面 | 交付 |
|----|------|-----|------|
| **A** | engineer-a | 精细 boundary | `bootstrap-v45-boundary-{i64,ptr,func,rodata}.lisp` |
| **B** | engineer-b | 扩散全局 | `bootstrap-v45-diffuse-global.lisp` + `PRODUCT-FEEDBACK` |
| **C** | engineer-b | 并发洋葱 | `bootstrap-v45-onion-parallel-matrix.lisp` |
| **D** | reviewer | 评估/反思 | `PARALLEL.md` + `wave1-assess-tick` + evidence |

Reviewer 依赖 A/B/C 完成后 `wave1-v45-R` 签收。

## Agent 快路径

```bash
skills/squad-parallel/scripts/fast-wave.sh lab/nano-lisp-jit/squad/catalog-v45.yaml wave1-v45-diffuse-parallel

# 四轨实现后 — 收敛（com-only，勿全量 run.sh 阻塞）
lab/nano-lisp-jit/scripts/v45-com-verify.sh

tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v45.yaml assess
```

发行面 signoff 用 `v45-scoped-ci-run`（`tests.pass≥2`）；全量 `run.sh` 仍属 v4 工厂，合 `main` 前再拉。

## 证据键

| 键 | 含义 |
|----|------|
| `v45.wave1.diffuse=1` | 全局扩散 plan 绿 |
| `v45.wave1.parallel=4` | 四域 boundary 精细 plan 齐 |
| `v45.wave1.rollup=1` | wave1 四轨 + assess rollup |

## Wave2（完全自举 · 工厂矩阵 · 一轮扩散）

筹划：[`DIFFUSE-WAVE2.md`](DIFFUSE-WAVE2.md) · 实施：[`CONCURRENT-IMPL.md`](CONCURRENT-IMPL.md)

```bash
skills/squad-parallel/scripts/fast-wave.sh \
  lab/nano-lisp-jit/squad/catalog-v45.yaml wave2-v45-lisp-selfhost
# 四轨并行实现 → 一次收敛：
bash lab/nano-lisp-jit/scripts/v45-wave2-converge.sh
```

| 键 | 含义 |
|----|------|
| `v45.wave2.diffuse=1` | Wave2 全局扩散 |
| `v45.selfhost.modules_full=1` | 13/13 modules |
| `v45.selfhost.next_com=1` | next.com 跑 smoke |
| `v45.wave2.factory_matrix=1` | 发行面 plan 索引 |
| `v45.wave2.rollup=1` | reviewer rollup |

**Wave3** ✅：[`DIFFUSE-WAVE3.md`](DIFFUSE-WAVE3.md) — `v45-wave3-converge.sh` 替代 ~35 run_case；662 wave 样本已归档。

**Wave4** ✅：[`DIFFUSE-WAVE4.md`](DIFFUSE-WAVE4.md) — `v45-wave4-converge.sh`（wave3 + next 洋葱 + tier3/squad 锚点）。

**Wave5** ✅：[`DIFFUSE-WAVE5.md`](DIFFUSE-WAVE5.md) — lisp-only 洋葱 + scoped CI（`tests.pass=2`）+ `v45-wave5-converge.sh`。

**Wave6** ✅：[`DIFFUSE-WAVE6.md`](DIFFUSE-WAVE6.md) — 洋葱主门禁 + w3 探针 + `v45-factory-slim.sh`。

**Wave7** ✅：[`DIFFUSE-WAVE7.md`](DIFFUSE-WAVE7.md) — **发行面终局 100%** · `v45.release.100=1` · v4 factory skip。

**Wave8** ✅：[`DIFFUSE-WAVE8.md`](DIFFUSE-WAVE8.md) — **DECISION 终局 100%** · `v45.endgame.100=1` · tier3/4。

**Wave9** ✅：合卷键 `v45.warehouse.100`（非物理全仓）· run.sh guard。

**Wave10** ✅：[`DIFFUSE-WAVE10.md`](DIFFUSE-WAVE10.md) · [`HONEST-REMAINING.md`](HONEST-REMAINING.md) — `v45.physical.zero_c=0` 明示未完成。

**Wave11**（tier5 四轨并发）：[`DIFFUSE-WAVE11.md`](DIFFUSE-WAVE11.md)

```bash
bash lab/nano-lisp-jit/scripts/v45-wave11-tier5-converge.sh
```

| 键 | 含义 |
|----|------|
| `v45.wave11.parallel=4` | T5a/T5b/T5c/T5d 四轨 plan 并发跑 |
| `v45.tier5.runsh_default=1` | 无参 `run.sh` 默认 scoped |
| `v45.tier5.archive_symlinks=2` | lispjit + nano_bootstrap |
| `v45.physical.zero_c=0` | 仍 **未完成** |

**Wave12** ✅：[`DIFFUSE-WAVE12.md`](DIFFUSE-WAVE12.md) — 四轨并行归档 16× `nano_*.c`；`lispjit_ir` 真源 **2**。

```bash
bash lab/nano-lisp-jit/scripts/v45-wave12-tier5-converge.sh
```

**Wave13** ✅：[`DIFFUSE-WAVE13.md`](DIFFUSE-WAVE13.md) — `lispjit-ir` **零真 `.c`**；`physical.zero_c` 仍 0。

```bash
bash lab/nano-lisp-jit/scripts/v45-wave13-tier5-converge.sh
```

**Wave14–15** ✅：tier5 **100%** — [`DIFFUSE-WAVE15.md`](DIFFUSE-WAVE15.md)

```bash
bash lab/nano-lisp-jit/scripts/v45-wave15-tier5-100-converge.sh
```

**Wave16–17 /goal** ✅：[`MINDMAP-TDD-TREE.md`](MINDMAP-TDD-TREE.md) — `v45.goal.mindmap_tree.100=1`

```bash
bash lab/nano-lisp-jit/scripts/v45-wave17-goal-mindmap-100-converge.sh
```

**Wave21 /goal 总签收** ✅：frontier **26/26** — `v45.goal.onion_tdd_tree_mindmap.100=1`  
日常：`v45-wave21-onion-tdd-tree-mindmap-100-converge.sh`

```bash
bash lab/nano-lisp-jit/scripts/v45-wave18-mindmap-unified-converge.sh
python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
```
