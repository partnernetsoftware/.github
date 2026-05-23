# v3.5 slice 4 — aarch64 nano-cc (route B, scoped)

**Status: slice 4 scoped evidence** — x86_64 nano-cc first; aarch64 exit42 without host cross-gcc for `nano-cc-hello.c`.

## Policy

| Target | Daily path | Refresh path |
|--------|------------|--------------|
| **x86_64** `nano-cc-hello.c` | `nano-cc compile … -o` → `emit_elf64_exit` (SysV x86_64) | same |
| **aarch64** `nano-cc-hello.c` | `NANO_CC_ARCH=aarch64 nano-cc compile … -o` → `emit_aarch64_exit` | same |
| **aarch64** `nano-cc-build-slice.c` | `build-slice … aarch64` → nano-cc (`NANO_CC_ARCH` from arch arg) | `NANO_BUILD_SLICE_CODEGEN=1` |
| **aarch64** full `lispjit.c` slice | `build-slice` → **genesis-pin** (`genesis/nano-jit.aarch64`) | `NANO_REGENESIS=1` + cosmocc or `aarch64-linux-gnu-gcc` cross |
| **aarch64** `nano-jit-slice-min.lisp` | `build-slice-lisp … aarch64` → `emit_aarch64_exit` (exit from `(expect N)`) | same |

Route B: nano-cc emits only the C-subset smoke (`int main(){return N;}`). Full slice ELFs stay on genesis-pin until later slices replace them with nano-cc codegen.

## Evidence

```bash
bash lab/nano-lisp-jit/run.sh
# nano-cc-compile-hello-aarch64
# nano-cc-qemu-aarch64-hello-exit42   (when qemu-aarch64-static present)
# run-bootstrap-v35-nano-cc-aarch64-plan
# run-bootstrap-v35-build-slice-aarch64-plan
# nano-cc-qemu-aarch64-build-slice-exit43   (when qemu-aarch64-static present)
# run-bootstrap-v35-build-slice-lisp-aarch64-plan
# nano-cc-qemu-aarch64-build-slice-lisp-exit42   (when qemu-aarch64-static present)
# run-bootstrap-v4-aarch64-aot-plan   (v4 slice-0 scout; aarch64-add-emit stub)
```

Bootstrap: `samples/bootstrap-v35-nano-cc-aarch64.lisp`, `samples/bootstrap-v35-build-slice-aarch64.lisp`, `samples/bootstrap-v35-build-slice-lisp-aarch64.lisp`, `samples/bootstrap-v4-aarch64-aot-plan.lisp` (v4 slice-0 scout)

## Environment

| Variable | Effect |
|----------|--------|
| `NANO_CC_ARCH=aarch64` | nano-cc emits ELF64 `EM_AARCH64` exit stub (no `aarch64-linux-gnu-gcc`); `build-slice … aarch64` sets this from the arch arg |
| `NANO_BUILD_SLICE_CODEGEN=1` | route `nano-cc-build-slice.c` through `build-slice` nano-cc path |
| `NANO_REGENESIS=1` | `build_nano_jit.sh` may cross-build / refresh genesis aarch64 pin |
| (default) | `lispjit.c` `build-slice aarch64` copies genesis pin; zero host `cc` |

## Gaps (explicit)

- nano-cc aarch64: **exit42 stub only** — not arithmetic/AOT/multi-section yet.
- `build-slice-lisp` aarch64: **exit stub only** (`nano-jit-slice-min.lisp`, `nano-jit-slice-add.lisp` via `(expect N)`); no VM/AOT aarch64 codegen yet.
- qemu smoke required on x86_64 host to execute aarch64 nano-cc ELF (native aarch64 host runs directly).

## v4 slice-0 scope (kickoff plan marker)

v3.5 **slice 4** evidence above stays frozen; v4 **slice-0** only adds a bootstrap plan scout — no new aarch64 codegen yet.

| Artifact | Role | Codegen |
|----------|------|---------|
| `samples/bootstrap-v4-aarch64-aot-plan.lisp` | v4 kickoff plan marker | reuses v3.5 `build-slice-lisp.mode=aarch64-add-emit` on `nano-jit-slice-add.lisp` |
| `.build/bootstrap-v4-aarch64-add-scout.elf` | scout ELF output | hardcoded add stub (`40+2` → exit 42), **not** VM/AOT aarch64 |

**In scope (slice-0)**: `run.sh` case `run-bootstrap-v4-aarch64-aot-plan`; file-size/hash evidence in the bootstrap plan.

**Out of scope (v4 slice proper, see [`../v4/README.md`](../v4/README.md))**: aarch64 VM/AOT codegen from Lisp IR; nano-cc aarch64 arithmetic/multi-section; replacing add-emit stub with x86 compile-path cross codegen.

See also [`../v3/CODEGEN.md`](../v3/CODEGEN.md) genesis-pin policy and [`ERROR-CODES.md`](ERROR-CODES.md).
