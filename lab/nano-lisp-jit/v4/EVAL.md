# v4 进度评估（合 main · wave27）

**评估日**：2026-05-23  
**分支**：`cursor/v4-wave15-parallel-108a` → **main**  
**catalog**：`v4-complete` scoped=100% terminal=100% ready=True  

## 六维终局（与 catalog 分离）

| 维度 | 终局目标 | wave27 后 | Δ（相对 wave25） |
|------|----------|-----------|------------------|
| Plan | bootstrap 无 `.c` | ✅ 常绿 | — |
| Runner | Lisp 执行 plan | C `nano-lisp-jit` | — |
| Codegen | Lisp IR 整表 → blob | 五 op 契约 + stub 整表读 | **+7%** → **~25%** |
| 编排 | Lisp `(squad-*)` | assess + 编排束样本 | **+6%** → **~18%** |
| 构建 | plan 内 build 图 | wave27 图 + results-min | **+8%** → **~30%** |
| 自举 | `.com` 下一代 | 未开卷 | — |

**整体终局**：约 **15–22%**（外圈满 ≠ 内圈替换完成）。

## 本波方法

```text
扩散：整表 + 3 plan 样本 + run.sh/catalog 一批登记
收敛：一次 run.sh → assess
洋葱：先 emit/契约 → runner → plan 文档
```

## 签收

- `bash lab/nano-lisp-jit/run.sh`
- `tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml assess`

**未声称**：零 `.c` / `.py` / `.sh`（见 [`DECISION.md`](DECISION.md) 终局未开卷）。

## wave28 增量（反思后）

| 维度 | Δ |
|------|---|
| Codegen | words-v2 ↔ lisp 表交叉验证 `verified=plan-lisp-v1-full` |
| 编排 | assess-evidence-chain + plan-contract-bundle |
| 构建 | build-graph-full（plan 多锚点） |

**终局整体**：仍约 **15–22%**；见 [`PROGRESS.md`](PROGRESS.md)。

## wave29（四轨扩散 · ≤4 并发）

| 维度 | wave29 后 | 说明 |
|------|-----------|------|
| Plan | ~92% | `v4-plan-manifest-v1.lisp` 契约清单 |
| Codegen | ~28% | add24 复用 verified 整表 |
| 编排 | ~22% | 四角色 squad 锚点 plan |
| 构建 | ~35% | plan 内 `tests.pass` + `build.pass` 双 results-min |
| 终局整体 | **15–22%** | catalog ready ≠ 零宿主 |

**并发上限**：四轨 = A/B/C/D 各一工作面（对应 squad 四角色规模），单波一次收敛。

## wave30（洋葱内圈 · 四轨）

| 维度 | wave30 后 | Δ |
|------|-----------|---|
| Plan | ~93% | `v4-onion-rings-v1.lisp` 圈索引 |
| 编排 | ~24% | supervise/signal/resume 链 |
| 构建 | ~36% | contract-regression 锚点 |
| 终局整体 | **15–22%** | 见 [`PROGRESS.md`](PROGRESS.md) |

**catalog**：`v4-complete` ready=True（合 main 时以本表为准）。

## wave31（POST-V4 证据矩阵 · 四轨）

| 维度 | wave31 后 | Δ |
|------|-----------|---|
| Plan | ~94% | `v4-wave-index-v1.lisp` 波次索引 |
| 编排 | ~25% | commander-tick + evidence-matrix |
| 构建 | ~37% | add26 + 双 results-min 锚点 |
| 终局整体 | **15–22%** | 见 [`PROGRESS.md`](PROGRESS.md) |

**并发**：四轨 A/B/C/D（≤4）；扩散→一次 `run.sh`→assess→洋葱。

**catalog**：`v4-complete` ready=True（合 main 时以本表为准）。

## wave32（host-reduce 洋葱 · 四轨）

| 维度 | wave32 后 | Δ |
|------|-----------|---|
| Plan | ~94% | wave-index + lisp-only 锚点 |
| Codegen | ~29% | add27 复用 verified 整表 |
| 编排 | ~26% | signal→resume→done 链 |
| 构建 | ~38% | host-reduce diffusion 锚点 |
| 终局整体 | **15–22%** | 见 [`PROGRESS.md`](PROGRESS.md) |

