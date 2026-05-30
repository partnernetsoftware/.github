# v4 slice-9 — opcode 索引 lowering 表（scoped）

**前置**：[`SLICE8.md`](SLICE8.md)。

## 实现

- `A64_ADD_EXIT_OP_*` + `a64_add_exit_v1_op_order[]` — 可观测 opcode 序
- 构建日志：`aarch64.emit.lowering.ops=5`
- `nano-jit-slice-add-14.lisp`（6+8→14）

## 签收

`signoff.id=v4-slice9-scoped`
