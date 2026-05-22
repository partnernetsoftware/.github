# nano-lisp-jit v3

v2.5 **100%** 完成。v3 **未完全 100%** — 缺 slice **4b-3**；**v3.5 冻结**。

## 自举两层 + codegen

| 层 | 含义 | 状态 |
|----|------|------|
| **A** | 用户 Lisp → `.lbin`/AOT；`nano-jit.com` self-pack | **100%** |
| **B 编排** | Lisp `bootstrap` genesis→gen1→gen2→gen3 | **100%** — [`BOOTSTRAP-THOROUGH.md`](BOOTSTRAP-THOROUGH.md) |
| **B codegen 4b-1** | `build-slice-lisp`（`.lisp`→ELF） | **100%** |
| **B codegen 4b-2** | `nano-cc` + `nano-cc-hello.c` | **100%** |
| **B codegen 4b-3** | 全量 `lispjit.c` 零 `cc` | **0%** — [`CODEGEN.md`](CODEGEN.md) |

## v3 完成度

| 切片 | 状态 |
|------|------|
| slice 0–3 core | **100%** |
| slice 4 编排 | **100%** |
| slice 4b-1 / 4b-2 | **100%** |
| slice 4b-3 | **0%** |

**v3 完全 100%**：**未签收**（~92%）。**v3.5**：待 4b-3 后 — [`../v3.5/README.md`](../v3.5/README.md)

## 命令

```bash
bash lab/nano-lisp-jit/run.sh
env NANO_SELFHOST_THOROUGH=1 NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh
```
