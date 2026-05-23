# v4 slice-11 — manifest encode 表（scoped）

**前置**：[`SLICE10.md`](SLICE10.md)。

## 实现

- `v4-aarch64-add-exit-ops.manifest` 增加 `encode …` 行（`imm=a|b` / `fixed=0x…`）
- 构建日志：`aarch64.emit.encode=manifest-v1`
- `nano-jit-slice-add-16.lisp`（9+7→16）

## 诚实口径

仍为 **C 解释 manifest** 填码；**非** Lisp runtime 读 IR。

## 签收

`signoff.id=v4-slice11-scoped`
