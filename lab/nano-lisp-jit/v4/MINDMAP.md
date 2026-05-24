# v4 洋葱 TDD mindmap（并行思维 · 活图）

**签收基线**：[`DECISION.md`](DECISION.md) · **`v4-complete`**（scoped S0–S15 + terminal native）。  
**本图**：post-v4 洋葱圈 **继续内卷**，每圈标 **scoped / 终局**。

## 终局六维（与 catalog 100% 分离）

| 维度 | 终局目标 | 当前 | 粗估 |
|------|----------|------|------|
| Plan | bootstrap 无 .c 源 | gate 常绿 | **~90%** |
| Runner | Lisp 执行 plan | C `nano-lisp-jit` | **~5%** |
| Codegen | Lisp IR 表 → blob | C stub 读 `v4-ir-table-v1.lisp`（svc0） | **~18%** |
| 编排 | Lisp `(squad-*)` | `(squad-assess)` 真调 assess；仍 Python | **~12%** |
| 构建 | plan 内 build 图 | `(results-min build.pass)` + `run.sh` | **~22%** |
| 自举 | `.com` 生成下一代 | 未开卷 | **~0%** |

**整体终局 ~10–20%**；**catalog `v4-complete` = 工程洋葱签收**（见 [`PROGRESS.md`](PROGRESS.md)）。


## 并行法则（每波）

**扩散 → 收敛 → 洋葱修正**（见 [`PARALLEL.md`](PARALLEL.md)）：先并发铺开整表/整图/整批门禁，再**一次** `run.sh`，最后由内圈向外修；禁止碎补式「一刀一 op」。

```text
轨 A · 契约/codegen  engineer-a  → ir-table/words 整份 + 样本族
轨 B · plan/编排      engineer-b  → bootstrap 图 + squad-* + v4/*.md
轨 R · 签收          reviewer    → 一次 run.sh → assess → sync-md
```

快路径：多轨扩散写完 → **一次** `bash lab/nano-lisp-jit/run.sh`（勿空转 `agent-team`）。见 [`skills/squad-parallel/`](../../skills/squad-parallel/)。

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
  ✅ S10–S16 日志回归；❌ VM/AOT 真发射

圈 4 · 编排终局
  tools/squad/*.py → bootstrap squad DSL
  ⏳ S6–S8 样本已铺；FFI 未开

圈 5 · 自举终局
  nano-cc / .com 自举
  ❌ 未开卷
```

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
