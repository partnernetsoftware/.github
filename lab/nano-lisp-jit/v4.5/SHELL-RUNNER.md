# Shell runner — practice ladder

**Goal**: `.com` becomes a Lisp-native shell runner — dogfood in `shell/*.lisp`, then embed in release COM.

## Capability layers

| Layer | API | C COM | Rust `nanolisp` |
|-------|-----|-------|-----------------|
| CLI | `spawn-wait` / `read-file` | ✅ | ✅ (Phase 0) |
| bootstrap | `(spawn-wait …)` / `(read-file …)` | ✅ | ✅ |
| `.lbin` VM | `libc:system` / `strlen` / … | ✅ | ✅ |
| `.lbin` addr | `libc:stdin` addr resolve | Rust ✅ | C (pin; no-arg pending) |

## Phase 0 (baseline)

**`lisp/shell/shell-v0-system.lisp`** — compile → run → `libc:system("echo …")`.

```bash
RS=lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp
$RS compile lab/nano-lisp-jit/lisp/shell/shell-v0-system.lisp /tmp/s.lbin
$RS run /tmp/s.lbin
```

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-v0-smoke.sh`

**Bootstrap plan**: `lisp/bootstrap/bootstrap-v45-shell-v0-smoke.lisp`

## Phase 1 — multi-command script

**`lisp/shell/shell-script.lisp`** — chained `libc:system` (3 steps).

```bash
$RS shell              # compile+run shell-script.lisp
$RS shell-repl         # VM read-line REPL (.lbin loop)
```

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-script-smoke.sh`

**Bootstrap plan**: `lisp/bootstrap/bootstrap-v45-shell-script-smoke.lisp`

## Phase 3 — no-arg shell dispatch

**`embed/shell-script.lbin`** — baked into `nanolisp` binary; `$COM` with no args runs it.

```bash
$RS                        # embedded shell.lbin (same as compile output)
$RS shell                  # dev: compile+run fresh shell-script.lisp
```

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-noarg-smoke.sh`

## Phase 6 — dual-track shell (current)

**`bootstrap-v45-shell-dual.lisp`** — Rust + C COM both compile/run `shell-v0`; stdin addr smoke.

```bash
bash lab/nano-lisp-jit/retired/scripts/nano-jit-shell-dual-smoke.sh
```

**Honest GAP**: C `nano-lisp.com` no-arg still prints usage (exit 2); Rust `nanolisp.com` runs embedded shell.

## Phase 5 — VM read-line

**`nano:read-line`** — `i32(ptr,i32)` FFI shim; **`shell-repl.lisp`** REPL loop in VM.

```bash
$RS shell-repl         # compile+run shell-repl.lisp (stdin → read-line → system)
```

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-repl-vm-smoke.sh`

## Phase 7 — libc fgets (stdin addr)

**`ptr(ptr,i32,ptr)`** — VM opcode `OP_CALL_IMPORT_CONST_IMM_PTR`; third arg is a resolved `addr` import (e.g. `libc:stdin`).

**`shell-fgets-smoke.lisp`** — resolve stdin, `fgets` into buf, expect nonnull from piped stdin.

```bash
$RS compile lab/nano-lisp-jit/lisp/shell/shell-fgets-smoke.lisp /tmp/f.lbin
printf 'line\n' | $RS run /tmp/f.lbin
```

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-fgets-smoke.sh`

**Honest GAP**: C COM parity for `ptr(ptr,i32,ptr)` + `OP_CALL_IMPORT_CONST_IMM_PTR` not ported; Rust-only Phase 7. Phase 6 `addr` resolve now dereferences globals (FILE* for `stdin`, not `&stdin`).

## Phase 4 — shell CI plan

**`lisp/bootstrap/bootstrap-v45-shell-ci.lisp`** — unified Phase 0–3 gate as bootstrap plan only.

```bash
$RS shell-ci           # run full shell ladder plan
$RS run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-ci.lisp
```

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-ci-smoke.sh`

Legacy per-phase smokes remain under `retired/scripts/nano-jit-rs-shell-*-smoke.sh` for granular debug.

## Roadmap

| Phase | Deliverable | Status |
|-------|-------------|--------|
| 0 | `shell-v0-system.lisp` + smoke + CLI parity | ✅ |
| 1 | `shell-script.lisp` + `nanolisp shell` | ✅ |
| 2 | `shell-repl` — VM read-line REPL (`nano:read-line`) | ✅ |
| 3 | `$COM` no-arg → built-in `shell.lbin` | ✅ |
| 4 | wave/ci scripts → shell plans only | ✅ |
| 6 | dual-track shell (C+Rust compile/run) + `addr` stdin | ✅ |
| 7 | libc `fgets` via stdin addr (`ptr(ptr,i32,ptr)`) | ✅ Rust |

## Integration into `.com`

1. Prove commands in `shell/*.lisp` + gate smoke.
2. AOT or compose module into runner slice (15-link / factory).
3. `main` dispatch: `argc==1` → `run shell.lbin`; else existing subcommands. ✅ (Rust dev + APE)

See also: [`PRODUCT-TRACKS.md`](PRODUCT-TRACKS.md) · [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md)
