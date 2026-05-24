# v4 终局进度（与 catalog 100% 分离）

**catalog `v4-complete` ready=True** = 工程洋葱 + 回归签收。  
**本表** = 完全 `.lisp` 自举、零 `.c` / `.py` / `.sh` 依赖。

| 维度 | 终局目标 | 当前 | 粗估 |
|------|----------|------|------|
| Plan | 全 plan 无 .c | ✅ | **~98%** |
| Runner | `.com` 链 gen2→gen13 | gen9 全功能 runner | **~42%** |
| Codegen | Lisp IR → blob | gen13 `lisp-by-extension` on gen9 | **~68%** |
| 构建 | plan 内 build 图 | gen11 无 genesis · gen12 nano-cc codegen | **~82%** |
| 自举 | `.com` 下一代 | gen2→gen13 + phase2 无 genesis / lisp-route | **~78%** |

**整体终局**：约 **80%** — phase2 已去 genesis pin（gen11–13）；**仍非 100%**：`lispjit.c` 日构建仍 `stage0-bridge`。

证据：`.build/v4-zero-host-bootstrap.evidence`（`zero.host.lisp_route=1` · `zero.host.nano_cc_codegen=1`）
