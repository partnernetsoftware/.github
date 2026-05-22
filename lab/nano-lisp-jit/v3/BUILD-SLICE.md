# v3 slice 4 — compiler-in-lisp (B-layer bootstrap)

Stage model (onion order):

| Stage | Input | Output | Status |
|-------|--------|--------|--------|
| 0 seed | host `cc` / cosmocc | `nano-jit.x86_64` | **today** |
| 1 graph | Lisp `bootstrap-plan` | user `.lbin` / APE steps | **today** (A-layer) |
| 2 slice DSL | Lisp `(build-slice …)` | ELF payload bytes | **v3 slice 4 — 0%** |
| 3 self-host | `nano-jit.com` | next-gen `.com` without stage 0 | **future** |

Evidence anchor: `samples/bootstrap-v3-vm-selfpack-matrix.lisp` runs on self-packed runner when `NANO_SLICE_COMPILER=native`.

**Implemented (v3 ~25%)**: bootstrap `(build-slice "lispjit.c" "out.elf" "x86_64"|"aarch64")` — see `samples/bootstrap-v3-build-slice.lisp`. Emits `build-slice.role=stage0-bridge`. Still invokes host/cross `cc`, not Lisp codegen.

Next: Lisp IR lowering for slice bytes; then drop stage0 `cc` for `lispjit.c`.
