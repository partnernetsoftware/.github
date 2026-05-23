# v3.5 slice 4 — aarch64 nano-cc (route B, scoped)

**Status: slice 4 scoped evidence** — x86_64 nano-cc first; aarch64 exit42 without host cross-gcc for `nano-cc-hello.c`.

## Policy

| Target | Daily path | Refresh path |
|--------|------------|--------------|
| **x86_64** `nano-cc-hello.c` | `nano-cc compile … -o` → `emit_elf64_exit` (SysV x86_64) | same |
| **aarch64** `nano-cc-hello.c` | `NANO_CC_ARCH=aarch64 nano-cc compile … -o` → `emit_aarch64_exit` | same |
| **aarch64** full `lispjit.c` slice | `build-slice` → **genesis-pin** (`genesis/nano-jit.aarch64`) | `NANO_REGENESIS=1` + cosmocc or `aarch64-linux-gnu-gcc` cross |

Route B: nano-cc emits only the C-subset smoke (`int main(){return N;}`). Full slice ELFs stay on genesis-pin until later slices replace them with nano-cc codegen.

## Evidence

```bash
bash lab/nano-lisp-jit/run.sh
# nano-cc-compile-hello-aarch64
# nano-cc-qemu-aarch64-hello-exit42   (when qemu-aarch64-static present)
# run-bootstrap-v35-nano-cc-aarch64-plan
```

Bootstrap: `samples/bootstrap-v35-nano-cc-aarch64.lisp`

## Environment

| Variable | Effect |
|----------|--------|
| `NANO_CC_ARCH=aarch64` | nano-cc emits ELF64 `EM_AARCH64` exit stub (no `aarch64-linux-gnu-gcc`) |
| `NANO_REGENESIS=1` | `build_nano_jit.sh` may cross-build / refresh genesis aarch64 pin |
| (default) | `lispjit.c` `build-slice aarch64` copies genesis pin; zero host `cc` |

## Gaps (explicit)

- nano-cc aarch64: **exit42 stub only** — not arithmetic/AOT/multi-section yet.
- `build-slice-lisp` aarch64: still `aarch64_not_implemented`.
- qemu smoke required on x86_64 host to execute aarch64 nano-cc ELF (native aarch64 host runs directly).

See also [`../v3/CODEGEN.md`](../v3/CODEGEN.md) genesis-pin policy and [`ERROR-CODES.md`](ERROR-CODES.md).
