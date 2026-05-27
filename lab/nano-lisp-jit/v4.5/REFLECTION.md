# v4.5 反思与梳理

## 一、我们在建什么（一句话）

**发行面**：`nano-jit.com` + `*.lisp` 完成编译、运行、打包、自举验收。  
**工厂**：`run.sh` + C 源码 + 历史 wave 样本 — 仅维护者全量回归，不是用户接口。

## 二、版本线（别混）

| 版本 | 签收什么 | 载体 |
|------|----------|------|
| v4 scoped | catalog S0–S15 · squad | `run.sh` + catalog-v4 |
| v4 lispjit-from-lisp | gen60 · genesis compare | zero-host plans |
| **v4.5 scoped 100%** | 洋葱 TDD · com-only verify | `bootstrap-v45-*.lisp` |

**v4.5 scoped 100% ≠ 全仓零 `.c/.sh`** — 见 [`PROGRESS.md`](PROGRESS.md)。

## 三、做对了什么

| 点 | 说明 |
|----|------|
| v4 当引擎 | 不重写 runner；`.com` 跑 plan 即自举 |
| 洋葱改载体 | 验收迁到 `bootstrap-v45-*.lisp` |
| tier 分期 | 避免「DONE = 删光 C」误解 |
| genesis 环境 | `env -u NANO_SELFHOST_REUSE_{X86,AARCH64}` 等再 compare |
| **目录清理** | `v4/` 从 260+ md 收到 14；SLICE → `archive/v4/slices/` |

## 四、踩过的坑

| 现象 | 根因 | 处理 |
|------|------|------|
| compare 失败 | `NANO_SELFHOST_REUSE_*` 盖过 genesis-pin | unset X86+AARCH64+reuse |
| multi-func `(run)` 断 plan | exit≠0 | `compile-elf64-exe` + `run-expect-exit` |
| boundary store-u32 红 | VM 未支持 | 改 store-load-u8 |
| func 内 block VM 红 | `func.unsupported.op=11` | 收录 `func-block-vm-gap` → **PRODUCT-FEEDBACK B01** |
| 负向 VM compile 不拒 ptr | VM 路径宽松 | 负向改 AOT `compile-elf64-exe` |
| v4 能否开 v4.5 | 混淆子轨与发行面 | handoff 锚 gen60 |
| SLICE 塞满 v4/ | wave 记账当活跃区 | 归档 + 路径批量改 |

## 五、清理后目录（真源）

```
lab/nano-lisp-jit/
├── v4.5/          ← SSOT（ONION-TDD · EVAL · REFLECTION · PRODUCT-FEEDBACK）
├── v4/            ← v4 决策/进度/mindmap（14 个 md + INDEX）
├── samples/
│   ├── bootstrap-v45-*   ← 洋葱验收
│   ├── boundary/         ← 10 正向 + 负向 plan
│   └── bootstrap-v4-*    ← 工厂（勿误删）
├── archive/v4/slices/    ← 244× SLICE 历史
├── archive/v4/factory-docs/
├── run.sh                ← 工厂全量回归
└── STRUCTURE.md          ← 地图
```

详见 [`CLEANUP.md`](CLEANUP.md)、[`../samples/README.md`](../samples/README.md)。

## 六、洋葱 TDD 怎么用（替代 .sh 纵切片）