**并发**：四轨 A/B/C/D（≤4）；扩散→一次 `run.sh`→assess→洋葱。

## wave33（build-graph 洋葱 · 四轨）

| 维度 | wave33 后 | Δ |
|------|-----------|---|
| Plan | ~95% | build-graph 多锚点 + assess 链 |
| Codegen | ~30% | add28 复用 verified 整表 |
| 编排 | ~27% | assess-chain + host-reduce 锚点 |
| 构建 | ~39% | build-graph-tick + PARALLEL |
| 终局整体 | **15–22%** | 见 [`PROGRESS.md`](PROGRESS.md) |

**并发**：四轨 A/B/C/D（≤4）；扩散→一次 `run.sh`→assess→洋葱。

**catalog**：`v4-complete` ready=True（合 main 时以本表为准）。

## wave34（plan-contract 洋葱 · 四轨）

| 维度 | wave34 后 | Δ |
|------|-----------|---|
| Plan | ~96% | manifest + contract bundle 锚点 |
| Codegen | ~31% | add29 复用 verified 整表 |
| 编排 | ~28% | terminal-tick + DECISION 分界 |
| 构建 | ~40% | plan-contract diffusion |
| 终局整体 | **15–22%** | 见 [`PROGRESS.md`](PROGRESS.md) |

**并发**：四轨 A/B/C/D（≤4）；扩散→一次 `run.sh`→assess→洋葱。

**catalog**：`v4-complete` ready=True（合 main 时以本表为准）。

## wave35–37（批量 · 每波四轨 ≤4 并发）

| 维度 | wave37 后 | 说明 |
|------|-----------|------|
| Plan | ~97% | contract / orchestration / gen5 锚点族 |
| Codegen | ~33% | add30–32 整表 verified |
| 编排 | ~30% | orchestration-bundle + dispatch 链 |
| 构建 | ~42% | 三波 diffusion 锚点 |
| 终局整体 | **15–22%** | catalog ready ≠ 零宿主 |

**方法**：一波扩散 3×四轨 → **一次** `run.sh` → `assess` → 洋葱文档。

**catalog**：`v4-complete` ready=True。
## wave38–40（批量 · 每波四轨 ≤4 并发）

| 维度 | wave40 后 | 说明 |
|------|-----------|------|
| Plan | ~98% | aarch64 scout + IR 深度 + onion 收束 |
| Codegen | ~35% | add33–35 verified 整表 |
| 编排 | ~32% | slice10–11 + terminal 锚点 |
| 构建 | ~44% | 三波 diffusion |
| 终局整体 | **15–22%** | 真提速需 VM emit / runner 去 C |

**方法**：3×四轨扩散 → **一次** `run.sh` → `assess` → 合 main。

**catalog**：`v4-complete` ready=True。

## wave41–43（批量 · 洋葱 TDD · ≤4 并发/波）

| 维度 | wave43 后 | 说明 |
|------|-----------|------|
| Plan | ~98% | emit-manifest + squad-deep + mindmap 收束 |
| Codegen | ~36% | add36–38 verified 整表 |
| 编排 | ~33% | S3 链 + assess bundle |
| 构建 | ~45% | 三波 diffusion |
| 终局整体 | **15–22%** | catalog≠零宿主；emit 开卷才抬终局 |

**方法**：扩散（3×四轨 plan 族）→ **一次** `bash lab/nano-lisp-jit/run.sh` → `assess` → 洋葱文档（MINDMAP/SLICE）→ 合 **main** 带本表。

**catalog**：`v4-complete` scoped=100% terminal=100% ready=True。

## wave44–46（批量 · 洋葱 TDD · ≤4 并发/波）

| 维度 | wave46 后 | 说明 |
|------|-----------|------|
| Plan | ~98% | ir-words 链 + gen5 bridge + scoped 收束 |
| Codegen | ~37% | add39–41 verified 整表 |
| 编排 | ~34% | terminal + evidence-matrix 锚点 |
| 构建 | ~46% | 三波 diffusion |
| 终局整体 | **15–22%** | 见 [`DECISION.md`](DECISION.md) |

