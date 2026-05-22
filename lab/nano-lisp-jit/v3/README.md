# nano-lisp-jit v3 kickoff

v2.5 **100%（scoped）** 完成。v3 从 v2.5 反思 + **自举语义分层** 出发，见 [`../ROADMAP.md`](../ROADMAP.md) mindmap。

## 自举两层（勿混）

| 层 | 含义 | 状态 |
|----|------|------|
| **A** | 用户 Lisp → `.lbin`/AOT；`nano-jit.com` self-pack | v1 **100%**，v3 保持不退化 |
| **B** | 编译器本体由 Lisp 生成 slice，脱离 `cc` 编 `lispjit.c` | **~10%** → [`BUILD-SLICE.md`](BUILD-SLICE.md) |

## v3 完成度

| 切片 | 状态 | 说明 |
|------|------|------|
| slice 0 VM `OP_CALL_FUNC` | **100%** | `func-call-vm-smoke.lisp` |
| slice 1 错误码/arity | **100%** | `func-param-vm-i64` + 负向 exit 2 |
| slice 2 aarch64 native slice | **0%** | 真 aarch64 payload |
| slice 3 证据/bootstrap | **~85%** | `bootstrap-v3-vm-selfpack-matrix.lisp` |
| slice 4 compiler-in-lisp | **~10%** | BUILD-SLICE stage 表 |

**v3 整体**：**~55%**

## 命令

```bash
bash lab/nano-lisp-jit/run.sh
env NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh
```
