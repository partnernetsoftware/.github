# Shell runner — practice ladder

**Goal**: `.com` becomes a Lisp-native shell runner — dogfood in `shell/*.lisp`, then embed in release COM.

## Capability layers

| Layer | API | C COM | Rust `nanolisp` |
|-------|-----|-------|-----------------|
| CLI | `spawn-wait` / `read-file` | ✅ | ✅ (Phase 0) |
| bootstrap | `(spawn-wait …)` / `(read-file …)` | ✅ | ✅ |
| `.lbin` VM | `libc:system` / `strlen` / … | ✅ | ✅ |

## Phase 0 (current)

**`lisp/shell/shell-v0-system.lisp`** — compile → run → `libc:system("echo …")`.

```bash
RS=lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp
$RS compile lab/nano-lisp-jit/lisp/shell/shell-v0-system.lisp /tmp/s.lbin
$RS run /tmp/s.lbin
```

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-v0-smoke.sh`

**Bootstrap plan**: `lisp/bootstrap/bootstrap-v45-shell-v0-smoke.lisp` — `.lbin` + `spawn-wait` dual path.

## Roadmap

| Phase | Deliverable | Status |
|-------|-------------|--------|
| 0 | `shell-v0-system.lisp` + smoke + CLI parity | ✅ |
| 1 | `shell-script.lisp` — multi-command via bootstrap | pending |
| 2 | REPL — `fgets` / read-line FFI | pending |
| 3 | `$COM` no-arg → built-in `shell.lbin` | pending |
| 4 | wave/ci scripts → shell plans only | pending |

## Integration into `.com`

1. Prove commands in `shell/*.lisp` + gate smoke.
2. AOT or compose module into runner slice (15-link / factory).
3. `main` dispatch: `argc==1` → `run shell.lbin`; else existing subcommands.

See also: [`PRODUCT-TRACKS.md`](PRODUCT-TRACKS.md) · [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md)
