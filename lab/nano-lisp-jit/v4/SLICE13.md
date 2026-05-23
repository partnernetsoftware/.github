# v4 slice-13 — runner 读 Lisp encode 表（scoped）

**前置**：[`SLICE12.md`](SLICE12.md)。

## 实现

- `samples/v4-aarch64-add-exit-ops.lisp` — s-expression encode 表（`encodes` / `imm` / `fixed`）
- `bootstrap-v4-slice13-add18.lisp` — build-slice-lisp add18 smoke
- `bootstrap-v4-slice13-evidence.lisp` — hash add18 ELF + encode IR 锚点
- 构建日志：`aarch64.emit.encode=lisp-v1`
- `nano-jit-slice-add-18.lisp`（11+7→18）

## 诚实口径

runner **runtime 读 Lisp encode 表**填码；仍为 C host 解析 s-expression，**非**纯 Lisp 自举发射。

## 签收

`signoff.id=v4-slice13-scoped`