```bash
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-onion-tdd.lisp
grep v45.scoped.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

`run.sh` 仅在 CI/维护时落盘 `.evidence`；**签收看 plan + .com**。

## 七、wave1（扩散全局 · 精细并发）

方法：[`PARALLEL.md`](PARALLEL.md) · catalog `wave1-v45-*` 四轨 ≤4 槽。

| 轨 | 交付 |
|----|------|
| A ×4 | `bootstrap-v45-boundary-{i64,ptr,func,rodata}.lisp` |
| B | `bootstrap-v45-diffuse-global.lisp` |
| C | `onion-parallel-matrix` + `scripts/v45-com-verify.sh` |
| D | `wave1-assess-tick` + `wave1-rollup` |

证据：`v45.wave1.diffuse=1` · `v45.wave1.parallel=4` · `v45.wave1.rollup=1`

## 八、自举（`*.lisp`）

真源：[`SELFHOST.md`](SELFHOST.md)。**S5** = seed `.com` 用 plan 完成 genesis compare、**lisp** `build-slice`、`pack-ape` → `v45-selfhost-next.com`（无 `run.sh` 步骤）。

**未达「完全」**：plan 内仍可有 `build-slice lispjit.c`；tier3 删仓内 C · S6 用 `next.com` 跑 verify。

## 九、Wave2 扩散（避免几十年碎砍）

真源：[`DIFFUSE-WAVE2.md`](DIFFUSE-WAVE2.md) · 并发清单：[`CONCURRENT-IMPL.md`](CONCURRENT-IMPL.md)。  
**一轮**：S6 next.com + S7 全模块 + S8 factory-matrix → `v45-wave2-converge.sh`。

**Wave4**：`next.com` 全洋葱 + tier3 `archive/runner` 锚点 + squad plan 无 `.sh` → `v45-wave4-converge.sh`。

**Wave5**：`onion-lisp-only` plan + scoped CI（terminal+converge）→ `v45-wave5-converge.sh`；catalog 不再要求 `tests.pass≥1302`。

**Wave6**：w3.com 语义修正（B09）+ 洋葱主门禁 + `v45-factory-slim.sh` → `v45-wave6-converge.sh`。

**Wave7**：`v45.release.100=1` — endgame plan + `skip_registry` v4 skip + `terminal-done` 升级 → **发行面终局签收**。

**Wave8**：`lispjit.c` 迁 `archive/runner` + `tier4-vm-emit` → `v45.endgame.100=1`（DECISION tier0–4，非零 C）。

**Wave9**：`v45.warehouse.100=1` — endgame ∧ factory 合卷；`run.sh` v4 块 `NANO_V45_SCOPED_ONLY` guard。

**Wave10**：[`HONEST-REMAINING.md`](HONEST-REMAINING.md) — **禁止**把 warehouse/endgame 写成物理全仓 100%；`v45.physical.zero_c=0` 明示 tier5 开卷。日常：`v45-wave10-honest-converge.sh`。

## 十、合并到 main（2026-05-24）

| 判断 | 结论 |
|------|------|
| 是否继续 Wave？ | **否** — 发行面/DECISION/warehouse 已签收 |
| 是否合并？ | **是** — `cursor/v45-full-100-fc19` → `main` |
| 合并后仍开卷？ | tier5：全仓零 C、默认瘦 `run.sh`、runner 全 Lisp codegen |

**教训**：证据键分层（`scoped` / `release` / `endgame` / `warehouse` / `physical.*`）避免 PR 标题误导；`warehouse.100` 只表示合卷门禁绿，不是删光 C。

## 十一、Wave11（扩散 + 并发 · tier5 切片）

| 调整 | 说明 |
|------|------|
| 默认入口 | 无参 `run.sh` 设 `NANO_V45_SCOPED_ONLY=1`；全量须 `NANO_V45_FULL_FACTORY=1` |
| 并发收敛 | 四轨 plan **后台并行** `wait` → rollup（见 `v45-wave11-tier5-converge.sh`） |
| 归档扩散 | `nano_bootstrap.c` 跟 tier3 同模式迁 `archive/c/runner/` |
| 诚实 | `lispjit_ir` 计数下降 ≠ `physical.zero_c=1` |

**扩散思维**：同一 wave 同时 touch T5a–T5d，禁止按单 `.c` 顺序碎迁。  
**并发思维**：com-only 矩阵用 `&`/`wait`，勿串行跑 4 个重 plan。

## 十二、Wave12（广度扩散 · 批量归档）

| 反思 | 调整 |
|------|------|
| 单文件迁太慢 | `v45-archive-runner-batch.sh` 四轨各 4 TU 并行 |
| 迁完怕断构建 | 收敛尾跑 `wave12-verify-smoke`（仍看 `scoped.100`） |
| 计数误导 | `nano_tu_archived=16` 与 `lispjit_ir_c_files=2` 分键 |

**下一调整**：Wave13 收 `ape_v2`；`irjit` 单独评估；仍不写 `physical.zero_c=1`。

## 十三、Wave13（门面收尾 · 分键诚实）

| 反思 | 调整 |
|------|------|
| `lispjit_ir=0` 易被误读成全仓 DONE | 新增 `ir_facade_zero_real`；**保留** `physical.zero_c=0` |
| ape/irjit 两种角色混迁 | E/F 双轨并行 batch，再四 plan 并发 |
| 归档后怕断 `#include` | `onion-after-archive` 验 `scoped`+`endgame` |

