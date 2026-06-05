# Shell runner — practice ladder

**Goal**: `.com` becomes a Lisp-native shell runner — dogfood in `shell/*.lisp`, then embed in release COM.

**Retrospective (Ph 0–9, Wave 7 closure)**: [`SHELL-REFLECTION.md`](SHELL-REFLECTION.md) · **scoped 100%**: [`SHELL-CLOSURE.md`](SHELL-CLOSURE.md)

## Capability layers

| Layer | API | C COM | Rust `nanolisp` |
|-------|-----|-------|-----------------|
| CLI | `spawn-wait` / `read-file` | ✅ | ✅ (Phase 0) |
| bootstrap | `(spawn-wait …)` / `(read-file …)` | ✅ | ✅ |
| `.lbin` VM | `libc:system` / `strlen` / … | ✅ | ✅ |
| `.lbin` addr | `libc:stdin` addr resolve | ✅ (pin) | ✅ |
| `.lbin` fgets | `libc:fgets` + stdin addr | ✅ Phase 7 (`nano-jit-c-shell-fgets-smoke.sh`) | ✅ Phase 7 |
| `.lbin` fgets REPL | `shell-repl-fgets.lisp` loop | ⬜ | ✅ Phase 7 alt |
| no-arg dispatch | `$COM` → embedded shell | ✅ release (Wave 6 pin) · ✅ source | ✅ Phase 3 |

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
$COM                       # C release: embedded shell (Wave 6 promote)
```

**Smokes**: `nano-jit-rs-shell-noarg-smoke.sh` · `nano-jit-c-shell-noarg-smoke.sh`

**Bootstrap**: `bootstrap-v45-shell-c-noarg.lisp`

| Artifact | `argc==1` | Testable |
|----------|-----------|----------|
| Rust `nanolisp.com` (release) | embedded shell | ✅ |
| C source + host `cc` | embed / compile-run | ✅ |
| C `release/nano-lisp.com` (pin) | embedded shell | ✅ probe + dual-smoke |

## Phase 7 — libc fgets (stdin addr)

**`ptr(ptr,i32,ptr)`** — `OP_CALL_IMPORT_CONST_IMM_PTR`; third arg is resolved `libc:stdin` addr.

**`shell-fgets-smoke.lisp`** — resolve stdin, `fgets` into buf, piped stdin.

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-fgets-smoke.sh`

**C track**: `nano-jit-c-shell-fgets-smoke.sh` (c-gate); opcode in pinned COM after Wave 6 promote.

| Track | Phase 7 fgets |
|-------|----------------|
| Rust | ✅ `nano-jit-rs-shell-fgets-smoke.sh` |
| C COM | ✅ `nano-jit-c-shell-fgets-smoke.sh` |

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

**Phase 7b (C track in plan)**: embed `cmp` vs rs, `$COM` spawn-wait, no-arg `shell.mode=embedded-lbin` (Wave 6 pin), COM compile/run `shell-script.lisp`. Smoke sources `nanolisp-c-release-shell-probe.sh` (~28 steps).

## Phase 6 — dual-track shell

**`bootstrap-v45-shell-dual.lisp`** — Rust + C compile/run shell-v0; stdin + fgets; C release no-arg embedded-lbin (Wave 6).

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-shell-dual-smoke.sh`

## Phase 8 — shell-full bootstrap

**`bootstrap-v45-shell-full.lisp`** — shell-ci essentials + dual C/Rust proc I/O + stdin/fgets + C no-arg pin in one plan (~29 steps).

```bash
RS=lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp
$RS run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-full.lisp
```

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-full-smoke.sh` (rs-gate; greps `nanolisp-shell-full-*`, `shell.mode=embedded-lbin` on both tracks after Wave 6).

**shell-full CLI note (Wave 4)**: Rust daily path is `run-bootstrap-plan` on the plan above (no dedicated `nanolisp shell-full` subcommand required — smoke drives the ladder). C track: pinned **`release/nano-lisp.com`** (**863 001 B**, Wave 6); optional `$COM run-bootstrap-plan …/bootstrap-v45-shell-full.lisp` parity — dedicated C `shell-full` subcommand still **⬜** (see [`SHELL-CLOSURE.md`](SHELL-CLOSURE.md)).

## Phase 9 — shell-promote bootstrap

**`bootstrap-v45-shell-promote.lisp`** — promote ladder: embed `cmp`, spawn-wait `bootstrap-v45-shell-c-noarg.lisp`, shell-ci subset, C COM no-arg `shell.mode=` (post–Wave 6 pin), COM compile/run `shell-script.lisp`. Cosmocc rebake + pin: `nano-jit-c-shell-release-promote.sh`.

