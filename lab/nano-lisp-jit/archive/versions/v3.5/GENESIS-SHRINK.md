# v3.5 slice 6 — Genesis shrink (scoped)

**Status: slice 6 kickoff ~scoped** — CI gates document and enforce daily zero host `cc` for `lispjit.c` slice builds.

## Policy

| Path | Daily build | Refresh (intentional host compiler) |
|------|-------------|-------------------------------------|
| `(build-slice "…/lispjit.c" …)` | **genesis-pin** — copy from [`../genesis/`](../genesis/README.md) | `NANO_REGENESIS=1` + `build_nano_jit.sh` |
| `(build-slice "…/nano-cc-*.c" …)` with `NANO_BUILD_SLICE_CODEGEN=1` | **nano-cc** / lisp-codegen | same |
| `(build-slice-lisp …)` | **lisp-codegen** | n/a |

Daily builds must **not** invoke host `cc` on `lispjit.c`. Logs must show `build-slice.role=genesis-pin` and `build-slice.compiler=none` (not `build-slice.compiler=cc`).

## When `NANO_REGENESIS=1` is allowed

Use only when intentionally refreshing genesis pins:

- Security or toolchain fix requires recompiling the pinned slice ELF.
- `lispjit.c` or libc/link flags changed in a way that invalidates the existing pin.
- Adding or updating the aarch64 pin (cross-gcc / cosmocc).

```bash
env NANO_REGENESIS=1 NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh
```

**Forbidden** in CI and routine developer loops: `NANO_REGENESIS=1` without review, or `NANO_SLICE_ALLOW_HOST_CC=1` for `lispjit.c` (deprecated since slice 3).

Genesis artifacts and hashes: [`../genesis/README.md`](../genesis/README.md), `genesis/manifest.txt`.

## Evidence

```bash
bash lab/nano-lisp-jit/run.sh
# run-bootstrap-v35-genesis-shrink-plan
# genesis-shrink-no-host-cc-build-log
```

Bootstrap: `samples/bootstrap-v35-genesis-shrink.lisp` — `build-slice` on `lispjit.c`, assert genesis-pin and no host `cc`.

## Build-level audit (slice 6)

After selfhost/bootstrap, `build_nano_jit.sh` runs `audit_genesis_shrink_log` on `bootstrap-report.txt`. `run.sh` runs the same helper on `results.txt` (`genesis-shrink-no-host-cc-build-log`).

The audit scans build logs for `build-slice.compiler=cc` paired with a subsequent `build-slice.source=…/lispjit.c` in the same build-slice stanza. If found and `NANO_REGENESIS` is unset, the build fails. Intentional pin refresh (`NANO_REGENESIS=1`) skips the check.

Helper: [`../audit_genesis_shrink.sh`](../audit_genesis_shrink.sh).

Optional native-slice matrix (when `NANO_SLICE_COMPILER=native`):

```bash
env NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh
# run-bootstrap-v35-genesis-shrink-native-slice
```

## Environment

| Variable | Effect |
|----------|--------|
| (default) | `lispjit.c` `build-slice` → genesis-pin; zero host `cc` |
| `NANO_REGENESIS=1` | `build_nano_jit.sh` may compile and update genesis pins |
| `NANO_SLICE_ALLOW_HOST_CC=1` | Deprecated fallback to host `cc` for `lispjit.c` |

See also [`../v3/CODEGEN.md`](../v3/CODEGEN.md), [`PARALLEL.md`](PARALLEL.md) track F, [`ERROR-CODES.md`](ERROR-CODES.md).
