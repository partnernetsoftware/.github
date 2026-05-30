# nano-lisp-jit v3

v2.5 **100%**。v3 **完全 100%** 已签收。

## 自举 + codegen

| 层 | 状态 |
|----|------|
| **A** 用户 Lisp + self-pack | **100%** |
| **B 编排** gen1→gen2→gen3 | **100%** — [`BOOTSTRAP-THOROUGH.md`](BOOTSTRAP-THOROUGH.md) |
| **4b-1** `build-slice-lisp` | **100%** |
| **4b-2** `nano-cc` hello | **100%** |
| **4b-3** `lispjit.c` genesis-pin | **100%** — [`CODEGEN.md`](CODEGEN.md) |

## 命令

```bash
bash lab/nano-lisp-jit/run.sh
env NANO_SELFHOST_THOROUGH=1 NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh
# 刷新 genesis pin（有意 host cc）：
env NANO_REGENESIS=1 NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh
```

**下一圈**：[`../v3.5/README.md`](../v3.5/README.md)
