# Shell runner — practice ladder

**Goal**: `.com` becomes a Lisp-native shell runner — dogfood in `shell/*.lisp`, then embed in release COM.

## Capability layers

| Layer | API | C COM | Rust `nanolisp` |
|-------|-----|-------|-----------------|
| CLI | `spawn-wait` / `read-file` | ✅ | ✅ (Phase 0) |
| bootstrap | `(spawn-wait …)` / `(read-file …)` | ✅ | ✅ |
| `.lbin` VM | `libc:system` / `strlen` / … | ✅ | ✅ |

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
$RS shell-repl         # stdin REPL (host readline + sh -c)
```

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-script-smoke.sh`

**Bootstrap plan**: `lisp/bootstrap/bootstrap-v45-shell-script-smoke.lisp`

## Phase 3 — no-arg shell dispatch (current)

**`embed/shell-script.lbin`** — baked into `nanolisp` binary; `$COM` with no args runs it.

```bash
$RS                        # embedded shell.lbin (same as compile output)
$RS shell                  # dev: compile+run fresh shell-script.lisp
```

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-noarg-smoke.sh`

## Roadmap

| Phase | Deliverable | Status |
|-------|-------------|--------|
| 0 | `shell-v0-system.lisp` + smoke + CLI parity | ✅ |
| 1 | `shell-script.lisp` + `nanolisp shell` | ✅ |
| 2 | `shell-repl` — stdin REPL via `/bin/sh -c` | ✅ (host readline; VM fgets pending) |
| 3 | `$COM` no-arg → built-in `shell.lbin` | ✅ |
| 4 | wave/ci scripts → shell plans only | pending |

## Integration into `.com`

1. Prove commands in `shell/*.lisp` + gate smoke.
2. AOT or compose module into runner slice (15-link / factory).
3. `main` dispatch: `argc==1` → `run shell.lbin`; else existing subcommands. ✅ (Rust dev + APE)

See also: [`PRODUCT-TRACKS.md`](PRODUCT-TRACKS.md) · [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md)