```bash
RS=lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp
$RS run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-promote.lisp
```

**Smoke**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-promote-smoke.sh` (rs-gate after shell-full; greps `bootstrap-plan.ok=1`).

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
| C | `nano-jit-c-gate.sh` | `nano-jit-c-shell-noarg-smoke.sh`, `nano-jit-c-shell-fgets-smoke.sh`; dual-gate adds `nano-jit-c-shell-promote-smoke.sh` (prep). Optional: `nano-jit-c-shell-release-promote.sh` when `NANO_C_SHELL_RELEASE_PROMOTE=1` |
| Rust | `nano-jit-rs-gate.sh` | `nano-jit-rs-shell-ci-smoke.sh`, `nano-jit-rs-shell-full-smoke.sh`, `nano-jit-rs-shell-promote-smoke.sh`, `nano-jit-rs-shell-repl-vm-smoke.sh`, `nano-jit-shell-dual-smoke.sh`, `nano-jit-rs-shell-fgets-smoke.sh`, `nano-jit-rs-shell-repl-fgets-smoke.sh` |

## Roadmap

| Phase | Deliverable | Status |
|-------|-------------|--------|
| 0–2 | v0 / script / VM REPL | ✅ |
| 3 | no-arg embed | ✅ Rust · ✅ C source · ✅ C release (Wave 6) |
| 4 | shell-ci bootstrap plan | ✅ |
| 6 | dual-track compile/run | ✅ |
| 7 | libc fgets via stdin addr | ✅ Rust · ✅ C COM |
| 7 alt | fgets REPL (`shell-repl-fgets`) | ✅ rs-gate · shell-ci · dual plan |
| 7b | C embed + shell-ci C track | ✅ plan + probe-conditional assert |
| 8 | shell-full bootstrap (`bootstrap-v45-shell-full.lisp`) | ✅ rs-gate (~29 steps) |
| 8b | shell-full C CLI / COM plan driver | ⬜ Wave 4 |
| 9 | shell-promote bootstrap (`bootstrap-v45-shell-promote.lisp`) | ✅ rs-gate (~12 steps; host-cc/cosmocc external) |

## C release shell promote (Wave 6)

**Orchestrator**: `nano-jit-c-shell-release-promote.sh` — cosmocc bootstrap → factory build → install `release/nano-lisp.com` → **`v45-manifest-pin.sh`** → probe `embedded` → c-gate.

```bash
bash lab/nano-lisp-jit/retired/scripts/nano-jit-c-shell-release-promote.sh
```

| Step | Command / artifact | Proves |
|------|-------------------|--------|
| 0 | `bootstrap-cosmocc.sh` (inside orchestrator) | `third_party/cosmocc/bin/x86_64-unknown-cosmo-cc` |
| 1 | `require_cosmocc` + `NANO_C_GATE_FACTORY=1 build_nano_jit.sh` | factory `.build/nano-jit/nano-jit.com` → `shell.mode=embedded-lbin` |
| 2 | `install` factory → `release/nano-lisp.com` | release bytes updated (not gate-auto) |
| 3 | `v45-manifest-pin.sh "$RELEASE_COM"` | `manifest.txt` parity with new pin |
| 4 | `nanolisp-c-release-shell-probe.sh` | `nanolisp.c-release-shell=embedded` |
| 5 | `nano-jit-c-gate.sh` | manifest parity + smokes green on new pin |

**Prep** (dual-gate default): `bash lab/nano-lisp-jit/retired/scripts/nano-jit-c-shell-promote-smoke.sh` — host-cc when cosmocc missing; manifest parity + probe when present (no release write).

**Heavy promote** (manual or `NANO_C_SHELL_RELEASE_PROMOTE=1` on dual-gate):

```bash
bash lab/nano-lisp-jit/retired/scripts/nano-jit-c-shell-release-promote.sh
NANO_C_SHELL_RELEASE_PROMOTE=1 bash lab/nano-lisp-jit/retired/scripts/nanolisp-dual-gate.sh
```

## Integration into `.com`

1. Prove commands in `shell/*.lisp` + gate smoke. ✅ Rust · ✅ C
2. AOT or compose module into runner slice (15-link / factory). ✅ C release (Wave 6 pin)
3. `main` dispatch `argc==1` → shell.lbin. ✅ Rust · ✅ C source · ✅ C release pin

See also: [`SHELL-CLOSURE.md`](SHELL-CLOSURE.md) · [`SHELL-REFLECTION.md`](SHELL-REFLECTION.md) · [`PRODUCT-TRACKS.md`](PRODUCT-TRACKS.md) · [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md)
