# v3.5 — nano-cc 扩展

**Status: slice 0–5 scoped + wave3 进行中** — v3 完全 100% 已签收。并行见 [`PARALLEL.md`](PARALLEL.md)；反思见 [`REFLECTION.md`](REFLECTION.md)（技术债、实验、P0–P3）。

| 切片 | 状态 | 说明 |
|------|------|------|
| slice 0 nano-cc 证据门禁 | **100%** | `nano-cc compile … -o`、bootstrap、`nano-cc-bad` exit 2 |
| slice 1 C-subset 前端 | **scoped** | `nano-cc parse` dump；`nano-cc-add-bad-sig` exit 2 |
| slice 2 x86_64 add | **100%** scoped | companion `.lisp` + `nano-cc-add` exit 42 |
| slice 3 `build-slice` 切换 | **100%** scoped | `NANO_BUILD_SLICE_CODEGEN=1` + `nano-cc-*.c` |
| slice 4 aarch64 nano-cc | **scoped** | `NANO_CC_ARCH` exit42；[`AARCH64.md`](AARCH64.md) |
| slice 5 gen3 自举 | **100%** scoped | `bootstrap-v35-selfhost-gen3`、genesis pin pack |
| slice 6 Genesis 收缩 | **~scoped kickoff** | [`GENESIS-SHRINK.md`](GENESIS-SHRINK.md)、`bootstrap-v35-genesis-shrink` |

**v3.5 整体**：**~55%**

## slice 0 证据

```bash
bash lab/nano-lisp-jit/run.sh   # nano-cc-compile-hello-cli, nano-cc-run-hello-exit42, v35 plan
```

样例：`samples/bootstrap-v35-nano-cc-hello.lisp`、`samples/nano-cc-bad.c`  
错误码：[`ERROR-CODES.md`](ERROR-CODES.md)

## slice 3 证据

```bash
bash lab/nano-lisp-jit/run.sh   # run-bootstrap-v35-build-slice-plan
env NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh   # run-bootstrap-v35-build-slice-native-slice
```

样例：`samples/bootstrap-v35-build-slice.lisp`、`samples/nano-cc-build-slice.c`  
环境：`NANO_BUILD_SLICE_CODEGEN=1`

## slice 4 aarch64（route B）

见 [`AARCH64.md`](AARCH64.md)。`run.sh`：`nano-cc-compile-hello-aarch64`、`nano-cc-qemu-aarch64-hello-exit42`（无 qemu 则 skip）。

## slice 6 genesis shrink（scoped kickoff）

见 [`GENESIS-SHRINK.md`](GENESIS-SHRINK.md)。`run.sh`：`run-bootstrap-v35-genesis-shrink-plan`。

## 目标

用扩展 **nano-cc** 逐步生成 slice，替代仅依赖 [`../genesis/`](../genesis/) pin 复制。见 [`../ROADMAP.md`](../ROADMAP.md) v3.5 mindmap。