**方法**：3×四轨扩散 → 一次 `run.sh` → `assess` → 合 **main**（本表 + [`PROGRESS.md`](PROGRESS.md)）。

**catalog**：`v4-complete` ready=True。

## wave47–49（批量 · 洋葱 TDD · ≤4 并发/波）

| 维度 | wave49 后 | 说明 |
|------|-----------|------|
| Plan | ~98% | supervise + manifest + post-v4 收束 |
| Codegen | ~38% | add42–44 verified 整表 |
| 编排 | ~35% | commander + contract 锚点 |
| 构建 | ~47% | 三波 diffusion |
| 终局整体 | **15–22%** | catalog ready ≠ 零宿主 |

**方法**：扩散（3×四轨）→ `bash lab/nano-lisp-jit/run.sh` → `assess` → 洋葱（MINDMAP/SLICE）→ 合 **main** 带本表。

**catalog**：`v4-complete` scoped=100% terminal=100% ready=True。

## wave50–52（批量 · 洋葱 TDD · ≤4 并发/波）

| 维度 | wave52 后 | 说明 |
|------|-----------|------|
| Plan | ~98% | table-only + wave27/28 + mindmap 收束 |
| Codegen | ~39% | add45–47 verified 整表 |
| 编排 | ~36% | evidence-matrix + assess 链 |
| 构建 | ~48% | 三波 diffusion |
| 终局整体 | **15–22%** | 见 [`DECISION.md`](DECISION.md) |

**方法**：3×四轨扩散 → `run.sh` → `assess` → 合 **main**（本表 + [`PROGRESS.md`](PROGRESS.md)）。

**catalog**：`v4-complete` ready=True。

## 长程自主推进（catalog ≠ 终局 100%）

| 签收层 | 状态 | 自主策略 |
|--------|------|----------|
| catalog `v4-complete` | ready=True（scoped/terminal 满） | **不停止**；继续按波扩散 |
| 终局六维 | **15–22%** | 未达 100% 前每合 main 更新本表 |
| 下一硬目标 | Lisp VM emit / runner 去 C | 见 [`REFLECTION.md`](REFLECTION.md) |

**每波固定**：≤4 并发轨 → 一次 `run.sh` → `assess` → 洋葱文档 → 合 main。

## wave53–55（长程自主 · 批量）

| 维度 | wave55 后 | Δ |
|------|-----------|---|
| Plan | ~98% | slice12–14 + squad S4–S6 + 自主里程碑 |
| Codegen | ~40% | add48–50 verified |
| 编排 | ~37% | squad 深链 |
| 构建 | ~49% | 三波 diffusion |
| 终局整体 | **15–22%** | **继续自主，不以 catalog 100% 为停点** |

**catalog**：`v4-complete` ready=True。


## wave56–58（长程自主 · 续批）

| 维度 | wave58 后 | Δ |
|------|-----------|---|
| Codegen | ~41% | add51–53 |
| 编排 | ~38% | four-track + host-reduce  recap |
| 构建 | ~50% | 续三波 diffusion |
| 终局整体 | **15–22%** | 仍自主推进 |

**wave 索引**：至 **58**。

## wave59–61（长程自主 · 续）

| 维度 | wave61 后 | Δ |
|------|-----------|---|
| Codegen | ~42% | add54–56 |
| 编排 | ~39% | evidence + resume 深链 |
| 构建 | ~51% | 三波 diffusion |
| 终局整体 | **15–22%** | catalog ready；自主继续 |

**wave 索引**：至 **61**。

## wave62–64（长程自主 · 续批）

| 维度 | wave64 后 | Δ |
|------|-----------|---|
| Codegen | ~43% | add57–59 verified |
| 编排 | ~40% | runner + reflection + lisp-only 深链 |
| 构建 | ~52% | 三波 diffusion |
| 终局整体 | **15–22%** | catalog ready；自主继续 |

**wave 索引**：至 **64**。

**门禁**：`run.sh` exit 0；`tests.pass=471`；`build.pass=26`；`assess` ready=True。

