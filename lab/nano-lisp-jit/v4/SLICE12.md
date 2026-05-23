# v4 slice-12 — plan-side IR lisp（scoped）

**前置**：[`SLICE11.md`](SLICE11.md)。

## 实现

- `samples/v4-aarch64-add-exit-ops.lisp` — s-expression IR（`profile` / `ops` / `encode` 表），镜像 manifest 数据面
- `bootstrap-v4-slice12-ir-plan.lisp` — file-hash IR 源
- `bootstrap-v4-slice12-evidence.lisp` — hash IR + slice-11 add16 ELF 锚点

## 诚实口径

仍为 **C host 读 manifest** 填码；Lisp IR 仅 plan 侧数据与 hash 锚，**非** runtime 发射。

## 签收

`signoff.id=v4-slice12-scoped`
