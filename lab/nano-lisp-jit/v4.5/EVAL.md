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

**v4.5 scoped 整体**：**100%**（本版本签收口径）

**全仓终局**（零 `.c`、VM emit、删 `run.sh`）：**~35–40%** — tier3–4 未开卷

## 本波（/goal 边界扩展）

| 类 | 路径 |
|----|------|
| 正向 boundary | `samples/boundary/*.lisp` ×13 |
| 负向 boundary | `bootstrap-v45-boundary-negative.lisp` |
| 产品反馈 | `PRODUCT-FEEDBACK.md` + `bootstrap-v45-boundary-feedback.lisp` |
| 证据键 | `v45.boundary.probes=13` · `v45.product.feedback=1` |

## 验证

```bash
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64 \
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS \
  $COM run-bootstrap-plan lab/nano-lisp-jit/samples/bootstrap-v45-onion-tdd.lisp

grep -E 'v45\.(scoped\.100|boundary\.probes|boundary\.negative)=' \
  lab/nano-lisp-jit/.build/v45-entry.evidence
```
