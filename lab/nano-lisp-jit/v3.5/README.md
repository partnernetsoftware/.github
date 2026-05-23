# v3.5 — nano-cc 扩展

**Status: slice 0 100%** — v3 完全 100% 已签收。切片 **1–6 并行 kickoff**，见 [`PARALLEL.md`](PARALLEL.md)。

| 切片 | 状态 | 说明 |
|------|------|------|
| slice 0 nano-cc 证据门禁 | **100%** | `nano-cc compile … -o`、bootstrap、`nano-cc-bad` exit 2 |
| slice 1 C-subset 前端 | **kickoff ~5%** | `add-parse`；见 [`ERROR-CODES.md#add-parse-slice-1`](ERROR-CODES.md#add-parse-slice-1) |
| slice 2 x86_64 对象发射 | **kickoff ~5%** | object+link；等 slice 1 IR dump 契约 |
| slice 3 `build-slice` 切换 | **0%** blocked | `build-slice-codegen`；见 [`ERROR-CODES.md#build-slice-codegen-slice-3`](ERROR-CODES.md#build-slice-codegen-slice-3) |
| slice 4 aarch64 nano-cc | **kickoff ~5%** | cross + qemu 或路线 B 文档 |
| slice 5 gen3 自举 | **0%** blocked | `bootstrap-v35-selfhost-gen3` |
| slice 6 Genesis 收缩 | **0%** blocked | pin + `NANO_REGENESIS` |

**v3.5 整体**：**~15%** — slice 0 签收；1/2/4 并行 kickoff；3/5/6 待上游波次。

## 并行下一命令

基线：

```bash
bash lab/nano-lisp-jit/run.sh
env NANO_SELFHOST_THOROUGH=1 NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh
```

| 轨道 | 下一命令 |
|------|----------|
| slice 1 | 加 `samples/nano-cc-add.c` + `add_parse_fail` 负向；`run.sh` parse/compile gate |
| slice 2 | nano-cc → `.o` → `link-elf64-exe`；对齐 host cc exit/符号 |
| slice 3 | `samples/bootstrap-v35-build-slice.lisp`；`env NANO_CC=1 bash lab/nano-lisp-jit/run.sh` |
| slice 4 | qemu aarch64 smoke 对照；aarch64 发射或路线 B 缺口文档 |
| slice 5 | `samples/bootstrap-v35-selfhost-gen3.lisp` + `selfhost-v35-gen3-*` |
| slice 6 | genesis manifest + CI 默认无 `cc lispjit.c` |

合并波次与冲突热点：[`PARALLEL.md`](PARALLEL.md)。

## slice 0 证据

```bash
bash lab/nano-lisp-jit/run.sh   # nano-cc-compile-hello-cli, nano-cc-run-hello-exit42, v35 plan
```

样例：`samples/bootstrap-v35-nano-cc-hello.lisp`、`samples/nano-cc-bad.c`  
错误码：[`ERROR-CODES.md`](ERROR-CODES.md)

## slice 4 aarch64（route B）

见 [`AARCH64.md`](AARCH64.md)。`run.sh`：`nano-cc-compile-hello-aarch64`、`nano-cc-qemu-aarch64-hello-exit42`（或 skip）。

## 目标

用扩展 **nano-cc** 逐步生成 slice，替代仅依赖 [`../genesis/`](../genesis/) pin 复制。见 [`../ROADMAP.md`](../ROADMAP.md) v3.5 mindmap。
