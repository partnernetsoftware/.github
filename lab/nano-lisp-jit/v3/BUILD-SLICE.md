# v3 slice 4 — compiler-in-lisp (B-layer bootstrap)

Stage model (onion order):

| Stage | Input | Output | Status |
|-------|--------|--------|--------|
| 0 seed | host `cc` / cosmocc | `nano-jit.x86_64` | **today** |
| 1 graph | Lisp `bootstrap-plan` | user `.lbin` / APE steps | **today** (A-layer) |
| 2 slice DSL | Lisp `(build-slice …)` | ELF payload bytes | **v3 slice 4 — 0%** |
| 3 self-host | `nano-jit.com` | next-gen `.com` without stage 0 | **future** |

Evidence anchor: `samples/bootstrap-v3-vm-selfpack-matrix.lisp` runs on self-packed runner when `NANO_SLICE_COMPILER=native`.

Next implementation slice: add `(build-slice source.c out.elf arch)` bootstrap step that shells to `cc` with explicit report field `build-slice.role=stage0-bridge` (documented bridge, not claiming B-layer done).
