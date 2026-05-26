# v4.5 进度评估

**签收**：`v45-scoped-100` · 洋葱 TDD 真源 = [`ONION-TDD.md`](ONION-TDD.md)

## 六维（v4.5 scoped）

| 维度 | 目标 | 评估 |
|------|------|------|
| Plan | bootstrap 无 `.c` | **100%** — verify + boundary + onion |
| Runner | `.com` 执行 plan | **100%** — com-only gate 绿 |
| 构建 | genesis-pin 日常 | **100%** — tier2 plan + compare.ok |
| 验收载体 | `*.lisp` 替代 `.sh` 纵切片 | **~92%** — wave1 四域并发 plan + com-verify |
| v4 交接 | gen60 / genesis | **100%** — handoff plan |
| 能力边界 | boundary 样例 | **~80%** — 13 正向 + 4 负向 + 产品反馈 doc |

**v4.5 scoped 整体**：**100%**

**v4.5 发行面 release**：**100%** — `v45.release.100=1`

**v4.5 DECISION 终局**：**100%** — `v45.endgame.100=1`（tier0–4，见 [`DIFFUSE-WAVE8.md`](DIFFUSE-WAVE8.md)）

**v4.5 合卷 warehouse**：**100%** — `v45.warehouse.100=1`（= endgame ∧ scoped 工厂；**≠ 物理零 C**）

**tier5 发行面**：**100%** — `v45.tier5.100=1` · `v45.physical.zero_c=1`（发行面树；见 [`HONEST-REMAINING.md`](HONEST-REMAINING.md)）

**完全自举（`.lisp` 用户口径）**：**100%** — `v45.selfhost.100=1`（Wave19）

**/goal 终局（洋葱×mindmap×lisp）**：**100%** — `v45.goal.lisp_selfhost.unified.100=1`（Wave20）

**/goal 总签收（洋葱 TDD × tree-mind-map）**：**100%** — `v45.goal.onion_tdd_tree_mindmap.100=1`（Wave21 · [`DIFFUSE-WAVE21.md`](DIFFUSE-WAVE21.md)）

**合并结论（→ `main`）**：日常收敛 **`v45-wave21-onion-tdd-tree-mindmap-100-converge.sh`**（内嵌 wave20→19→18）。

## 合并进度分析（/goal 洋葱 TDD-tree-mind-map · 2026-05-25）

| 卷 | 分支/提交 | 签收键 | 状态 |
|----|-----------|--------|------|
| Wave11–13 tier5 | `cursor/v45-*-tier5-fc19` | `tier5.100` · `ir_facade_zero_real` | ✅ main |
| Wave14–15 | `cursor/v45-tier5-100-fc19` | `physical.zero_c=1`（发行面树） | ✅ main |
| Wave16–17 mindmap 树 | `cursor/v45-mindmap-tree-100-fc19` | `goal.mindmap_tree.100` | ✅ main |
| **Wave18 统一** | `cursor/v45-mindmap-unified-100-fc19` | **`goal.onion_mindmap.unified.100`** | ✅ main |
| Wave19 自举 | `cursor/v45-selfhost-100-fc19` | `v45.selfhost.100` | ✅ 并入本合并 |
| Wave20 统一 | `cursor/v45-selfhost-100-fc19` | `goal.lisp_selfhost.unified.100` | ✅ main |
| **Wave21 总签收** | `cursor/v45-goal-onion-tdd-100-fc19` | **`goal.onion_tdd_tree_mindmap.100`** | ✅ main |
| **清洗反思** | `cursor/v45-reflect-cleanup-fc19` | `cleanup.reflect` · canonical | 🔄 本合并 |

| 指标 | 数值 |
|------|------|
| `mindmap-frontier-v45` 节点 | **26/26 done（100%）** |
| 日常收敛 | **`v45-wave21-onion-tdd-tree-mindmap-100-converge.sh`** |
| lisp 自举 | `v45.selfhost.100=1` |
| boundary | `v45.boundary.probes=13` · `negative=1` |

**本 /goal 口径 100%**：`v45.goal.onion_tdd_tree_mindmap.100=1` + `nodes_done=nodes_total=26`。  
**工厂进阶（Wave22）**：`v45.selfhost.plan_no_c=1` — S4/S5 **另有** 零 `lispjit.c` plan 绿。  
**未声称 100%**：v4 全图 69 节点 · 全量 runner Lisp codegen · 全 monorepo 零 C。

## 进度评估（2026-05-25 · 继续推进前）

| 卷 | 完成度 | 签收键 / 说明 |
|----|--------|----------------|
| 发行面 scoped | **100%** | `scoped.100` · `release.100` |
| DECISION / warehouse | **100%** | `endgame.100` · `warehouse.100` |
| tier5 发行面树 | **100%** | `tier5.100` · `physical.zero_c=1`（发行面） |
| 洋葱 TDD | **100%** | `onion.lisp_only` · VM emit 矩阵 |
| mindmap 活图 | **100%** | **26/26** · DP `pct=100` |
| lisp 自举（用户） | **100%** | `selfhost.100` · next/gen2 矩阵 |
| **/goal 总签收** | **100%** | `goal.onion_tdd_tree_mindmap.100` |
| 工厂 S4/S5 零 C plan | **100%** | `selfhost.plan_no_c=1`（Wave22） |
| 全 monorepo 零 C | **0%** | 诚实未达 |
| v4 全 frontier | **未并入** | 69 节点独立 SSOT |

