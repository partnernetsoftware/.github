# v4 洋葱 TDD mindmap（并行思维 · 活图 · **全局 SSOT**）

**签收基线**：[`DECISION.md`](DECISION.md) · **`v4-complete`**（scoped S0–S15 + terminal native）。  
**本图**：post-v4 洋葱圈 **继续内卷**；**扩散 = 改这张图 + 并发填就绪节点**，不是盲目 `wave++`。

## 活图扩散循环（mindmap 即扩散面）

```text
    ┌─────────────────────────────────────────┐
    │  1. 读 MINDMAP + mindmap-frontier.json │  ← 全局 + DP 就绪集
    └──────────────────┬──────────────────────┘
                       ▼
    ┌─────────────────────────────────────────┐
    │  2. DP：选 layer 上 status=ready 节点   │  ≤4 个可并行（依赖已满足）
    └──────────────────┬──────────────────────┘
                       ▼
    ┌─────────────────────────────────────────┐
    │  3. 扩散骨架 + 并发细节                  │  gen-terminal-bfs / gen wave + cc×4
    └──────────────────┬──────────────────────┘
                       ▼
    ┌─────────────────────────────────────────┐
    │  4. 收敛：一次 run.sh + assess           │
    └──────────────────┬──────────────────────┘
                       ▼
    ┌─────────────────────────────────────────┐
    │  5. 回写：本文件 + PROGRESS + frontier   │  done → 解锁下一层 ready
    └──────────────────┬──────────────────────┘
                       └──────────► 未终局 100% 则回到 1
```

**DP 技巧**：把节点当成状态图，不是时间表——只挑 **deps 全 done** 的 `ready` 进线程池；`blocked` 等子节点签收后再变 `ready`。

```bash
python3 lab/nano-lisp-jit/tools/mindmap-dp.py ready   # 本轮可并发谁
python3 lab/nano-lisp-jit/tools/mindmap-dp.py next    # W1..W4 与验收句
```

机器可读前沿：[`mindmap-frontier.json`](mindmap-frontier.json) · 终局六轨：[`TERMINAL-BFS.md`](TERMINAL-BFS.md)。

## 终局六维（与 catalog 100% 分离）

| 维度 | 终局目标 | 当前 | 粗估 |
|------|----------|------|------|
| Plan | bootstrap 无 .c 源 | gate 常绿 | **~98%** |
| Runner | Lisp 执行 plan | C runner 锚点续批 | **~8%** |
| Codegen | Lisp IR 表 → blob | grep `add.bytes`/`add.result` | **~56%** |
| 编排 | Lisp `(squad-*)` | onion-milestone | **~51%** |
| 构建 | plan 内 build 图 | add143 + results-min | **~66%** |
| 自举 | `.com` 生成下一代 | 未开卷 | **~0%** |

**整体终局 ~15–22%**；**catalog `v4-complete` = 工程洋葱签收**（见 [`PROGRESS.md`](PROGRESS.md)）。


## 并行法则（每波）

**扩散 → 收敛 → 洋葱修正**（见 [`PARALLEL.md`](PARALLEL.md)）：先并发铺开整表/整图/整批门禁，再**一次** `run.sh`，最后由内圈向外修；禁止碎补式「一刀一 op」。

```text
轨 A · 契约/codegen  engineer-a  → ir-table/words 整份 + 样本族
轨 B · plan/编排      engineer-b  → bootstrap 图 + squad-* + v4/*.md
轨 R · 签收          reviewer    → 一次 run.sh → assess → sync-md
```

快路径：多轨扩散写完 → **一次** `bash lab/nano-lisp-jit/run.sh`（勿空转 `agent-team`）。见 [`skills/squad-parallel/`](../../skills/squad-parallel/)。

**终局 BFS**（对齐 loader/.com 主线，非 wave 计数）：[`TERMINAL-BFS.md`](TERMINAL-BFS.md) · `python3 tools/gen-terminal-bfs.py` → `v4-terminal-bfs-cc.sh`（≤4 路 cc）。

## 洋葱圈（由外向内 · TDD）

```text
圈 0 · 证据 / 门禁
  run.sh + catalog-v4.yaml + assess
  ✅ v4-complete（scoped + terminal smoke）

圈 1 · Plan（无 .c 引用）
  bootstrap-v4-*.lisp + v4-ir-words-v1.txt
  ✅ S0–S16 样本递增

圈 2 · Runner（host C）
  nano_bootstrap.c + nano-lisp-jit
  ✅ 执行 plan；⏳ Lisp (squad-*) 替代 Python

圈 3 · Codegen stub（表驱动 emit）
  nano_elf64.c：v1 entry → v2 fixed → v3 movz → v4 table-only → v5 plan-words 契约
  wave225–252 · 洋葱快进 · diffuse+4cc
  ✅ S10–S16 日志回归；❌ VM/AOT 真发射

圈 4 · 编排终局
  tools/squad/*.py → bootstrap squad DSL
  ⏳ S6–S8 样本已铺；FFI 未开

圈 5 · 自举终局
  nano-cc / .com 自举
  ❌ 未开卷

圈 6 · loader / pack / .com（TERMINAL-BFS）
  LDR PACK JIT AOT COM BOOT — layer1 ✅ · layer2 ⏳ 见 frontier
  [`TERMINAL-BFS.md`](TERMINAL-BFS.md)

圈 7 · 自举终局
  nano-jit.com → 下一代 .com — ❌ layer4 blocked
```

