# v3 slice 4 — compiler-in-lisp (B-layer bootstrap)

Stage model (onion order):

| Stage | Input | Output | Status |
|-------|--------|--------|--------|
| 0 seed | host `cc` / cosmocc | `nano-jit.x86_64` | **today** |
| 1 graph | Lisp `bootstrap-plan` | user `.lbin` / APE steps | **today** (A-layer) |
| 2 slice DSL | Lisp `(build-slice …)` / `(build-slice-lisp …)` | ELF payload bytes | **4b-1/4b-2 100%**；`lispjit.c` 仍 cc |
| 3 self-host | gen1→gen2→gen3 | orchestration + codegen smoke | **100%** 编排；4b-3 待办 |

Evidence: `bootstrap-v3-codegen-smoke.lisp`；`bootstrap-v3-selfhost-gen3.lisp`；[`CODEGEN.md`](CODEGEN.md).

**`build-slice`**: `nano-cc-hello.c` → `build-slice.role=lisp-codegen`；`lispjit.c` → `stage0-bridge`（cc）.

**`build-slice-lisp`**: `nano-jit-slice-min.lisp` → `compile-elf64-code`（零 cc）.

Next: **4b-3** — full `lispjit.c` via expanded `nano-cc`（v3 完全 100% 阻塞项；v3.5 冻结）。
