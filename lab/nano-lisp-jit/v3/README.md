# nano-lisp-jit v3 kickoff

v2.5 **100%（scoped）** 完成。v3 **core（slice 0–3）100%（scoped）**；slice 4（B 层）进行中。

## 自举两层

| 层 | 含义 | 状态 |
|----|------|------|
| **A** | 用户 Lisp → `.lbin`/AOT；`nano-jit.com` self-pack | **100%** |
| **B** | Lisp 生成编译器 slice，脱离 `cc` 编 `lispjit.c` | **~40%** — `build-slice` / `build-graph` 桥接 |

## v3 完成度

| 切片 | 状态 |
|------|------|
| slice 0 `OP_CALL_FUNC` | **100%** |
| slice 1 错误码/arity | **100%** |
| slice 2 aarch64 slice | **100%** scoped |
| slice 3 证据/bootstrap | **100%** |
| slice 4 compiler-in-lisp | **~40%** |

**v3 core**：**100%（scoped）** — [`REFLECTION.md`](REFLECTION.md)  
**v3 整体**：**~85%**

## 命令

```bash
bash lab/nano-lisp-jit/run.sh
env NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh
```
