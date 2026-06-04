# Shell runner — practice ladder

**Goal**: `.com` becomes a Lisp-native shell runner — dogfood in `shell/*.lisp`, then embed in release COM.

**Retrospective (Ph 0–7 proof, dual-track GAP, % rubric)**: [`SHELL-REFLECTION.md`](SHELL-REFLECTION.md)

## Capability layers

| Layer | API | C COM | Rust `nanolisp` |
|-------|-----|-------|-----------------|
| CLI | `spawn-wait` / `read-file` | ✅ | ✅ (Phase 0) |
| bootstrap | `(spawn-wait …)` / `(read-file …)` | ✅ | ✅ |
| `.lbin` VM | `libc:system` / `strlen` / … | ✅ | ✅ |
| `.lbin` addr | `libc:stdin` addr resolve | ✅ (pin) | ✅ |
| `.lbin` fgets | `libc:fgets` + stdin addr | ⬜ | ✅ Phase 7 |
| `.lbin` fgets REPL | `shell-repl-fgets.lisp` loop | ⬜ | ✅ Phase 7 alt |
| no-arg dispatch | `$COM` → embedded shell | ❌ release · ✅ source | ✅ Phase 3 |

## Phase 0 (baseline)

**`lisp/shell/shell-v0-system.lisp`** — compile → run → `libc:system("echo …")`.

```bash
RS=lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp
$RS compile lab/nano-lisp-jit/lisp/shell/shell-v0-system.lisp /tmp/s.lbin
$RS run /tmp/s.lbin
```

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-v0-smoke.sh`

## Phase 1 — multi-command script

**`lisp/shell/shell-script.lisp`** — chained `libc:system` (3 steps).

```bash
$RS shell              # compile+run shell-script.lisp
$RS shell-repl         # VM read-line REPL (.lbin loop)
```

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-script-smoke.sh`

## Phase 2 — VM read-line REPL

**`nano:read-line`** — `i32(ptr,i32)` FFI shim; **`shell-repl.lisp`** REPL loop in VM.

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-repl-vm-smoke.sh`

## Phase 3 — no-arg shell dispatch

**Rust**: `embed/shell-script.lbin` baked in; `$COM` with no args runs it.

**C source**: `nano_main.c` → `cmd_shell_noarg` (embed file / compile-run fallback).

```bash
$RS                        # embedded shell.lbin
$COM                       # C release: usage exit 2 until cosmocc promote
```

**Smokes**: `nano-jit-rs-shell-noarg-smoke.sh` · `nano-jit-c-shell-noarg-smoke.sh`

**Bootstrap**: `bootstrap-v45-shell-c-noarg.lisp`

| Artifact | `argc==1` | Testable |
|----------|-----------|----------|
| Rust `nanolisp.com` (release) | embedded shell | ✅ |
| C source + host `cc` | embed / compile-run | ✅ |
| C `release/nano-lisp.com` (pin) | usage exit 2 | ✅ GAP smoke |

## Phase 7 — libc fgets (stdin addr)

**`ptr(ptr,i32,ptr)`** — `OP_CALL_IMPORT_CONST_IMM_PTR`; third arg is resolved `libc:stdin` addr.

**`shell-fgets-smoke.lisp`** — resolve stdin, `fgets` into buf, piped stdin.

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-fgets-smoke.sh`

**GAP**: C COM parity for fgets opcode not ported.

## Phase 7 alt — fgets REPL loop

**`shell-repl-fgets.lisp`** — VM loop: stdin addr + `libc:fgets` + `libc:system` (alternative to Phase 2 `nano:read-line` REPL).

```bash
$RS compile lab/nano-lisp-jit/lisp/shell/shell-repl-fgets.lisp /tmp/rf.lbin
printf '%s\n' 'echo nanolisp-shell-repl-fgets' | $RS run /tmp/rf.lbin
```

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-repl-fgets-smoke.sh` (rs-gate + dual bootstrap + shell-ci plan).

## Phase 4 — shell CI plan

**`bootstrap-v45-shell-ci.lisp`** + **`nanolisp shell-ci`**

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-ci-smoke.sh`

**Phase 7b (C track in plan)**: embed `cmp` vs rs, `$COM` spawn-wait, no-arg `exit 2` (or `shell.mode=` when probe reports promote), COM compile/run `shell-script.lisp`. Smoke sources `nanolisp-c-release-shell-probe.sh` for conditional C no-arg assert (~28 steps).

