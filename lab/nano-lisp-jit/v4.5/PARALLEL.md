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
