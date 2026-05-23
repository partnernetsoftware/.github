# v4 终局进度（与 catalog 100% 分离）

**catalog `v4-complete` ready=True** = 工程洋葱 + 回归签收。  
**本表** = 完全 `.lisp` 自举、零 `.c` / `.py` / `.sh` 依赖。

| 维度 | 终局目标 | 当前 | 粗估 |
|------|----------|------|------|
| Plan（bootstrap 无 .c 源） | 全 plan 无 .c | ✅ gate 常绿 | **~90%** |
| Runner | Lisp 执行 plan | C `nano-lisp-jit` | **~5%** |
| Codegen | Lisp IR → 发射 | C 表 stub + plan 字表契约 | **~15%** |
| 编排 | Lisp `(squad-*)` | Python + shell | **~10%** |
| 构建 | plan 内 build 图 | `run.sh` + `build_nano_jit.sh` | **~20%** |
| 自举 | `.com` 生成下一代 | 未开卷 | **~0%** |

**整体终局**：约 **10–20%**（外圈证据满 ≠ 内圈替换完成）。

**调整原则**（并行 + 洋葱）：每波只推进一圈一格；双轨 A=codegen / B=编排文档；波末一次 `run.sh`。

见 [`MINDMAP.md`](MINDMAP.md)、[`REFLECTION.md`](REFLECTION.md)。