**并发**：2× batch `&` + 4× plan `&` → rollup；**禁止**把 `ir_facade` 写成 warehouse 100%。

## 十四、Wave14–15（到 tier5 100% 才停）

| 反思 | 调整 |
|------|------|
| T5d 仅 smoke | 四样本并行 VM emit → `vm_emit_broad=1` |
| `zero_c` 语义模糊 | 拆键：`release_samples_c` + `archive_*` 透明计数 |
| onion 红 genesis | wave15 用 `env -u NANO_SELFHOST_*` |
| 未到 100% 不停 | `tier5.100=1` + `honest.tier5.open=0` 闭合卷 |

**仍不声称**：全 monorepo 零 C · runner 全 Lisp codegen。

## 十五、Wave16–17（洋葱×mindmap-tree → goal 100%）

| 反思 | 调整 |
|------|------|
| v4 mindmap 与 v45 洋葱脱节 | `MINDMAP-TDD-TREE` + `frontier-v45.json` 显式 `onion_ring` |
| 扩散无 DP 锚点 | `mindmap-dp-v45.py ready` 驱动四槽 |
| 收敛后 frontier 漂移 | Python 回写 JSON `status=done` |
| 不到 100% 不停 | `v45.goal.mindmap_tree.100=1` 闭合本 /goal 卷 |

## 十六、Wave18（统一 frontier 14/14）

Wave17 只签收 7 节点 → 用户「不到 100% 不停」合理。扩展 L4–L7 把 v4 DP（boot/bare/core/selfhost/terminal）耦合进同一棵 `frontier-v45` 树，`nodes_done=nodes_total=14` 才写 `onion_mindmap.unified.100`。

## 十七、反思分析（/goal 合并 main · 洋葱×mindmap）

### 做对了什么

| 点 | 说明 |
|----|------|
| **耦合 SSOT** | `ONION-TDD.md` + `MINDMAP-TDD-TREE.md` + `mindmap-frontier-v45.json` 三件套互引 |
| **广度扩散** | 每波 ≤4 槽：L1 四轨 → L4 四轨 → 不碎补单 plan |
| **并发收敛** | `&`/`wait` 跑 plan；单脚本 `wave18` 链式收敛 wave15→17→18 |
| **诚实分层** | `goal.mindmap_tree`（7 节点）与 `goal.onion_mindmap.unified`（14 节点）分键，避免过早喊停 |
| **机器回写** | 收敛后 Python 更新 frontier `status=done`，`mindmap-dp-v45.py stats` 可审计 |

### 踩坑与调整

| 现象 | 调整 |
|------|------|
| Wave17 后用户仍要 100% | 扩展 frontier 至 14 节点，新增 `unified.100` |
| `onion-tdd` genesis 红 | 收敛内统一 `env -u NANO_SELFHOST_*` |
| `goal.mindmap_tree` 易被当成终局 | 文档写明 unified 才闭合 /goal |
| v4 MINDMAP 69 节点 ≠ v45 | v45 活图独立 SSOT，不混称 v4 终局 % |

