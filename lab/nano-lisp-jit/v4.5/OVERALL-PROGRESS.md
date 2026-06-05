# Overall progress — nanolisp commercial SOTA

**Updated**: 2026-06-05 · Wave 7 shell closure (scoped **100%** ladder). SSOT: [`SHELL-CLOSURE.md`](SHELL-CLOSURE.md) · [`SHELL-REFLECTION.md`](SHELL-REFLECTION.md).

## Executive summary

| Track | Overall | Gate | Release artifact |
|-------|---------|------|------------------|
| **C `nano-lisp.com`** | **95%** shipping-ready | `nanolisp.c-gate=ok` | **863 001 B** · wave SSOT (Wave 6 shell promote pin) |
| **Rust `nanolisp.com`** | **99%** feature parity | `nanolisp.gate=ok` | **3 000 373 B** · full CLI APE |
| **Rust slim pathfinder** | **40%** | slim smoke | `nanolisp-slim.com` ~161 KiB (genesis-pin pack) |
| **Migration (Rust replaces C)** | **~86%** | dual gate | C maintained until slim + parity; shell embed **done** on C pin (863 001 B) |
| **Shell runner ladder** | **100% scoped** | nested dual-gate + shell-ci + shell-full + release promote + probe | Ph 0–9 · [`SHELL-CLOSURE.md`](SHELL-CLOSURE.md); product shell slice **~85%** |

**Dual gate (both tracks)**:

```bash
bash lab/nano-lisp-jit/retired/scripts/nanolisp-dual-gate.sh
```

## Rust component parity (~99%)

| Area | % | Notes |
|------|---|-------|
| VM / `.lbin` run | 100% | 21/21 module compile hash parity |
| APE pack / inspect / run-ape | 90% | v2 memfd; full CLI slices |
| x86_64 AOT + compose-15link | 95% | semantic 8k→154k + hybrid + genesis-pin |
| aarch64 build-slice-lisp | 85% | VM/AOT pure-blob; compose-15link still x86-only |
| bootstrap-plan DSL | 99% | build-slice / compose15 / proc-io / pack-ape |
| nano-cc build-slice | 90% | `build_slice_use_nano_cc` ported |
| NLCap v0 | 90% | multi-tier + abin |
| Release promote | 85% | full + slim genesis pack |

## C track (~95%)

| Area | % | Notes |
|------|---|-------|
| Wave convergence / factory | 95% | v45-wave chain through factory-build-lisp-only |
| Release pin / manifest | 100% | `nano-jit-c-gate` manifest parity |
| 158KB runner | 90% | host `cc` lispjit.c · genesis-pin 155648B |
| Pure Lisp 158KB codegen | **0%** | honest GAP — still host cc or pin copy |

## Honest remaining GAP (priority)

1. **Rust release slim → C parity** — genesis slim ~161 KiB vs C 327 KiB (166592×2); need compose/build-slice slices not pin-only
2. **158KB pure Lisp codegen** — both tracks still depend on host `cc` or pin for full runner
3. **aarch64 compose-15link** — Rust `build_compose_15link` x86-only
4. **Wave scripts default COM** — still `nano-lisp.com`; Rust not wave SSOT yet
5. **Shell product SOTA** — user daily COM-only + slim Rust ≈ C COM size (**~85%** product shell slice; ladder **100% scoped** per [`SHELL-CLOSURE.md`](SHELL-CLOSURE.md))

## Milestone checklist

- [x] PRODUCT-TRACKS + dual gate
- [x] C gate (`nano-jit-c-gate.sh`)
- [x] Rust gate (`nano-jit-rs-gate.sh`) — 20 unit tests
- [x] compose-15link build-slice + semantic + hybrid + genesis-pin
- [x] aarch64 VM/AOT build-slice-lisp (min/ir pure-blob)
- [x] nano_cc build-slice path
- [x] `nanolisp-slim.com` genesis-pin release pathfinder
- [x] shell-v0 — `libc:system` .lbin + CLI `spawn-wait`/`read-file`
- [x] shell Phase 1 — `shell-script.lisp` + `nanolisp shell` / `shell-repl` + bootstrap chain
- [x] shell Phase 3 — no-arg → embedded `shell-script.lbin` in APE
- [x] shell Phase 4 — `bootstrap-v45-shell-ci.lisp` + `nanolisp shell-ci`
- [x] shell Phase 5 — VM `nano:read-line` + `shell-repl.lisp`
- [x] shell Phase 6 — dual-track bootstrap + `libc:stdin` addr FFI
- [x] shell Phase 7 — VM `libc:fgets` via stdin addr — Rust + C host-cc (`nano-jit-c-shell-fgets-smoke.sh`)
- [x] shell Phase 7 alt — `shell-repl-fgets.lisp` + smoke (shell-ci + dual bootstrap)
- [x] shell Phase 7b source — C `cmd_shell_noarg` + `archive/c/embed/shell-script.lbin` (host-cc embedded-lbin)
- [x] shell Phase 7b release — C `nano-lisp.com` factory embed + manifest rebake (`nano-jit-c-shell-release-promote.sh` → `v45-manifest-pin.sh`)
- [x] shell-ci extension — fgets + repl-fgets + Phase 7b C track (~28 steps)
- [x] C release shell auto-probe — `nanolisp-c-release-shell-probe.sh` (P2 ~done)
- [x] shell Phase 8 — `bootstrap-v45-shell-full.lisp` + `nano-jit-rs-shell-full-smoke.sh` (~29 steps, rs-gate)
- [x] shell Phase 8 C CLI — shell-full entry on C COM / `run-bootstrap-plan` (Wave 4)
- [x] shell Phase 9 — `bootstrap-v45-shell-promote.lisp` + gate readonly promote wiring (Wave 5–6)
- [x] shell P0 Wave 6 — `nano-jit-c-shell-release-promote.sh` + `v45-manifest-pin.sh` (product shell **~85%**)
- [x] shell Wave 7 closure — [`SHELL-CLOSURE.md`](SHELL-CLOSURE.md) scoped **100%** ladder lock
- [x] shell smokes in `nanolisp-dual-gate.sh` (c: shell-noarg · rs: shell-ci/shell-full/repl-vm/shell-dual/fgets/repl-fgets)
- [ ] Rust APE size ≈ C COM with runnable full CLI
- [ ] C/Rust zero host-cc 158KB codegen
- [ ] v45-wave default → `nanolisp.com`
