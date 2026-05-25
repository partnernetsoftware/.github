# v4 slice-18 — 终局宿主减量（wave26）

| 刀 | 交付 |
|----|------|
| **Lisp IR → blob（一 op）** | `v4-ir-table-v1.lisp` 中 `svc0` → C emit 进 ELF |
| **squad-assess 真执行** | bootstrap `(squad-assess catalog)` 调 `tools/squad/squad.sh assess` |
| **build 进 plan** | `(results-min … bootstrap-report.txt build.pass 26)` |

仍非零宿主：runner 为 C；assess 仍调 Python。