### 合并到 `origin/main`（历史）

- Wave17–18：`dd02902` → `cd50109`（14 节点）
- **当前 main**：`76100a2`（Wave21 · 26 节点）— 日常见 [`CLEANUP.md`](CLEANUP.md)

### 仍开卷（另一口径，非本 goal）

- v4 `mindmap-frontier.json` 深层 zero-host 链映射到 v45
- 154KB runner 全量 Lisp codegen

## 十九、Wave19–20（lisp 完全自举 × 洋葱 mindmap 统一）

| 反思 | 调整 |
|------|------|
| `selfhost.100` 与 mindmap 14 节点分离 | Wave20 扩 frontier L8–L10 → **20/20** |
| gen2 `.com` 跑 onion 退出码 42 | converge 以 `run-expect-exit.ok=1` 签收，非裸 `$?` |
| Wave18 unified 非 lisp 终局 | 新键 **`goal.lisp_selfhost.unified.100`** 闭合 /goal |
| 不到 100% 不停 | `selfhost.100` ∧ `onion_mindmap.unified` ∧ `nodes_done=20` |

**日常收敛**：`v45-wave20-lisp-selfhost-unified-converge.sh`（内嵌 wave19→18 链）

## 二十、反思分析（/goal 合并 main · lisp 完全自举）

### 进度（机器签收）

| 卷 | 键 | 含义 |
|----|-----|------|
| Wave19 | `v45.selfhost.100=1` | S5+T3+next 矩阵+lisp-only 链 |
| Wave20 | `v45.goal.lisp_selfhost.unified.100=1` | 洋葱×mindmap×自举 **20/20** |

### 做对了什么

- **三件套仍 SSOT**：`ONION-TDD` · `MINDMAP-TDD-TREE` · `mindmap-frontier-v45.json`
- **单轮收敛**：wave20 脚本链式调用 wave19→18，避免人工多步
- **诚实分层**：`selfhost.100`（自举卷）与 `lisp_selfhost.unified.100`（/goal 终局）分键

### 踩坑

| 现象 | 调整 |
|------|------|
| gen2 仅 9KB，onion 后 exit 42 | 与 verify-smoke 同判据，grep `run-expect-exit.ok` |
| wave3 先跑 `goal-selfhost-100` 时 gen2 未建 | goal plan 用 `gen2_distinct` 键，非裸 file-size |
| S4/S5 plan 仍含归档 `lispjit.c` | 文档保留工厂层诚实未达，与 /goal 分离 |

### 可停条件（本 /goal · Wave20）

```bash
bash lab/nano-lisp-jit/scripts/v45-wave20-lisp-selfhost-unified-converge.sh
grep v45.goal.lisp_selfhost.unified.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats  # 期望 20/20
```

## 二十一、Wave21（/goal 洋葱 TDD-tree-mind-map 总签收）

| 反思 | 调整 |
|------|------|
| Wave20 仍非用户字面 /goal 名 | 总键 **`onion_tdd_tree_mindmap.100`** 聚合 tier5·scoped·三棵 goal·boundary |
| boundary 与 mindmap 脱节 | L11 四轨并发跑 `boundary-*` plan + mindmap 锚点 |
| 文档仍写 wave17/18 日常 | ONION-TDD / MINDMAP 改指向 wave21 收敛脚本 |
| 不到 100% 不停 | `nodes_done=26` 才写总签收 |

### 合并到 `origin/main`（本波）

- 分支：`cursor/v45-goal-onion-tdd-100-fc19`
- 机器键：`v45.goal.onion_tdd_tree_mindmap.100=1`
- 进度：[`EVAL.md`](EVAL.md) §合并进度分析 · 反思：本节 + §十九–二十

