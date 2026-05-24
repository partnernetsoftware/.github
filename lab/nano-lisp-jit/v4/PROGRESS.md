# v4 终局进度（与 catalog 100% 分离）

**catalog `v4-complete` ready=True** = 工程洋葱 + 回归签收。  
**本表** = 完全 `.lisp` 自举、零 `.c` / `.py` / `.sh` 依赖。

| 维度 | 终局目标 | 当前 | 粗估 |
|------|----------|------|------|
| Plan（bootstrap 无 .c 源） | 全 plan 无 .c + manifest + wave-index | ✅ gate 常绿 | **~98%** |
| Runner | Lisp 执行 plan | C `nano-lisp-jit` + runner/terminal/resume 锚点 | **~6%** |
| Codegen | Lisp IR 整表 → blob | stub + **add.result/operands** 可观测 | **~54%** |
| 编排 | Lisp `(squad-*)` | orchestration-bundle + evidence-matrix | **~49%** |
| 构建 | plan 内 build 图 | wave121 add116 + turbo gate | **~63%** |
| 自举 | `.com` 生成下一代 | 未开卷 | **~0%** |

**整体终局**：约 **15–22%**（wave113–121：cc 下手 + turbo，见 [`EVAL.md`](EVAL.md) §wave113–121）。

**调整原则**（并行 + 洋葱）：每波只推进一圈一格；扩散→收敛→洋葱；波末一次 `run.sh`（见 [`PARALLEL.md`](PARALLEL.md)）。

见 [`MINDMAP.md`](MINDMAP.md)、[`REFLECTION.md`](REFLECTION.md)。