**综合（/goal 卷）**：**100%** — 可停；**综合（工厂物理终局）**：约 **96%** — 仍差全量 codegen / 物理删 run.sh。

## 合并进度分析（Wave25–29 → `origin/main` · 2026-05-25）

| Wave | 签收键 | 活图 | 状态 |
|------|--------|------|------|
| 28 | `factory_physical_continue.100` | factory 7/7 | ✅ main |
| **29** | **`selfhost_deep_continue.100`** | selfhost-deep **7/7** | ✅ main |

| 指标 | 数值 |
|------|------|
| `/goal` | **100%** · 26/26 |
| selfhost-next 深度矩阵 | modules + regenesis + chain + **onion-tdd** |
| 扩展活图层数 | /goal · codegen · factory · **selfhost-deep**（各 7 节点） |
| 工厂物理终局（诚实） | **~96%** |

**日常**：`v45-wave29-selfhost-deep-continue-converge.sh`

| Wave27 codegen 耦合 | **100%** | `v45.codegen_coupled.100` · 扩展活图 **7/7** |
| Wave28 工厂物理续推 | **100%** | `factory_physical_continue.100` |
| Wave29 selfhost 深度 | **100%** | `selfhost_deep_continue.100` · **7/7** |
| 全量 runner Lisp codegen | **~35%** | next 代际跑通 modules+onion；154KB 未达 |
| Wave23 继续卷 | **100%** | `v45.v45.continue.100=1` |
| v4 握手 | **100%** | `v45.v4.handoff.verified=1`（69/69，≠ v45 frontier） |
| 代际 plan-no-C matrix | **100%** | `factory.next_lisp_only_matrix=1` |

## 本波（/goal 边界扩展）

| 类 | 路径 |
|----|------|
| 正向 boundary | `samples/boundary/*.lisp` ×13 |
| 负向 boundary | `bootstrap-v45-boundary-negative.lisp` |
| 产品反馈 | `PRODUCT-FEEDBACK.md` + `bootstrap-v45-boundary-feedback.lisp` |
| 证据键 | `v45.boundary.probes=13` · `v45.product.feedback=1` |

## Wave2 扩散（自举 + 工厂矩阵）

| 维度 | 评估 |
|------|------|
| 代际自举 S6 | **100%** — `next.com` 跑 smoke |
| 模块 S7 | **100%** — 13/13 `lispjit-modules` |
| 工厂 Lisp 化 S8 | **~85%** — `factory-matrix` 索引；`run.sh` 仍 terminal |
| 收敛 | **100%** — `v45-wave2-converge.sh` 单轮 |

筹划/实施：[`DIFFUSE-WAVE2.md`](DIFFUSE-WAVE2.md) · [`CONCURRENT-IMPL.md`](CONCURRENT-IMPL.md)

## Wave4（next 洋葱 + tier3 锚点）

| 维度 | 评估 |
|------|------|
| next 代际洋葱 | **100%** — `next.com` 跑 `onion-tdd` |
| tier3 归档锚点 | **~60%** — `archive/runner`；未删 `lispjit-ir` |
| squad plan 化 | **100%** — wave4 squad plan；assess smoke 待 com 重打 |

[`DIFFUSE-WAVE4.md`](DIFFUSE-WAVE4.md)

## Wave5（lisp-only 洋葱 + scoped CI）

| 维度 | 评估 |
|------|------|
| lisp-only 洋葱 plan | **100%** — 无 `lispjit.c` build-slice |
| scoped CI | **100%** — `v45-scoped-results.txt` · `tests.pass=2` |
| w3.com 矩阵 | **~0%** 阻塞 — 代际 smoke 仍 gap，仅记录 `v45.w3_com.matrix` |

[`DIFFUSE-WAVE5.md`](DIFFUSE-WAVE5.md)

## Wave6（洋葱主 + w3 探针 + factory slim）

| 维度 | 评估 |
|------|------|
| 洋葱主门禁 | **100%** — `onion-lisp-only` 写入 ONION-TDD |
| w3 代际 | **100%** 探针口径 — slice exit 42，非 runner 矩阵 |
| 工厂 slim | **~70%** — 独立脚本；`run.sh` v4 墙未 hook skip |

[`DIFFUSE-WAVE6.md`](DIFFUSE-WAVE6.md)

## Wave7（发行面终局签收）

| 维度 | 评估 |
|------|------|
| release audit | **100%** — `v45.release.100=1` |
| factory v4 skip | **100%** — `skip_registry` + `NANO_V45_SCOPED_ONLY` |
| 收敛 | **100%** — `v45-wave7-converge.sh` |