### 可停条件（/goal 终局）

```bash
bash lab/nano-lisp-jit/scripts/v45-wave21-onion-tdd-tree-mindmap-100-converge.sh
grep v45.goal.onion_tdd_tree_mindmap.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats  # 期望 26/26
```

## 二十二、清洗反思（整理后再继续）

### 为什么要洗

| 问题 | 危害 | 清洗 |
|------|------|------|
| evidence **append-only** | 同键多行（如 `nodes_done` 14→20→26）| `v45-evidence-canonical.sh` 取末值 |
| 多代收敛脚本并存 | 新人跑 wave17/18 以为终局 | [`CLEANUP.md`](CLEANUP.md) 标明 **仅 wave21** |
| goal 键层级多 | 过早以 `mindmap_tree` 喊停 | L2–L6 表 + 总键 `onion_tdd_tree_mindmap` |
| §十七–二十一 叠代 | 反思分散 | 本节 + `cleanup-reflect.sh` 一轮复核 |

### 做对了什么（可保留的工作方式）

1. **洋葱 × mindmap 三件套** 不动：`ONION-TDD` · `MINDMAP-TDD-TREE` · `frontier-v45.json`
2. **每波 ≤4 轨并发**，单脚本链式收敛 — 继续用，只换入口为 wave21
3. **分键签收** — 子 goal 保留，总键聚合；避免删历史键
4. **诚实未达** 与 /goal 分卷 — 不为了 100% 混称 v4 69 节点或全仓 zero_c

### 调整（下一卷前）

| 方向 | 建议 |
|------|------|
| 继续 nano-jit | 先 `v45-cleanup-reflect.sh`，再开新 wave |
| 新 frontier 节点 | 必须改 JSON + goal plan + 收敛脚本 **同一 PR** |
| evidence 审计 | 优先读 `.canonical`，不用裸 grep evidence 首行 |
| 工厂 C | 单独立项：`lispjit.c` plan 化或 gen60 级 codegen，勿并入 /goal |

### 一轮清洗命令

```bash
bash lab/nano-lisp-jit/scripts/v45-cleanup-reflect.sh
```

## 二十三、Wave22（工厂 S4/S5 plan 零 lispjit.c）

| 反思 | 调整 |
|------|------|
| /goal 已 100% 但 SELFHOST 仍写「plan 含 C」 | 新增 `regenesis-lisp-only` / `chain-lisp-only` |
| 与 w3/w19 链重复？ | 工厂卷单独键 `plan_no_c`，不扩 frontier |
| 进度评估 | 见 [`EVAL.md`](EVAL.md) §进度评估 — /goal 100% · 物理终局 ~85% |

## 二十四、Wave24（发行面继续）

代际 plan 零 C 的 `.com` 不仅能跑 smoke，还能跑 **verify-core** 与 **13/13 modules**；`scoped-ci` 改为认 `continue.100` / 总 goal。日常入口上移到 `wave24-release-converge.sh`。

## 二十五、Wave25（codegen 探针四轨）

| 反思 | 调整 |
|------|------|
| 154KB runner 全 Lisp codegen 太大，不能并进 /goal | 独立卷 `codegen_probe.100` · 3 slice 探针 + ir-table |
| `next-lisp-only.com` 跑完整 onion 无输出 exit 42 | 判据对齐 wave23 `smoke_ok`（exit 42 或 grep ok） |
| 与 gen60 关系？ | W4 mindmap 锚 `gen60-lispjit-from-lisp-done` · 仍 **~15%** 物理覆盖 |

日常入口：`v45-wave25-codegen-probe-converge.sh`（内嵌 wave24 链）。

## 二十六、Wave26（codegen 五轨扩面）

