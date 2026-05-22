# v3 CLI / VM error codes

Unified compile-time rejection for VM `.lbin` and AOT ELF paths.

| Exit | When | stderr tag |
|------|------|------------|
| **0** | success | — |
| **1** | parse/read/bad-args | `parse=fail`, `compile_fail`, `read=fail` |
| **2** | semantic compile rejection | `compile=unsupported_source reason=*`, `unsupported_source` (AOT) |
| **3** | blob write / generic `compile=fail` after infer passed | `compile=fail` |

## Arity / param (slice 1)

| reason | Sample |
|--------|--------|
| `load_arg_i64` | `func-param-missing-param-bad.lisp` — `load-arg-i64` without `(param i64)` |
| `call_arity` | `func-param-call-no-arg-bad.lisp` — `(call …)` with callee `(param i64)` but no i64 on stack |

Both must fail with **exit 2** on:

- `compile` → `.lbin`
- `compile-elf64-obj-code` / `compile-elf64-exe`

Positive path: `func-param-vm-i64.lisp` — `(param i64)` + `load-arg-i64` + `OP_LOAD_ARG_I64` in `.lbin` (see `run.sh` + `build_nano_jit.sh` native slice).

## VM runtime (execution, not compile)

| Exit | Meaning |
|------|---------|
| 20 | `call-func.*=bad_arg` — wrong value kind for call |
| 24 | bad func index / range |

Runtime codes are unchanged; slice 1 only unifies **compile-time** rejection.