## DP 前沿（layer 2 · 已签收 2026-05-24）

| 槽 | 节点 ID | 环 | 验收（摘） | 状态 |
|----|---------|-----|------------|------|
| W1 | `com-lbin-in-ape` | 组装 | `pack-app.payload.lbin=1` · `mindmap-com-app.com` | **done** |
| W2 | `boot-selfpack-com` | 自举 | `nano-jit.com` hash + inspect-ape v2 | **done** |
| W3 | `codegen-ir-emit` | Codegen | `aarch64.emit.profile=ir-exit-v1` | **done** |
| W4 | `runner-squad-dispatch` | 编排 | `squad-dispatch.ok=1` bootstrap 步骤 | **done** |

**layer 3 已签收（terminal edge）**：

| 槽 | 节点 ID | 验收（摘） | 状态 |
|----|---------|------------|------|
| W1 | `loader-bare-default` | `pack-ape-bare.mode=bare` · `mindmap-bare.com` | **done** |
| W2 | `terminal-edge-milestone` | `terminal.edge.ok=1` · 单 plan 链 pack-ape→JIT→pack-app→`nano-jit.com` | **done** |

**layer 4 已签收**：`zero-host-bootstrap` — `nano-jit.com` 执行 `bootstrap-v4-zero-host-gen2-via-com.lisp` → `zero-host-gen2-nano-jit.com`（`zero.host.bootstrap.ok=1`）。**下一环**：gen3-on-zero-host-com、去 host `cc` build-slice。

## 波次地图（wave15–24）

| Wave | 轨 A（codegen） | 轨 B（编排/文档） |
|------|-----------------|-------------------|
| 15–20 | IR entry/table v1–v3、manifest | squad S6–S8、COMPLETE-SCOPED |
| 21 | table-only v4 + add18 | POST-V4、build-graph |
| 22 | — | assess-scoped、README 地图 |
| 23 | — | terminal build evidence |
| **24** | **plan-words-v5 + add19** | **MINDMAP.md + mindmap-tick** |

## wave26（宿主减量 · 三刀）

| 轨 | 交付 |
|----|------|
| A | `(ir-table-lisp …)` + add21 · `ir.op.svc0.from=plan-lisp-v1` |
| B | `(squad-assess catalog)` + `(results-min build.pass 26)` · [`SLICE18.md`](SLICE18.md) |
| R | 上表六维 + assess ready |

## 下一圈（wave27 草图）

| 圈 | P0 |
|----|-----|
| C2 | 第二 op 进 `v4-ir-table-v1.lisp` |
| O2 | assess 结果写 evidence（减 shell grep） |
| T1 | cosmocc full build.pass≥119 进 plan |

## wave25（plan-words 校验）

| 轨 | 交付 |
|----|------|
| A | `ir.table.verified=plan-words-v1`（C 读 `v4-ir-words-v1.txt`）+ add20 |
| B | [`PROGRESS.md`](PROGRESS.md) 终局六维表 + `bootstrap-v4-squad-assess-once.lisp` |
| R | `REFLECTION` 区分 catalog vs 终局 % |

## wave30

见 SLICE30.md

## wave31

见 SLICE31.md · evidence-matrix 四轨

## wave32

见 SLICE32.md · host-reduce 洋葱四轨

## wave33

见 SLICE33.md · build-graph 洋葱四轨

## wave34

见 SLICE34.md · plan-contract 洋葱四轨

## wave35–37

批量三波 · 见 SLICE35–37.md

## wave38–40

批量 · SLICE38–40.md

## wave41–43（洋葱 TDD 批量）

```text
扩散 → run.sh+assess → 修文档圈
每波 ≤4 轨：A diffusion / B plan / C plan / D evidence
```

## wave44–46

ir-words → gen5-bridge → scoped-close

## wave47–49

supervise → manifest → post-v4-close

## wave50–52

table-only → wave27/28 → eval-close

## 长程自主（wave53+）

```text
catalog 满 → 仍扩散
终局 <100% → 不停
```

## wave53–55

slice12–14 → squad → autonomous-milestone

## wave59–61

wave26/27 → evidence → codegen-manifest


## wave65–67

codegen-emit → squad-commander → onion-terminal（长程自主）


## wave68–73（长程自循环）

ir-table → build-graph → host-reduce → plan-contract → evidence → four-track-milestone

## wave83–85

reflection/resume → lisp-only/terminal → codegen/emit（长程自主续批）

## wave86–88

runner/plan → assess/evidence-matrix → onion/mindmap-close（长程自主续批）

## wave140–148

emit-bytes-obs → runner/codegen/emit 四轨扩散 → onion-milestone（`MINDMAP`+`LONG-RUN` tick · tests.pass 续涨）

## wave149–165（先扩散后并发）

一次 `gen 149 165` 框架 → **5× cc** 填肉（bootstrap/elf64/SLICE）→ **1× gate** · tests.pass **864**

## wave166–182（洋葱 TDD 续卷）

`gen 166 182` → 5×cc（onion.layer / onion.tdd / SLICE 洋葱段）→ gate · **tests.pass=932**
