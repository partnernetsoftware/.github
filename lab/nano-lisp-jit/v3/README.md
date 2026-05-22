# nano-lisp-jit v3 kickoff

v2.5 **100%（scoped）** 完成。v3 从 v2.5 反思 + **自举语义分层** 出发，见 [`../ROADMAP.md`](../ROADMAP.md) mindmap。

## 自举两层（勿混）

| 层 | 含义 | 状态 |
|----|------|------|
| **A** | 用户 Lisp → `.lbin`/AOT；`nano-jit.com` self-pack | v1 **100%**，v3 保持不退化 |
| **B** | 编译器本体由 Lisp 生成 slice，脱离 `cc` 编 `lispjit.c` | **0%** → v3 **slice 4** |

当前链：`lispjit.c` ──cc/cosmo──► `nano-jit.*` ──► 只编译**用户** `.lisp`，不是「Lisp 编自己」。

## v3 完成度

| 切片 | 状态 | 说明 |
|------|------|------|
| slice 0 VM `OP_CALL_FUNC` | **100%** | `func-call-vm-smoke.lisp` + `run.sh` |
| slice 1 错误码/arity | **~80%** | VM/AOT exit 2；[`ERROR-CODES.md`](ERROR-CODES.md) |
| slice 2 aarch64 native slice | **0%** | 真 aarch64 payload |
| slice 3 证据/bootstrap | **~75%** | skip 汇总、bare pack、`build_nano_jit` func-call smoke |
| slice 4 compiler-in-lisp | **0%** | Lisp 构建图 → 替换 stage0 C 编译 |

**v3 整体**：**~40%**

## 洋葱序（可并行）

1. slice 1 收尾：`load-arg` VM  lowering（正路径）+ bootstrap DSL 负向
2. slice 2 + slice 3：aarch64 slice + self-packed 矩阵扩面
3. slice 4：最小 Lisp `(build-slice …)` 描述，与 §5/§6 ROADMAP 对齐

## 命令

```bash
bash lab/nano-lisp-jit/run.sh
env NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh
```
