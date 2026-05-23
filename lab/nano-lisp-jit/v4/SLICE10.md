# v4 slice-10 — manifest IR surface（scoped）

**前置**：[`SLICE9.md`](SLICE9.md)。

## 实现

- `samples/v4-aarch64-add-exit-ops.manifest` — 外部 `op …` 序表驱动 lowering
- 构建日志：`aarch64.emit.ir_surface=manifest-v1`、`aarch64.emit.manifest=…`
- `nano-jit-slice-add-15.lisp`（7+8→15）

## 诚实口径

仍为 **C host emit**；manifest 仅外置 opcode 序，**非** Lisp IR → VM 发射。

## 签收

`signoff.id=v4-slice10-scoped`