## wave65–67（长程自主 · 续批）

| 维度 | wave67 后 | Δ |
|------|-----------|---|
| Codegen | ~44% | add60–62 verified |
| 编排 | ~41% | emit + squad commander + terminal 深链 |
| 构建 | ~53% | 三波 diffusion |
| 终局整体 | **15–22%** | catalog ready；**未到 100% 自主继续** |

**wave 索引**：至 **67**。

**方法**：≤4 轨扩散 → 一次 `run.sh` → `assess` → 洋葱文档 → 合 main（本表 + [`PROGRESS.md`](PROGRESS.md)）。

## wave68–73（长程自主 · 续批 ×2）

| 维度 | wave73 后 | Δ |
|------|-----------|---|
| Codegen | ~45% | add63–68 verified |
| 编排 | ~42% | ir-table + build-graph + squad/evidence 深链 |
| 构建 | ~54% | 六波 diffusion |
| 终局整体 | **15–22%** | catalog ready；**未到 100% 自主继续** |

**wave 索引**：至 **73**。

**方法**：≤4 轨/波 → 一次 `run.sh` → `assess` → 合 main；队列见 [`LONG-RUN-TODO.md`](LONG-RUN-TODO.md)。

**门禁**：`run.sh` exit 0；`tests.pass=494`；`build.pass=26`；`assess` ready=True。

## wave74–76（长程自主 · 洋葱 TDD · ≤4 并发/波）

| 维度 | wave76 后 | Δ |
|------|-----------|---|
| Plan | ~98% | runner / emit / mindmap 锚点族 |
| Codegen | ~46% | add69–71 verified 整表 |
| 编排 | ~43% | runner-scout + emit-deep 链 |
| 构建 | ~55% | 三波 diffusion |
| Runner | ~6% | wave74 lisp-runner-scout 样本 |
| 终局整体 | **15–22%** | catalog≠零宿主；VM emit 未开卷 |

**wave 索引**：至 **76**。

**方法**：≤4 轨/波 → 一次 `run.sh` → 洋葱（MINDMAP/SLICE）→ 合 main；`gen-v4-wave-batch.py 74 76`。

**门禁**：`tests.pass=507`；`build.pass=26`（main 归档后 catalog `build.pass≥119` 需 cosmocc，与波次样本 `26` 并存）。

## wave77–79（长程自主 · 洋葱 TDD · ≤4 并发/波）

| 维度 | wave79 后 | Δ |
|------|-----------|---|
| Plan | ~98% | commander-resume + build-graph + longrun 锚点 |
| Codegen | ~47% | add72–74 verified 整表 |
| 编排 | ~44% | squad commander/resume 深链 |
| 构建 | ~56% | 三波 diffusion |
| 终局整体 | **15–22%** | 自循环 TODO 状态机入账 |

**wave 索引**：至 **79**。

**方法**：`gen-v4-wave-batch.py 77 79`；`LONG-RUN-TODO.md` 自循环状态机。

**门禁**：`tests.pass=519`；`build.pass=26`。

## wave80–82（长程自主 · 洋葱 TDD · ≤4 并发/波）

| 维度 | wave82 后 | Δ |
|------|-----------|---|
| Plan | ~98% | ir-table / emit-manifest / four-track 锚点续链 |
| Codegen | ~48% | add75–77 verified 整表 |
| 编排 | ~45% | hostreduce + manifest + contract 交叉引用 |
| 构建 | ~57% | 三波 diffusion |
| 终局整体 | **15–22%** | catalog ready；Lisp VM emit 未开卷 |

**wave 索引**：至 **82**。

**方法**：`gen-v4-wave-batch.py 80 82`；ir-table / emit-manifest / four-track 三轨续批。

**门禁**：`tests.pass=532`；`build.pass=26`（native；cosmocc 缺失时 aarch64 slice 跳过）。

## wave83–85（长程自主 · 洋葱 TDD · ≤4 并发/波）

