# v4 slice-8 — emit lowering 表（scoped）

**前置**：[`SLICE7.md`](SLICE7.md)。

## 实现

- `emit_aarch64_add_exit_v1_lower` — 5 条 `uint32_t` 指令表驱动（替代内联手写序列）
- `emit_aarch64_add_exit_file` — 薄包装，行为与 slice-7 一致
- `nano-jit-slice-add-13.lisp` — 8+5→13 回归

## 签收

`signoff.id=v4-slice8-scoped`
