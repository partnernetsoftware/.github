# v4 wave27 — 扩散收敛（整表 + 编排束 + build 图）

| 面 | 交付 |
|----|------|
| **契约** | `v4-ir-table-v1.lisp` 五 op 整表 |
| **Codegen** | stub **一次**读整表 → `plan-lisp-v1-full` / v7 + add22 |
| **编排** | `bootstrap-v4-squad-orchestration-bundle.lisp` |
| **构建** | `bootstrap-v4-build-graph-wave27.lisp` + `wave27-diffusion` assess/results-min |
| **进度** | [`EVAL.md`](EVAL.md) 六维评估（合 main 用） |