| 维度 | wave85 后 | Δ |
|------|-----------|---|
| Plan | ~98% | reflection / lisp-only / codegen 续链 |
| Runner | ~6% | terminal + resume 锚点补强 |
| Codegen | ~49% | add78–80 verified 整表 |
| 编排 | ~46% | reflection-resume + lisponly-terminal 交叉引用 |
| 构建 | ~58% | 三波 diffusion |
| 自举 | ~0% | 仍未开卷 Lisp VM emit |
| 终局整体 | **15–22%** | catalog ready；继续按长程自循环推进 |

**wave 索引**：至 **85**。

**方法**：`gen-v4-wave-batch.py 83 85`；reflection / resume / lisp-only / terminal / codegen / emit 六锚点三波续批。

**门禁**：`tests.pass=544`；`build.pass=27`（native）。

## wave86–88（长程自主 · 洋葱 TDD · ≤4 并发/波）

| 维度 | wave88 后 | Δ |
|------|-----------|---|
| Plan | ~98% | runner-plan + plan-contract 再锚定 |
| Runner | ~6% | runner tick 与 LISP-ONLY/DECISION 交叉引用 |
| Codegen | ~50% | add81–83 verified 整表 |
| 编排 | ~47% | assess + evidence-matrix 链补强 |
| 构建 | ~59% | 三波 diffusion + slice evidence |
| 自举 | ~0% | 仍未开卷 Lisp VM emit |
| 终局整体 | **15–22%** | catalog ready；下一批从 wave89 继续 |

**wave 索引**：至 **88**。

**方法**：`gen-v4-wave-batch.py 86 88`；runner/plan、assess/evidence、onion/mindmap 三波续批。

**门禁**：`tests.pass=556`；`build.pass=27`（native）。

## wave89–91（longrun apply · ≤4 轨/波）

| 维度 | wave91 后 | 说明 |
|------|-------------|------|
| Codegen | ~49% | add 续批 verified |
| 终局整体 | **15–22%** | deterministic apply |

**方法**：`v4-apply-batch.py 89 91` → `run.sh` gate。

## wave92–97（skill longrun · 2 批 × ≤4 轨/波）

| 维度 | wave97 后 | Δ |
|------|-----------|---|
| Plan | ~98% | longrun-skill + commander + mindmap 锚点 |
| Codegen | ~51% | add87–92 verified |
| 编排 | ~48% | squad-commander-chain |
| 构建 | ~60% | build-graph-recap |
| 终局整体 | **15–22%** | VM emit 未开卷 |

**wave 索引**：至 **97** · **tests.pass=592** · 指针 **98**

**方法**：`bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts loop --batches 2 --goal wave103`

## wave98–103（skill longrun · 2 批）

| 维度 | wave103 后 | Δ |
|------|------------|---|
| Plan | ~98% | post-v4 + orchestration 锚点 |
| Codegen | ~52% | add93–98 verified |
| 编排 | ~49% | squad orchestration-bundle |
| 构建 | ~61% | 六波 diffusion |
| 终局整体 | **15–22%** | 指针 **104** |

**门禁**：`tests.pass=616` · skill apply 全绿

## wave98–100（longrun apply · ≤4 轨/波）

| 维度 | wave100 后 | 说明 |
|------|-------------|------|
| Codegen | ~49% | add 续批 verified |
| 终局整体 | **15–22%** | skill apply |

**方法**：`bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts apply 98 100`

## wave101–103（longrun apply · ≤4 轨/波）

| 维度 | wave103 后 | 说明 |
|------|-------------|------|
| Codegen | ~49% | add 续批 verified |
| 终局整体 | **15–22%** | skill apply |

**方法**：`bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts apply 101 103`

## wave104–106（longrun apply · ≤4 轨/波）

| 维度 | wave106 后 | 说明 |
|------|-------------|------|
| Codegen | ~49% | add 续批 verified |
| 终局整体 | **15–22%** | skill apply |

**方法**：`bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts apply 104 106`

## wave107–109（longrun apply · ≤4 轨/波）

| 维度 | wave109 后 | 说明 |
|------|-------------|------|
| Codegen | ~49% | add 续批 verified |
| 终局整体 | **15–22%** | skill apply |

**方法**：`bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts apply 107 109`

