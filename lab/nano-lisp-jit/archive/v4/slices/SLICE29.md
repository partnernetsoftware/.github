# v4 wave29 — 四轨扩散（≤4 并发）

| 轨 | 角色 | 交付 |
|----|------|------|
| **A** | codegen | `v4-plan-manifest-v1.lisp` + wave29-diffusion + add24 |
| **B** | 编排 | `bootstrap-v4-squad-four-roles.lisp`（四角色锚点） |
| **C** | 构建 | `bootstrap-v4-build-gates-plan.lisp`（双 results-min） |
| **D** | 签收 | manifest-anchor + evidence + [`EVAL.md`](EVAL.md) |

方法：扩散 → 一次 `run.sh` → 洋葱修。见 [`PARALLEL.md`](PARALLEL.md)。