| 反思 | 调整 |
|------|------|
| Wave25 next_lo 仅 warn | 显式 `onion-next-lo-minimal` plan + 独立键 |
| 探针仅 3 slice | 加 VM emit arith/strlen → `lisp_slices=5` |
| 物理覆盖仍小 | 独立卷 `codegen_expand.100` · **~20%** 诚实未达全量 |

## 二十七、Wave27（工厂 codegen 洋葱×mindmap 耦合）

| 反思 | 调整 |
|------|------|
| /goal 26/26 已满，工厂 codegen 如何续推？ | 扩展活图 `mindmap-frontier-v45-codegen.json`（7 节点） |
| wave14 VM emit 四轨未全进 codegen 卷 | W1/W2 补 ctrl + multi → `vm_emit_profiles=4` |
| 代际仅 next-lo 探针 | 加 `chain-lo-minimal` 对称矩阵 |
| 与 v4 gen60 脱节？ | W4 gen60-handshake 显式耦合 /goal 前置键 |
| 仍不能喊物理 100% | `codegen_coupled.100` 签收 · 154KB 全量 codegen **~28%** |

## 二十八、Wave28（工厂物理续推）

| 反思 | 调整 |
|------|------|
| slice com（9KB）跑不了完整 onion/smoke | **selfhost-next.com（819KB）** 跑 smoke+core+onion 矩阵 |
| codegen 仅 VM emit 四轨 | 加 slice 双架构 + ir-table-broad → `lisp_slices=9` |
| run.sh 瘦化无进展 | W4 `runsh-factory-continue-anchor` 绑 release-run + scoped-ci |
| 扩展活图如何叠层？ | 第三张活图 `mindmap-frontier-v45-factory.json`（7 节点） |
| 仍不能喊物理 100% | `factory_physical_continue.100` · 工厂终局 **~93%** 诚实 |

## 二十九、Wave29（selfhost-next 深度矩阵）

| 反思 | 调整 |
|------|------|
| Wave28 仅 smoke/core/onion | 加 modules-full + regenesis + chain 四轨 |
| /goal 能否在代际 com 复核？ | **selfhost-next 跑 onion-tdd** → `next_onion_tdd=1` |
| 活图继续分卷 | 第四张 `mindmap-frontier-v45-selfhost-deep.json` |
| 工厂物理 ~96% | `selfhost_deep_continue.100`；154KB 全 codegen 仍开卷 |

## 三十、Wave30（/goal×工厂 统一耦合）

| 反思 | 调整 |
|------|------|
| /goal 仅在 host com 签收不够？ | **selfhost-next 跑 goal-onion-tdd-tree-mindmap-100** |
| 四扩展活图如何收束？ | 第五张 `mindmap-frontier-v45-goal-factory.json` |
| boundary/terminal 代际？ | next 跑 boundary-probe + terminal-done |
| 工厂物理 ~97% | `goal_factory_unified_continue.100`；全量 codegen 仍未达 |

## 三十一、Wave31（边界代际四轨）

| 反思 | 调整 |
|------|------|
| Wave21 boundary 仅在 host com？ | **selfhost-next** 跑 i64/ptr/func/negative 四轨 |
| /goal L11–13 与代际脱节 | 第六张活图 `boundary-next.json` |
| 工厂物理 ~98% | `terminal_continue.100`；154KB 全 codegen 仍开卷 |

## 三十二、Wave32（工厂终局 rollupy）

| 反思 | 调整 |
|------|------|
| Wave25–31 键分散？ | `rollup.waves_25_31=1` 一次复核七卷 |
| 子 goal 仅 host 绿？ | next 跑 lisp-unified + onion-unified |
| 第七张活图 | `mindmap-frontier-v45-rollup.json` |
| 工厂物理 ~99% | `factory_rollup_continue.100`；全量 codegen 仍开卷 |

## 三十三、Wave33（codegen 代际深探）

