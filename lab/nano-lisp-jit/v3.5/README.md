# v3.5 — nano-cc 扩展

**Status: slice 0 100%** — v3 完全 100% 已签收。

| 切片 | 状态 | 说明 |
|------|------|------|
| slice 0 nano-cc 证据门禁 | **100%** | `nano-cc compile … -o`、bootstrap、`nano-cc-bad` exit 2 |
| slice 1 C-subset 前端 | **0%** | |
| slice 2 x86_64 对象发射 | **0%** | |
| slice 3 `build-slice` 切换 | **0%** | |
| slice 4 aarch64 nano-cc | **scoped** | route B: `NANO_CC_ARCH` exit42 + genesis-pin；[`AARCH64.md`](AARCH64.md) |
| slice 5 gen3 自举 | **0%** | |
| slice 6 Genesis 收缩 | **0%** | |

**v3.5 整体**：**~20%**

## slice 0 证据

```bash
bash lab/nano-lisp-jit/run.sh   # nano-cc-compile-hello-cli, nano-cc-run-hello-exit42, v35 plan
```

样例：`samples/bootstrap-v35-nano-cc-hello.lisp`、`samples/nano-cc-bad.c`  
错误码：[`ERROR-CODES.md`](ERROR-CODES.md)

## slice 4 aarch64（route B）

见 [`AARCH64.md`](AARCH64.md)。`run.sh`：`nano-cc-compile-hello-aarch64`、`nano-cc-qemu-aarch64-hello-exit42`（无 qemu 则 skip）。

## 目标

用扩展 **nano-cc** 逐步生成 slice，替代仅依赖 [`../genesis/`](../genesis/) pin 复制。见 [`../ROADMAP.md`](../ROADMAP.md) v3.5 mindmap。
