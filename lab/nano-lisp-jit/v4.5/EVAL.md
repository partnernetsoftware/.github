# v4.5 进度评估

**签收**：`v45-scoped-100` · 洋葱 TDD 真源 = [`ONION-TDD.md`](ONION-TDD.md)

## 六维（v4.5 scoped）

| 维度 | 目标 | 评估 |
|------|------|------|
| Plan | bootstrap 无 `.c` | **100%** — verify + boundary + onion |
| Runner | `.com` 执行 plan | **100%** — com-only gate 绿 |
| 构建 | genesis-pin 日常 | **100%** — tier2 plan + compare.ok |
| 验收载体 | `*.lisp` 替代 `.sh` 纵切片 | **~85%** — 洋葱矩阵在 plan；工厂 `run.sh` 仍全量 |
| v4 交接 | gen60 / genesis | **100%** — handoff plan |
| 能力边界 | boundary 样例 | **开卷** — 5 个 boundary/*.lisp |

**v4.5 scoped 整体**：**100%**（本版本签收口径）

**全仓终局**（零 `.c`、VM emit）：**~35–40%**（与 v4 EVAL 六维对齐，未抬升 codegen 实质）

## 本波交付

| 类 | 路径 |
|----|------|
| 洋葱主 plan | `bootstrap-v45-onion-tdd.lisp` |
| 终局 plan | `bootstrap-v45-terminal-done.lisp` |
| tier2 | `bootstrap-v45-build-slice-genesis.lisp` |
| 边界探测 | `samples/boundary/*.lisp` + `bootstrap-v45-boundary-probe.lisp` |
| 目录图 | [`STRUCTURE.md`](../STRUCTURE.md) |
| 反思 | [`REFLECTION.md`](REFLECTION.md) |

## 验证

```bash
grep -E 'v45\.(scoped\.100|onion\.lisp_only|build\.no_host_cc)=' \
  lab/nano-lisp-jit/.build/v45-entry.evidence
```