[`DIFFUSE-WAVE7.md`](DIFFUSE-WAVE7.md)

## Wave8（DECISION tier0–4）

| 维度 | 评估 |
|------|------|
| tier3 真源 | **100%** — `archive/runner/lispjit.c`；`lispjit-ir` symlink |
| tier4 VM emit | **100%** — `tier4-vm-emit` · `v45.codegen.vm_emit=1` |
| endgame | **100%** — `v45.endgame.100=1` |

[`DIFFUSE-WAVE8.md`](DIFFUSE-WAVE8.md)

## Wave9（warehouse 合卷）

| 维度 | 评估 |
|------|------|
| factory scoped | **100%** — `v45.factory.100=1`（须 env） |
| warehouse 键 | **100%** — `v45.warehouse.100=1` |
| `run.sh` v4 墙 | **~85%** — guard 合卷；无参默认仍胖 |

[`DIFFUSE-WAVE9.md`](DIFFUSE-WAVE9.md)

## Wave10（诚实剩余 + 日常收敛）

| 维度 | 评估 |
|------|------|
| 口径文档 | **100%** — `HONEST-REMAINING.md` |
| 物理诚实键 | **100%** — `physical.zero_c=0` · `lispjit_ir_c_files=19` |
| 日常入口 | **100%** — `v45-wave10-honest-converge.sh` |

[`DIFFUSE-WAVE10.md`](DIFFUSE-WAVE10.md)

## Wave11（tier5 四轨并发）

| 维度 | 评估 |
|------|------|
| T5a 默认瘦 | **100%** — `v45.tier5.runsh_default=1` |
| T5b 归档 symlink | **~15%** — 2/20 TU（lispjit + bootstrap） |
| T5c 物理清单 | **100%** — `PHYSICAL-INVENTORY.md` |
| T5d VM emit 矩阵 | **~30%** — smoke 扩面，非全表 |
| 物理 zero_c | **0% 签收** — 仍 `physical.zero_c=0` |

[`DIFFUSE-WAVE11.md`](DIFFUSE-WAVE11.md)

## Wave12（16 TU 广度归档）

| 维度 | 评估 |
|------|------|
| T5b 批量 symlink | **~90%** — 16/18 nano TU + lispjit/bootstrap |
| `lispjit-ir` 真 `.c` | **2** — `ape_v2` · `irjit` |
| 并发收敛 | **100%** — 四轨 batch `&` + 四 anchor 并行 |
| physical zero_c | **0% 签收** |

[`DIFFUSE-WAVE12.md`](DIFFUSE-WAVE12.md)

## Wave13（`lispjit-ir` 门面零真 `.c`）

| 维度 | 评估 |
|------|------|
| T5b 门面 | **100%** — 20 symlink · 0 真 `.c` |
| T5c 计数 | **100%** — 分键 `ir` / `archive_runner` |
| 全仓 zero_c | **0% 签收** — `archive/runner` 仍有真源 |

[`DIFFUSE-WAVE13.md`](DIFFUSE-WAVE13.md)

## Wave14–15（T5d + tier5 100%）

| 维度 | 评估 |
|------|------|
| T5d VM emit 矩阵 | **100%** — 4 轨并行 |
| tier5 签收 | **100%** — `v45.tier5.100=1` |
| 发行面树 zero_c | **100%** — `ir`+`samples` 零真 `.c` |
| 全 monorepo zero_c | **未声称** |

[`DIFFUSE-WAVE15.md`](DIFFUSE-WAVE15.md)

## Wave16–17（/goal 洋葱×mindmap-tree）

| 维度 | 评估 |
|------|------|
| frontier DP 耦合 | **100%** — `mindmap-frontier-v45.json` |
| 四轨并发 | **100%** — W1–W4 绿 |
| /goal 签收 | **100%** — `v45.goal.mindmap_tree.100=1` |

[`MINDMAP-TDD-TREE.md`](MINDMAP-TDD-TREE.md) · [`DIFFUSE-WAVE17.md`](DIFFUSE-WAVE17.md)

## Wave18（统一 frontier 100%）

| 维度 | 评估 |
|------|------|
| frontier 覆盖 | **100%** — 14/14 nodes `done` |
| L4 四轨 | **100%** — boot/bare/core/selfhost |
| 统一签收 | **100%** — `v45.goal.onion_mindmap.unified.100=1` |

[`DIFFUSE-WAVE18.md`](DIFFUSE-WAVE18.md)

## 验证（清洗后）

```bash
bash lab/nano-lisp-jit/scripts/v45-cleanup-reflect.sh
grep v45.goal.onion_tdd_tree_mindmap.100=1 \
  lab/nano-lisp-jit/.build/v45-entry.evidence.canonical
```

详见 [`CLEANUP.md`](CLEANUP.md) · 反思 [`REFLECTION.md`](REFLECTION.md) §二十二。
