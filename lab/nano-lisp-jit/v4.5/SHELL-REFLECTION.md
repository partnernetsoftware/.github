# Shell runner — reflection (Phases 0–7 merged)

**Updated**: 2026-06-04 · Phases 0–7 Rust merged; C source no-arg wired  
**SSOT ladder**: [`SHELL-RUNNER.md`](SHELL-RUNNER.md) · **product tracks**: [`PRODUCT-TRACKS.md`](PRODUCT-TRACKS.md) · **rollup %**: [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md)

## Executive summary

Phases **0–7 (Rust)** and **C source no-arg (7b)** are merged and gated. C **release** `nano-lisp.com` pin still `usage:` on no-arg until cosmocc promote.

**Honest overall**: **~88%** (see [percent rubric](#percent-rubric) below).

---

## What each phase proved

| Phase | Deliverable | What it proved |
|-------|-------------|----------------|
| **0** | `shell-v0-system.lisp` + `spawn-wait` / `read-file` CLI | Bootstrap proc I/O and VM `libc:system` path work on both tracks; `.lbin` is a viable shell seed. Smoke: `nano-jit-rs-shell-v0-smoke.sh`. |
| **1** | `shell-script.lisp` + `nanolisp shell` | Multi-step `libc:system` chain compiles and runs; dev CLI can compile+run fresh script without re-embedding. Smoke: `nano-jit-rs-shell-script-smoke.sh`. |
| **2** | `nano:read-line` + `shell-repl.lisp` | VM FFI shim (`i32(ptr,i32)`) + stdin-driven REPL loop; interactive path distinct from one-shot script. *(Some docs label this Phase 5 — same capability.)* Smoke: `nano-jit-rs-shell-repl-vm-smoke.sh`. |
| **3** | `$COM` no-arg → `embed/shell-script.lbin` | Rust binary embeds compile output; `argc==1` runs embedded `.lbin` (`shell.mode=embedded-lbin`). Hash-match in shell-ci proves embed freshness. Smoke: `nano-jit-rs-shell-noarg-smoke.sh`. |
| **4** | `bootstrap-v45-shell-ci.lisp` + `shell-ci` | Unified ladder (0→3 + read-line + REPL + pack-ape) as **one bootstrap plan** — onion TDD replacement for per-phase `.sh` smokes. Smoke: `nano-jit-rs-shell-ci-smoke.sh`. |
| **5** | *(alias)* | Same as Phase 2 in section headers of [`SHELL-RUNNER.md`](SHELL-RUNNER.md); numbering debt only. |
| **6** | `bootstrap-v45-shell-dual.lisp` + dual smoke | C and Rust both compile/run `shell-v0`; stdin addr + fgets on Rust. |
| **7** | `libc:fgets` via stdin addr | Rust VM `ptr(ptr,i32,ptr)`; smoke: `nano-jit-rs-shell-fgets-smoke.sh`. C opcode parity pending. |
| **7b** | C `nano_main.c` no-arg | Source `cmd_shell_noarg` wired; host-cc path green; release COM pin unchanged until promote. Smoke: `nano-jit-c-shell-noarg-smoke.sh` (in `nano-jit-c-gate.sh`). |

**Still open**: C release rebake (`nano-lisp.com` no-arg embed), factory embed slice, dual-smoke expectation flip when C COM ships shell UX.

---

## Dual-track honest GAP

| Capability | C `nano-lisp.com` (wave SSOT) | Rust `nanolisp.com` (parity candidate) |
|------------|-------------------------------|----------------------------------------|
| CLI `spawn-wait` / `read-file` | ✅ | ✅ |
| `.lbin` `libc:system` compile/run | ✅ | ✅ |
| `nanolisp shell` / `shell-repl` / `shell-ci` subcommands | ❌ (C CLI differs) | ✅ |
| No-arg `$COM` → shell | ❌ **release** `usage:` exit 2 · ✅ **source** `cmd_shell_noarg` | ✅ embedded `shell-script.lbin` |
| `libc:stdin` addr in VM | ✅ (pinned release) | ✅ |
| `libc:fgets` via stdin addr | ⬜ opcode parity pending | ✅ Phase 7 |
| Dual bootstrap plan | ✅ compile/run v0 via C COM | ✅ plan driver on Rust |
| Gate inclusion | **c-gate** → `nano-jit-c-shell-noarg-smoke.sh` | **rs-gate** → shell-ci, repl, dual, fgets |
| Dual-gate (`nanolisp-dual-gate.sh`) | ✅ nested via c-gate | ✅ nested via rs-gate (incl. `nano-jit-shell-dual-smoke.sh`) |

The dual smoke **expects** release asymmetry today: Rust no-arg must print `shell.mode=embedded-lbin`; pinned C COM no-arg must print `usage:` (`nano-jit-shell-dual-smoke.sh` lines 37–48). Host-cc C runner can satisfy `cmd_shell_noarg` — documented in `nano-jit-c-shell-noarg-smoke.sh`. That is honest regression coverage, not full release parity.

---

## What “done” means vs product SOTA

| Criterion | Practice ladder (Ph 0–7) | Product SOTA |
|-----------|--------------------------|--------------|
| Lisp shell dogfood in `lisp/shell/` | ✅ | ✅ |
| Bootstrap plans replace granular smokes | ✅ shell-ci | ✅ nested in dual-gate (via track gates) |
| `$COM` no-arg is a shell | ✅ Rust · ✅ C source | ⬜ C wave SSOT release still `usage:` |
| Slim COM (~327 KiB) carries shell | N/A (Rust ~2.8 MiB full) | ⬜ embed not in C release pin |
| Wave scripts default COM | C `nano-lisp.com` | ⬜ unchanged |
| User daily = COM + plan only | ✅ for shell-ci path | ⬜ factory regenesis for C embed pending |

**Done for engineering proof** ≠ **done for shipping**: wave SSOT and pinned `manifest.txt` still describe a C COM without no-arg shell dispatch on the **release** artifact. Rust release promote proves the UX on the candidate artifact only.

---

## Percent rubric (~88%)

| Slice | % | Rationale |
|-------|---|-----------|
| Rust ladder proof (Ph 0–7, REPL, fgets) | **96%** | All rs-gate smokes green; embed hash-match in shell-ci |
| Dual-track parity (Ph 6–7, 7b source) | **82%** | Compile/run parity; C release no-arg + fgets opcode gap; gates nested not standalone dual script |
| Product / release (slim COM, wave SSOT) | **58%** | No C embed in pin; factory rebake pending |
| **Weighted overall** | **~88%** | 0.45×96 + 0.35×82 + 0.20×58 ≈ 88 |

Previous **~82%** underweighted Phase 7 fgets and 7b source wiring; **~88%** keeps release/gate gaps explicit while crediting nested dual-gate coverage.

---

## Recommended next 3 steps (priority)

| Priority | Item | Status |
|----------|------|--------|
| **P0** | Phase 7: C no-arg **release** embed — rebake `nano-lisp.com`; dual smoke flips C expectation from `usage:` to shell marker | ⬜ source done (7b); promote pending |
| **P1** | Gate wiring — shell regression on daily dual path | **partial** — `nanolisp-dual-gate.sh` nests `nano-jit-c-gate.sh` (shell-noarg) + `nano-jit-rs-gate.sh` (shell-dual, fgets, shell-ci); no duplicate standalone shell block in dual-gate |
| **P2** | Release + docs convergence — manifest pin, PRODUCT-TRACKS shell row, shell-ci Phase 3 assert C COM no-arg when release ships | ⬜ after P0 promote |

---

## Related

- [`SHELL-RUNNER.md`](SHELL-RUNNER.md) — commands, smokes, roadmap table
- [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md) — cross-track % rollup
- [`REFLECTION.md`](REFLECTION.md) — v4.5 wave narrative (wave60/67 shell-retire is CI infra, not this ladder)
