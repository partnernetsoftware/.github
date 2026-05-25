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
$COM run-bootstrap-plan lab/nano-lisp-jit/samples/bootstrap-v45-onion-tdd.lisp
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
| 归档扩散 | `nano_bootstrap.c` 跟 tier3 同模式迁 `archive/runner/` |
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

## 十五、Wave3（整表扩散，勿逐条）

见 DIFFUSE-WAVE2 §Wave3：无 C plan · run.sh 单行化 · wave 归档。