## wave110–112（longrun apply · ≤4 轨/波）

| 维度 | wave112 后 | 说明 |
|------|-------------|------|
| Codegen | ~49% | add 续批 verified |
| 终局整体 | **15–22%** | skill apply |

**方法**：`bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts apply 110 112`

## wave104–112（turbo longrun · 3 批 1 gate）

| 维度 | wave112 后 | Δ | 说明 |
|------|-------------|---|------|
| Plan | ~98% | — | plan-lisp-v1-full 常绿 |
| Runner | ~7% | +1% | runner-scout/plan/bridge 续批 |
| Codegen | ~53% | +1% | emit/codegen 锚点续批 |
| 编排 | ~49% | — | — |
| 构建 | ~62% | +1% | add99–107 |
| 自举 | ~0% | — | 未开卷 |
| tests.pass | **652** | +36 | turbo `--gate-every 3` |
| 终局整体 | **15–22%** | — | 外圈证据 ≠ VM emit |

**方法**：`bun run … loop --batches 3 --gate-every 3 --goal wave112`

## wave113–115（longrun apply · ≤4 轨/波）

| 维度 | wave115 后 | 说明 |
|------|-------------|------|
| Codegen | ~49% | add 续批 verified |
| 终局整体 | **15–22%** | skill apply |

**方法**：`bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts apply 113 115`

## wave116–118（longrun apply · ≤4 轨/波）

| 维度 | wave118 后 | 说明 |
|------|-------------|------|
| Codegen | ~49% | add 续批 verified |
| 终局整体 | **15–22%** | skill apply |

**方法**：`bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts apply 116 118`

## wave119–121（longrun apply · ≤4 轨/波）

| 维度 | wave121 后 | 说明 |
|------|-------------|------|
| Codegen | ~49% | add 续批 verified |
| 终局整体 | **15–22%** | skill apply |

**方法**：`bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts apply 119 121`

## wave113–121（cc 下手 + turbo · 3 批 1 gate）

| 维度 | wave121 后 | Δ | 说明 |
|------|-------------|---|------|
| Plan | ~98% | — | plan-lisp-v1-full |
| Runner | ~8% | +1% | runner/emit/plan 续批 |
| Codegen | **~54%** | +1% | **cc**：`add.result` / `add.operands` / `emit.bytes` |
| 构建 | ~63% | +1% | add108–116 |
| tests.pass | **688** | +36 | turbo + cc C 层 |
| 终局整体 | **15–22%** | — | 可观测 ≠ VM emit |

**并行**：Composer 扩 WAVES + `cc-huoshan1-ds4pro` 改 `nano_bootstrap.c`/`nano_elf64.c` → skill `loop --gate-every 3`

## wave122–124（longrun apply · ≤4 轨/波）

| 维度 | wave124 后 | 说明 |
|------|-------------|------|
| Codegen | ~49% | add 续批 verified |
| 终局整体 | **15–22%** | skill apply |

**方法**：`bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts apply 122 124`

## wave125–127（longrun apply · ≤4 轨/波）

| 维度 | wave127 后 | 说明 |
|------|-------------|------|
| Codegen | ~49% | add 续批 verified |
| 终局整体 | **15–22%** | skill apply |

**方法**：`bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts apply 125 127`

## wave128–130（longrun apply · ≤4 轨/波）

| 维度 | wave130 后 | 说明 |
|------|-------------|------|
| Codegen | ~49% | add 续批 verified |
| 终局整体 | **15–22%** | skill apply |

**方法**：`bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts apply 128 130`

## wave122–130（Dev Agents Team + turbo · Critic grep）

| 维度 | wave130 后 | Δ | 说明 |
|------|-------------|---|------|
| Plan | ~98% | — | plan-lisp-v1-full |
| Codegen | **~55%** | +1% | **Critic**：`extra_grep` 验收 `add.result`/`operands` |
| 编排 | ~50% | +1% | wave130 `DEV-AGENTS-TEAM.md` milestone |
| tests.pass | **724** | +36 | Commander→Planner→Worker(skill)→Critic |
| 终局整体 | **15–22%** | — | 强模型控向 + 程序记忆 SSOT |

