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
