# nano-lisp-jit v3 kickoff

v2.5 **100%（scoped）** 完成。v3 **100%（scoped）** — core + B 层编排自举；Lisp codegen 未达成。

## 自举两层

| 层 | 含义 | 状态 |
|----|------|------|
| **A** | 用户 Lisp → `.lbin`/AOT；`nano-jit.com` self-pack | **100%** |
| **B orchestration** | Lisp `bootstrap` 编排 genesis→gen1→gen2 | **100%** scoped — [`BOOTSTRAP-THOROUGH.md`](BOOTSTRAP-THOROUGH.md) |
| **B codegen** | Lisp 生成 slice 机器码，零 `cc` | **0%** — `build-slice` 仍 stage0-bridge |

## v3 完成度

| 切片 | 状态 |
|------|------|
| slice 0 `OP_CALL_FUNC` | **100%** |
| slice 1 错误码/arity | **100%** |
| slice 2 aarch64 slice | **100%** scoped |
| slice 3 证据/bootstrap | **100%** |
| slice 4 orchestration（B 层） | **100%** scoped |
| slice 4b codegen | **0%** |

**v3 整体（scoped）**：**100%** — 反思见 [`REFLECTION.md`](REFLECTION.md)

## 命令

```bash
bash lab/nano-lisp-jit/run.sh
env NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh
env NANO_SELFHOST_THOROUGH=1 NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh
```