**工作流**：见 [`DEV-AGENTS-TEAM.md`](DEV-AGENTS-TEAM.md) — 不堆 agent 数，堆调度质量。

## wave131–133（longrun apply · ≤4 轨/波）

| 维度 | wave133 后 | 说明 |
|------|-------------|------|
| Codegen | ~49% | add 续批 verified |
| 终局整体 | **15–22%** | skill apply |

**方法**：`bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts apply 131 133`

## wave134–136（longrun apply · ≤4 轨/波）

| 维度 | wave136 后 | 说明 |
|------|-------------|------|
| Codegen | ~49% | add 续批 verified |
| 终局整体 | **15–22%** | skill apply |

**方法**：`bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts apply 134 136`

## wave137–139（longrun apply · ≤4 轨/波）

| 维度 | wave139 后 | 说明 |
|------|-------------|------|
| Codegen | ~49% | add 续批 verified |
| 终局整体 | **15–22%** | skill apply |

**方法**：`bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts apply 137 139`

## wave131–139（post-main · turbo）

| 维度 | wave139 后 | Δ | 说明 |
|------|-------------|---|------|
| Plan | ~98% | — | 已 ff **origin/main** |
| Codegen | ~55% | — | extra_grep 续批 |
| tests.pass | **760** | +36 | add126–134 |
| 终局整体 | **15–22%** | — | catalog≠终局 |

**合 main**：`cursor/v4-wave74-76-autonomous-fc19` → `main` @ bc3c1f0；本批在 `main` 上续推。

## wave140–142（longrun apply · ≤4 轨/波）

| 维度 | wave142 后 | 说明 |
|------|-------------|------|
| Codegen | ~49% | add 续批 verified |
| 终局整体 | **15–22%** | skill apply |

**方法**：`bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts apply 140 142`

## wave143–145（longrun apply · ≤4 轨/波）

| 维度 | wave145 后 | 说明 |
|------|-------------|------|
| Codegen | ~49% | add 续批 verified |
| 终局整体 | **15–22%** | skill apply |

**方法**：`bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts apply 143 145`

## wave146–148（longrun apply · ≤4 轨/波）

| 维度 | wave148 后 | 说明 |
|------|-------------|------|
| Codegen | ~49% | add 续批 verified |
| 终局整体 | **15–22%** | skill apply |

**方法**：`bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts apply 146 148`

## wave140–148（扩散+并发+洋葱 · turbo + cc）

| 维度 | wave148 后 | Δ | 说明 |
|------|-------------|---|------|
| Plan | ~98% | — | plan-lisp-v1-full |
| Runner | ~8% | — | runner/plan/lisp 轨 |
| Codegen | **~56%** | +1% | **cc**：stdout `add.bytes=20` + extra_grep |
| 编排 | ~51% | +1% | wave148 onion/mindmap tick |
| 构建 | ~66% | +1% | add135–143 |
| tests.pass | **796** | +36 | ≤4 并发：cc∥gen∥skill |
| 终局整体 | **15–22%** | — | catalog≠零宿主 |

**方法**：`cc-huoshan1-ds4pro` + `loop --batches 3 --gate-every 3 --goal wave148`

## wave149–165（洋葱先扩散后并发 · 17 波 1 gate）

| 维度 | wave165 后 | Δ | 说明 |
|------|-------------|---|------|
| Plan | ~98% | — | 一次 gen 扩散框架 |
| Codegen | **~57%** | +1% | 5×cc：elf64 v2-diffuse + `add.verified` |
| 编排 | ~52% | +1% | DIFFUSE-WORKFLOW 入账 |
| tests.pass | **864** | +68 | 17 波 × 4 轨 / 1× run.sh |
| 终局整体 | **15–22%** | — | **提速模型**验证 |

```bash
python3 lab/nano-lisp-jit/tools/gen-v4-wave-batch.py 149 165
bash lab/nano-lisp-jit/tools/v4-diffuse-then-cc.sh
export NANO_SLICE_COMPILER=native && bash lab/nano-lisp-jit/run.sh
```