## Phase 6 — dual-track shell

**`bootstrap-v45-shell-dual.lisp`** — Rust + C compile/run shell-v0; stdin + fgets; C release no-arg GAP step.

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-shell-dual-smoke.sh`

## Phase 8 — shell-full bootstrap

**`bootstrap-v45-shell-full.lisp`** — shell-ci essentials + dual C/Rust proc I/O + stdin/fgets + C no-arg pin in one plan (~29 steps).

```bash
RS=lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp
$RS run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-full.lisp
```

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-full-smoke.sh` (rs-gate; greps `nanolisp-shell-full-*`, `shell.mode=embedded-lbin`, C `spawn-wait` exit 2).

## C release shell auto-probe (P2)

**`retired/scripts/nanolisp-c-release-shell-probe.sh`** — run pinned `$COM` with no args; sets `NANO_C_RELEASE_HAS_SHELL` to `1` (`shell.mode=`) or `0` (`usage:` exit 2). Sourced by shell-ci, dual, and promote smokes; override with `export NANO_C_RELEASE_HAS_SHELL=0|1` before source.

```bash
bash lab/nano-lisp-jit/retired/scripts/nanolisp-c-release-shell-probe.sh
# nanolisp.c-release-shell=gap|embedded
```

## Dual gate (shell audit markers)

`bash lab/nano-lisp-jit/retired/scripts/nanolisp-dual-gate.sh` runs C then Rust product gates. Shell regression is **not** invoked again at the dual-gate layer; log lines `nanolisp.dual-gate.shell=*` document nested smokes:

| Track | Gate script | Shell smokes |
|-------|-------------|--------------|
| C | `nano-jit-c-gate.sh` | `nano-jit-c-shell-noarg-smoke.sh` |
| Rust | `nano-jit-rs-gate.sh` | `nano-jit-rs-shell-ci-smoke.sh`, `nano-jit-rs-shell-full-smoke.sh`, `nano-jit-rs-shell-repl-vm-smoke.sh`, `nano-jit-shell-dual-smoke.sh`, `nano-jit-rs-shell-fgets-smoke.sh`, `nano-jit-rs-shell-repl-fgets-smoke.sh` |

## Roadmap

| Phase | Deliverable | Status |
|-------|-------------|--------|
| 0–2 | v0 / script / VM REPL | ✅ |
| 3 | no-arg embed | ✅ Rust · ✅ C source · ⬜ C release |
| 4 | shell-ci bootstrap plan | ✅ |
| 6 | dual-track compile/run | ✅ |
| 7 | libc fgets via stdin addr | ✅ Rust |
| 7 alt | fgets REPL (`shell-repl-fgets`) | ✅ rs-gate · shell-ci · dual plan |
| 7b | C embed + shell-ci C track | ✅ plan + probe-conditional assert |
| 8 | shell-full bootstrap (`bootstrap-v45-shell-full.lisp`) | ✅ rs-gate (~29 steps) |
| 9 | C release rebake + factory embed in pin | ⬜ cosmocc promote (product slice 58%) |

## C release shell promote (prep)

Source no-arg shell is gated (`nano-jit-c-shell-noarg-smoke.sh`); rebaking `release/nano-lisp.com` needs cosmocc. Run `bash lab/nano-lisp-jit/retired/scripts/nano-jit-c-shell-promote-smoke.sh` — sources auto-probe when `NANO_C_RELEASE_HAS_SHELL` unset; exits 0 with `skip cosmocc_missing` when the toolchain is absent, otherwise checks manifest parity and the release GAP without rewriting `manifest.txt`. Full regenesis is opt-in (`NANO_C_SHELL_PROMOTE_BUILD=1` → `build_nano_jit.sh`); after a green factory build, promote with `v45-manifest-pin.sh` (probe should then report `nanolisp.c-release-shell=embedded`).

## Integration into `.com`

1. Prove commands in `shell/*.lisp` + gate smoke. ✅ Rust
2. AOT or compose module into runner slice (15-link / factory). ⬜ C release
3. `main` dispatch `argc==1` → shell.lbin. ✅ Rust · ✅ C source · ⬜ C release pin

See also: [`SHELL-REFLECTION.md`](SHELL-REFLECTION.md) · [`PRODUCT-TRACKS.md`](PRODUCT-TRACKS.md) · [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md)
