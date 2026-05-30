# v4 slice-15 — emit table-only（post-v4）

**前置**：[`SLICE14.md`](SLICE14.md)、[`POST-V4.md`](POST-V4.md)。

## 交付

- 日志 `aarch64.emit.encode=table-only`（movz + fixed 均经表）
- add18（10+8）ELF

## 非目标

- 去掉 C runner
- Lisp 内嵌 u64 码表