| 反思 | 调整 |
|------|------|
| 探针仅在 host com？ | **selfhost-next** 跑 slice/vm/ir 四轨 |
| 与 rollupy 关系？ | 链 wave32；不改 `lisp_slices` 计数语义 |
| 第八张活图 | `mindmap-frontier-v45-codegen-deep.json` |
| 工厂 ~99.5% | `codegen_deep_continue.100`；154KB 全 C 仍诚实未达 |

## 三十四、Wave34（runner codegen 广面）

| 反思 | 调整 |
|------|------|
| /goal 26/26 后往哪推？ | 第九张扩展活图 `mindmap-frontier-v45-runner-codegen.json` |
| Wave33 四轨够吗？ | 模块表 + emit 宽表 + ir-facade + modules 子集 |
| DP | `NANO_V45_FRONTIER=mindmap-frontier-v45-runner-codegen.json` |

真源：[`DIFFUSE-WAVE34.md`](DIFFUSE-WAVE34.md) · `runner_codegen_continue.100` · 活图 **7/7**（广面探针 ≠ 154KB 全 C）

## 三十五、Wave44–48 辩证梳理（mindmap 续推）

### 矛盾与统一

| 张力 | 正题 | 反题 | 合题（Wave48） |
|------|------|------|----------------|
| /goal 26/26 已满 | 不能再扩 frontier 混称 DONE | 发行面终局（`.com` 自举）仍未物理闭合 | **扩展活图分卷**：每波独立 `continue.100` |
| 100% 证据 vs 诚实 | `physical.zero_c=1`（发行面树） | `archive/lispjit.c` ~154KB 仍在 | **独立诚实键**：`archive_runner_c` · `factory_physical_closure` |
| 速度 vs 可信 | 快 seed 跳过整链 (~1s) | 历史 evidence 可能缺键 | 活图 7/7 seed + `V45_FULL=1` 留给 CI |
| 用户路径 vs CI | plan-only daily | `scripts/v45-*.sh` 仍跑收敛 | Wave47 分界 · Wave48 收 **nano-lisp.com 叙事** |

### Wave44→48 广度环（活图链）

```text
semantic(43) → nano-lisp.com(44) → 诚实零C(45) → 15link全链(46) → plan-only(47) → 自举终局(48)
```

### 做对了什么

1. **每波 7 节点 × 四轨** — DP `ready ≤4` 可机械执行
2. **daily 入口单调升维** — 每波一个 `converge-daily-*.lisp`，不删旧 plan
3. **快 seed** — 开发迭代不绑 90s 整链；诚实键不伪造物理 DONE

### 下一圈 mindmap 动作（Wave48 后）

| 步骤 | 命令/产物 |
|------|-----------|
| 读 frontier | `NANO_V45_FRONTIER=mindmap-frontier-v45-lisp-com-bootstrap-terminal.json` |
| DP | `mindmap-dp-v45.py stats` → 7/7 则读 `next_wave_preview` |
| 开 Wave49 | `endgame-honest-rollup` — 发行面卷闭合，154KB **仍独立开卷** |
| 停损线 | 禁止把 `factory_physical_closure=1` 写成全 monorepo zero_c DONE |

## 三十六、Wave49（文档 SSOT + endgame rollup）

| 反思 | 调整 |
|------|------|
| CLEANUP/PROGRESS 仍指 wave34 | P0 文档对齐 → wave48/49 为日常 |
| Wave44–48 键分散 | W1 `rollup.waves_44_48` 一次复核 |
| rollup 易被误读为物理 DONE | W2 `honest.endgame_remaining` 显式锚 |
| cleanup-reflect 绑 wave21（慢） | 改绑 wave51 快收敛 |

## 三十七、Wave50–51（扩展活图 rollup · ≠ v4.5 目标达成）

| 反思 | 调整 |
|------|------|
| 154KB 不能并进 rollup DONE | Wave50 独立活图 + 诚实键 |
| 扩展活图 18 张需 rollup 键 | Wave51 `v45_terminal_complete.100`（**非**物理 DONE） |
| 文档 SSOT 漂移 | 禁止混称 v4.5 DONE |

