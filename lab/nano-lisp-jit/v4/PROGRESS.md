# v4 终局进度（与 catalog 100% 分离）

**catalog `v4-complete` ready=True** = 工程洋葱 + 回归签收。  
**本表** = 完全 `.lisp` 自举、零 `.c` / `.py` / `.sh` 依赖。

| 维度 | 终局目标 | 当前 | 粗估 |
|------|----------|------|------|
| Plan（bootstrap 无 .c 源） | 全 plan 无 .c + manifest + wave-index | ✅ gate 常绿 | **~98%** |
| Runner | Lisp 执行 plan | gen2..gen10 `.com` runner 链 + terminal-edge on gen9 | **~35%** |
| Codegen | Lisp IR 整表 → blob | onion + zero-host lisp/aot 轨 | **~62%** |
| 编排 | Lisp `(squad-*)` | MINDMAP DP + hooks | **~58%** |
| 构建 | plan 内 build 图 | zero-host 全链 gate | **~75%** |
| 自举 | `.com` 生成下一代 | **gen2→gen10 scoped complete**（`zero.host.chain.complete=1`） | **~72%** |

**整体终局（scoped）**：约 **75%** — zero-host 链已收口；**未宣称 100%**：`build-slice` 仍 stage0-bridge、gen4/5/8 瘦包、非纯 Lisp 编 `lispjit.c`。

**验收**：`bootstrap-v4-zero-host-chain-complete.lisp` · `.build/v4-zero-host-bootstrap.evidence`

见 [`MINDMAP.md`](MINDMAP.md)、[`EVAL.md`](EVAL.md)。
