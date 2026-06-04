# Shell runner — practice ladder

**Goal**: `.com` becomes a Lisp-native shell runner — dogfood in `shell/*.lisp`, then embed in release COM.

**Retrospective (Ph 0–8, Wave 4 prep, dual-track GAP, % rubric)**: [`SHELL-REFLECTION.md`](SHELL-REFLECTION.md)

## Capability layers

| Layer | API | C COM | Rust `nanolisp` |
|-------|-----|-------|-----------------|
| CLI | `spawn-wait` / `read-file` | ✅ | ✅ (Phase 0) |
| bootstrap | `(spawn-wait …)` / `(read-file …)` | ✅ | ✅ |
| `.lbin` VM | `libc:system` / `strlen` / … | ✅ | ✅ |
| `.lbin` addr | `libc:stdin` addr resolve | ✅ (pin) | ✅ |
| `.lbin` fgets | `libc:fgets` + stdin addr | ⬜ Wave 4 opcode | ✅ Phase 7 |
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

**GAP**: C COM parity for fgets opcode — **Wave 4** planned (`OP_CALL_IMPORT_CONST_IMM_PTR` + stdin addr; c-gate smoke TBD).

| Track | Phase 7 fgets |
|-------|----------------|
| Rust | ✅ `nano-jit-rs-shell-fgets-smoke.sh` |
| C COM | ⬜ Wave 4 — port VM opcode + extend shell-ci / dual C steps |

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

**shell-full CLI note (Wave 4)**: Rust daily path is `run-bootstrap-plan` on the plan above (no dedicated `nanolisp shell-full` subcommand required — smoke drives the ladder). C track has no equivalent one-shot CLI yet; Wave 4 adds a COM dispatch or documents `$COM run-bootstrap-plan …/bootstrap-v45-shell-full.lisp` parity so dual-gate can audit a C shell-full marker alongside rs-gate.

## Phase 9 — shell-promote bootstrap

**`bootstrap-v45-shell-promote.lisp`** — promote ladder: embed `cmp`, spawn-wait `bootstrap-v45-shell-c-noarg.lisp`, shell-ci subset (hash-match + `nanolisp shell`), probe-friendly C COM no-arg exit 2, COM compile/run `shell-script.lisp`. Host-cc and cosmocc rebake stay external (`nano-jit-c-shell-promote-smoke.sh`, manual `v45-manifest-pin.sh`).

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
| 3 | no-arg embed | ✅ Rust · ✅ C source · ⬜ C release |
| 4 | shell-ci bootstrap plan | ✅ |
| 6 | dual-track compile/run | ✅ |
| 7 | libc fgets via stdin addr | ✅ Rust · ⬜ C opcode (Wave 4) |
| 7 alt | fgets REPL (`shell-repl-fgets`) | ✅ rs-gate · shell-ci · dual plan |
| 7b | C embed + shell-ci C track | ✅ plan + probe-conditional assert |
| 8 | shell-full bootstrap (`bootstrap-v45-shell-full.lisp`) | ✅ rs-gate (~29 steps) |
| 8b | shell-full C CLI / COM plan driver | ⬜ Wave 4 |
| 9 | shell-promote bootstrap (`bootstrap-v45-shell-promote.lisp`) | ✅ rs-gate (~12 steps; host-cc/cosmocc external) |

## C release shell promote (prep)

**Host-cc proves factory source; release pin still blocks product.**

| Step | Command / artifact | Proves |
|------|-------------------|--------|
| 1 | `nano-jit-c-shell-noarg-smoke.sh` (host `cc` runner) | `cmd_shell_noarg` + `archive/c/embed/shell-script.lbin` → `shell.mode=embedded-lbin` |
| 2 | `nano-jit-c-shell-promote-smoke.sh` | cosmocc absent: host `cc` factory (`embedded-lbin`); cosmocc present: manifest parity + release GAP/embedded (probe); never rewrites `manifest.txt` alone |
| 3 | `NANO_C_SHELL_PROMOTE_BUILD=1` on promote smoke | `build_nano_jit.sh` factory → `.build/nano-jit/nano-jit.com` with `shell.mode=` |
| 4 | `v45-manifest-pin.sh` (manual) | `release/nano-lisp.com` pin; probe → `nanolisp.c-release-shell=embedded`; product slice can move off 58% |

Run `bash lab/nano-lisp-jit/retired/scripts/nano-jit-c-shell-promote-smoke.sh` — without cosmocc it logs `skip cosmocc_missing` then still builds `.build/nano-lisp-jit-host-shell-noarg` and asserts no-arg `shell.mode=embedded-lbin` (same host path as step 1); with cosmocc it runs manifest parity and the release probe without touching the pin. Dual-gate runs promote prep (steps 1–2) by default; shipping waits on step 4.

### C release shell promote (heavy — optional)

**Not in default dual-gate** (cosmocc factory → `release/nano-lisp.com` + `v45-manifest-pin.sh`).

| Step | Command | When |
|------|---------|------|
| 5 | `bash lab/nano-lisp-jit/retired/scripts/nano-jit-c-shell-release-promote.sh` | Manual or `NANO_C_SHELL_RELEASE_PROMOTE=1` on dual-gate after promote_prep |
| 6 | Re-run `nanolisp-dual-gate.sh` | Confirm c-gate + rs-track green on new pin |

```bash
bash lab/nano-lisp-jit/retired/scripts/nano-jit-c-shell-release-promote.sh
NANO_C_SHELL_RELEASE_PROMOTE=1 bash lab/nano-lisp-jit/retired/scripts/nanolisp-dual-gate.sh
```

## Integration into `.com`

1. Prove commands in `shell/*.lisp` + gate smoke. ✅ Rust
2. AOT or compose module into runner slice (15-link / factory). ⬜ C release
3. `main` dispatch `argc==1` → shell.lbin. ✅ Rust · ✅ C source · ⬜ C release pin

See also: [`SHELL-REFLECTION.md`](SHELL-REFLECTION.md) · [`PRODUCT-TRACKS.md`](PRODUCT-TRACKS.md) · [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md)
