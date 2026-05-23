# v4 scoped 完成（洋葱 mindmap · 诚实口径）

**签收 id**：`v4-complete-scoped`  
**日期**：2026-05-23  
**不等于**：全仓库零 `.c`、VM/AOT 真 codegen、294/119 terminal 回归（见 `terminal_gates`）。

## 洋葱圈（本签收覆盖）

| 圈 | 内容 | 状态 |
|----|------|------|
| A Plan | 全部 `bootstrap-v4-*.lisp` 无 `.c` 源引用 | ✅ |
| B Runner | host `nano-lisp-jit` 执行 plan | ✅（v3.5 已接受） |
| C Codegen scoped | S0–S15：scout → opcode 表 → IR entry/table v1–v4 → manifest → table-only | ✅ scoped stub |
| 轨1 编排 scoped | S0–S8 bootstrap 契约（assess/dispatch/signal/resume 样本） | ✅ |
| 轨2 并行波次 | wave8–20 双轨（codegen ∥ 编排） | ✅ |
| 轨3 自举终局 | nano-cc / 下一代 `.com` | ❌ 留 post-v4 |

## 终局（post-v4）

- `terminal_gates`：`run.sh` ≥294、`build_nano_jit.sh` ≥119
- Lisp `(squad-*)` 替代 `tools/squad/*.py`
- IR 驱动 emit 替代 `nano_elf64.c` 内手写序列

## 并行推进法（固化）

见 [`PARALLEL.md`](PARALLEL.md)、[`skills/squad-parallel/`](../../skills/squad-parallel/)。
