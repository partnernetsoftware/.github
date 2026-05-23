# v4 洋葱 TDD mindmap（并行思维 · 活图）

**签收基线**：[`DECISION.md`](DECISION.md) · **`v4-complete`**（scoped S0–S15 + terminal native）。  
**本图**：post-v4 洋葱圈 **继续内卷**，每圈标 **scoped / 终局**。

## 并行法则（每波）

```text
轨 A · codegen    engineer-a  → nano_*.c + nano-jit-slice-add-N + .evidence
轨 B · 编排/文档  engineer-b  → bootstrap-v4-squad-* + v4/*.md
轨 R · 签收      reviewer    → 一次 run.sh → assess → sync-md
```

快路径：双轨实现 → **一次** `bash lab/nano-lisp-jit/run.sh`（勿空转 `agent-team`）。见 [`skills/squad-parallel/`](../../skills/squad-parallel/)。

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

## 下一圈（wave25 草图）

| 圈 | P0 |
|----|-----|
| C1 | C 读 `v4-ir-words-v1.txt` 校验 hash（仍 host） |
| O1 | `(squad-assess catalog)` 单步 plan |
| T1 | cosmocc full build.pass≥119 进 plan |
