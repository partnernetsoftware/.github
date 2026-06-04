# Shell runner — practice ladder

**Goal**: `.com` becomes a Lisp-native shell runner — dogfood in `shell/*.lisp`, then embed in release COM.

## Capability layers

| Layer | API | C COM | Rust `nanolisp` |
|-------|-----|-------|-----------------|
| CLI | `spawn-wait` / `read-file` | ✅ | ✅ (Phase 0) |
| bootstrap | `(spawn-wait …)` / `(read-file …)` | ✅ | ✅ |
| `.lbin` VM | `libc:system` / `strlen` / … | ✅ | ✅ |
| `.lbin` addr | `libc:stdin` addr resolve | ✅ (pin) | ✅ |
| no-arg dispatch | `$COM` → embedded shell | ❌ release pin · ✅ source/host cc | ✅ Phase 3 |

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
$COM                       # C: source argc==1 wired; release COM still usage until promote
```

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-noarg-smoke.sh`

**C track smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-c-shell-noarg-smoke.sh`

**Bootstrap plan**: `lisp/bootstrap/bootstrap-v45-shell-c-noarg.lisp`

### C track — source vs release GAP

| Artifact | `argc==1` behavior | Testable now |
|----------|-------------------|--------------|
| Rust `nanolisp.com` (release) | embedded `shell-script.lbin` | ✅ |
| C `nano_main.c` + `nano_shell_cli.c` (source) | `run-app(self)` → embed file → compile-run fallback | ✅ host `cc` |
| C `release/nano-lisp.com` (manifest pin) | usage, exit 2 | ✅ smoke expects GAP |

**Source dispatch** (`archive/c/runner/nano_main.c`): `argc==1` → `cmd_shell_noarg(argv[0])`:

1. `run-app` on self when factory `pack-app` embeds `shell-script.lbin` (TODO promote).
2. Repo embed files: `archive/c/embed/shell-script.lbin` or `nano-jit-rs/embed/shell-script.lbin`.
3. Fallback: compile+run `lisp/shell/shell-script.lisp` → `shell.mode=lbin-script`.

**Host cc bootstrap** (no cosmocc):

```bash
cc -DNANO_LISP_JIT -I lab/lispjit-ir -I lab/nano-lisp-jit/retired/archive-c/runner \
  -Os -s lab/nano-lisp-jit/archive/c/runner/lispjit.c -ldl \
  -o lab/nano-lisp-jit/.build/nano-lisp-jit-host-shell-noarg
lab/nano-lisp-jit/.build/nano-lisp-jit-host-shell-noarg   # shell.mode=… step1 ret=0
```

**Still requires cosmocc release promote**: rebuild + repack `release/nano-lisp.com` so pinned manifest picks up no-arg dispatch (or factory embed for `shell.mode=embedded-lbin` without compile-run fallback).

## Phase 5 — VM read-line

**`nano:read-line`** — `i32(ptr,i32)` FFI shim; **`shell-repl.lisp`** REPL loop in VM.

```bash
$RS shell-repl         # compile+run shell-repl.lisp (stdin → read-line → system)
```

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-repl-vm-smoke.sh`

## Phase 4 — shell CI plan

**`lisp/bootstrap/bootstrap-v45-shell-ci.lisp`** — unified Phase 0–3 gate as bootstrap plan only.

```bash
$RS shell-ci           # run full shell ladder plan
$RS run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-ci.lisp
```

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-ci-smoke.sh`

Legacy per-phase smokes remain under `retired/scripts/nano-jit-rs-shell-*-smoke.sh` for granular debug.

## Phase 6 — dual-track shell (current)

**`bootstrap-v45-shell-dual.lisp`** — Rust + C COM both compile/run `shell-v0`; stdin addr smoke.

```bash
bash lab/nano-lisp-jit/retired/scripts/nano-jit-shell-dual-smoke.sh
```

**Honest GAP**: C `release/nano-lisp.com` no-arg still prints usage (exit 2) — manifest pin unchanged. Rust `nanolisp.com` runs embedded shell. C **source** + host `cc` runner matches Rust no-arg via embed file or compile-run fallback.

## Roadmap

| Phase | Deliverable | Status |
|-------|-------------|--------|
| 0 | `shell-v0-system.lisp` + smoke + CLI parity | ✅ |
| 1 | `shell-script.lisp` + `nanolisp shell` | ✅ |
| 2 | `shell-repl` — VM read-line REPL (`nano:read-line`) | ✅ |
| 3 | `$COM` no-arg → built-in `shell.lbin` | ✅ Rust · ✅ C source · ⬜ C release promote |
| 4 | wave/ci scripts → shell plans only | ✅ |
| 6 | dual-track shell (C+Rust compile/run) + `addr` stdin | ✅ |
| 7 | C release rebake + dual-gate no-arg parity | ⬜ cosmocc promote |

## Integration into `.com`

1. Prove commands in `shell/*.lisp` + gate smoke. ✅ (Rust)
2. AOT or compose module into runner slice (15-link / factory). ⬜ (C release)
3. `main` dispatch: `argc==1` → `run shell.lbin`; else existing subcommands. ✅ Rust · ✅ C source · ⬜ C release pin

See also: [`PRODUCT-TRACKS.md`](PRODUCT-TRACKS.md) · [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md)