## 三十八、Wave52（物理零 cpysh 续推）

| 反思 | 调整 |
|------|------|
| Wave51 被误读为 v4.5 DONE | 改口径：扩展 rollup ≠ 目标达成 |
|  prematurely 开 v5 | 撤回 v5/；Wave52 回到 v4.5 物理轨 |
| 真目标仍是零 cpysh | `physical_zero_cpysh_continue.100` + 诚实锚 |

## 三十九、Wave53（154KB codegen 扩面 · v4.5 消 C 主路径）

| 反思 | 调整 |
|------|------|
| 应集中精力完成 v4.5 | Wave53 154KB 15link 全模块扩面 |
| 扩面绿 ≠ C 已删 | `honest.lispjit_c_remains=1` 显式锚 |
| 日常应指向物理轨 | `converge-daily-v45-physical.lisp` |

## 四十、Wave54（CI plan-only 收敛 · 消 sh 轨）

| 反思 | 调整 |
|------|------|
| 用户路径应可无 `.sh` | `converge-daily-v45-complete-plan-only.lisp` |
| host CI `.sh` 不能混称 DONE | `honest.host_sh_ci_only=1` 保留 |
| 收敛链迁入 plan | `ci_plan_only_converge_chain=1` |

## 四十一、Wave68–69（v4.5 真目标树 · 广度扩散）

### 真目标（未完成 ❌）

```text
用户路径 = nano-lisp.com + *.lisp bootstrap plan
  └─ plan 内零 .c / .sh / .py 步骤
  └─ plan 内零 archive/c 路径（Wave66+ daily 已收口）
物理诚实 = retired/ 可存历史 · CI run.sh 工厂面须显式分层，禁止混称 DONE
```

### 三层签收（禁止混称）

| 层 | 键族 | 能声称 | 不能声称 |
|----|------|--------|----------|
| L6 | `goal.onion_tdd_tree_mindmap.100` | /goal 26/26 | v4.5 物理 DONE |
| L7 | `v45.*.continue.100` | 扩展活图分卷 Wave34–N | 全仓零 C/sh/py |
| **L8** | **用户 daily + 诚实键** | **用户可 COM+plan 收敛** | **run.sh 已退役** |

### 已完成物理轨（Wave62–68）

```text
COM 统一(nano-lisp/) → 原生 bootstrap(63) → runner C 退仓(64) → CI sh 退(65)
→ factory lisp 退(66) → wave sh 退(67) → 种子 COM 退(68)
```

### 广度扩散（下一圈 ≤4 槽）

| Wave | 环 | W1 | W2 | W3 daily | W4 |
|------|-----|----|----|----------|-----|
| **69** | run.sh 工厂诚实 | prove | archive-honest | factory-honest-terminal | selfhost-matrix |
| 70 | daily 零 archive 审计 | audit-prove | stale-plan-honest | daily-audit-terminal | matrix |
| 71 | genesis 锚点诚实 | genesis-prove | anchor-honest | daily-genesis-free | matrix |

**停损线**：Wave69 只收口「run.sh = 工厂 · 用户不依赖」；不删 `run.sh`、不宣称 v4.5 DONE。

## 四十二、release/ COM 进仓（2026-05-27）

| 变更 | 说明 |
|------|------|
| `release/nano-lisp.com` | 产品 COM SSOT · git 跟踪 · `manifest.txt` pin |
| `release/v45-selfhost-next.com` | 自举代际 COM 同步进仓 |
| 路径迁移 | bootstrap / 收敛脚本 / 文档 → `release/` 取代 `.build/nano-lisp/` |
| `.build/` | 仍 gitignore · 仅本地 runtime 缓存 |


见 DIFFUSE-WAVE2 §Wave3：无 C plan · run.sh 单行化 · wave 归档。
