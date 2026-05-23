# v4 并行推进（不必等 signoff 100%）

## 口径

| 层 | 含义 | 推进条件 |
|----|------|----------|
| **scoped** | 本 slice 计划 + 证据 + 样本 | `assess` → `scoped_ready=True` 即可开下一波 |
| **terminal** | 全量 `run.sh` / `build_nano_jit.sh` 回归 | 合 `main` 前拉绿，不阻塞下一 slice 设计 |

`catalog-v4.yaml` 自 **wave15** 起：`v35-regression-*` 在 `terminal_gates`；`signoff.id=v4-slice10-scoped`。

## 双轨并行（每波最多两工程兵）

```text
轨 A · codegen   engineer-a  → ../lispjit-ir/nano_*.c + addN 样本 + v4-sliceN.evidence
轨 B · 编排      engineer-b  → bootstrap-v4-squad-*.lisp + v4/SLICE*.md（不碰 emit）
轨 R · 签收      reviewer    → sync-md + assess scoped_ready
```

**禁止**：两轨同改 `run.sh` 同一 case 块；新 case 由先完工轨追加，另一轨 rebase。

## Agent 快路径（单进程）

```bash
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml resume --reason wave15
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml dispatch --force --include-meta
# 并行实现 A/B touch_paths → 一次 bash lab/nano-lisp-jit/run.sh → done → assess
```

勿在未写代码时长期挂 `agent-team`（见 [`skills/squad-parallel/SKILL.md`](../../skills/squad-parallel/SKILL.md) 提速节）。

## wave16（当前）

| 轨 | 任务 id | 交付 |
|----|---------|------|
| A | `wave16-v4-ir-table-v2` | `ir.table.version=v2` + add16 |
| B | `wave16-v4-squad-dispatch` | `bootstrap-v4-squad-s6-dispatch.lisp` |

## wave24（洋葱 mindmap · 并行）

| 轨 | 任务 | 交付 |
|----|------|------|
| A | `wave24-v4-plan-words` | `v4-ir-words-v1.txt` + `plan-words-v1` / v5 + add19 |
| B | `wave24-v4-mindmap` | [`MINDMAP.md`](MINDMAP.md) + `bootstrap-v4-squad-mindmap-tick.lisp` |
| R | `wave24-v4-R` | assess `v4-complete` ready |

