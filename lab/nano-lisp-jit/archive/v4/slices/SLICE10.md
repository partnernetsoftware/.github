# v4 slice-10 — IR entry 锚点（scoped）

**前置**：[`SLICE9.md`](SLICE9.md)。并行策略：[`PARALLEL.md`](PARALLEL.md)。

## 交付

| 轨 | 内容 |
|----|------|
| **codegen** | 构建日志 `aarch64.emit.ir.entry=v1`；add15（7+8）ELF |
| **编排** | `bootstrap-v4-squad-s6-assess.lisp` — S6 只读 assess 契约样本 |

## 非目标

- Lisp 内真 `(squad-assess …)` FFI
- 替换 C 内 `a64_add_exit_v1_encode`

## 签收

`signoff.id=v4-slice10-scoped`（terminal 回归另计）。
