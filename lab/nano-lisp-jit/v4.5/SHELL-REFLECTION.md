# Shell runner — reflection (Phases 0–7 merged)

**Updated**: 2026-06-04 · Wave 2 reflection (post `nanolisp-shell-integrate`)  
**SSOT ladder**: [`SHELL-RUNNER.md`](SHELL-RUNNER.md) · **product tracks**: [`PRODUCT-TRACKS.md`](PRODUCT-TRACKS.md) · **rollup %**: [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md)

## Executive summary

Phases **0–7 (Rust)**, **Phase 7 alt** (`shell-repl-fgets`), **shell-ci Phase 7 extension** (fgets + repl-fgets, 22 steps), and **C source no-arg + file embed (7b)** are merged and gated. C **release** `nano-lisp.com` pin still `usage:` on no-arg until cosmocc promote.

**Honest overall**: **~90%** (see [percent rubric](#percent-rubric) below).

---

## What each phase proved

| Phase | Deliverable | What it proved |
|-------|-------------|----------------|
| **0** | `shell-v0-system.lisp` + `spawn-wait` / `read-file` CLI | Bootstrap proc I/O and VM `libc:system` path work on both tracks; `.lbin` is a viable shell seed. Smoke: `nano-jit-rs-shell-v0-smoke.sh`. |
| **1** | `shell-script.lisp` + `nanolisp shell` | Multi-step `libc:system` chain compiles and runs; dev CLI can compile+run fresh script without re-embedding. Smoke: `nano-jit-rs-shell-script-smoke.sh`. |
| **2** | `nano:read-line` + `shell-repl.lisp` | VM FFI shim (`i32(ptr,i32)`) + stdin-driven REPL loop; interactive path distinct from one-shot script. *(Some docs label this Phase 5 — same capability.)* Smoke: `nano-jit-rs-shell-repl-vm-smoke.sh`. |
| **3** | `$COM` no-arg → `embed/shell-script.lbin` | Rust binary embeds compile output; `argc==1` runs embedded `.lbin` (`shell.mode=embedded-lbin`). Hash-match in shell-ci proves embed freshness. Smoke: `nano-jit-rs-shell-noarg-smoke.sh`. |
| **4** | `bootstrap-v45-shell-ci.lisp` + `shell-ci` | Unified ladder (0→3 + read-line + REPL + **fgets + repl-fgets** + pack-ape, 22 steps). Smoke: `nano-jit-rs-shell-ci-smoke.sh`. |
| **5** | *(alias)* | Same as Phase 2 in section headers of [`SHELL-RUNNER.md`](SHELL-RUNNER.md); numbering debt only. |
| **6** | `bootstrap-v45-shell-dual.lisp` + dual smoke | C and Rust both compile/run `shell-v0`; stdin addr + fgets on Rust. |
| **7** | `libc:fgets` via stdin addr | Rust VM `ptr(ptr,i32,ptr)`; smoke: `nano-jit-rs-shell-fgets-smoke.sh`. C opcode parity pending. |
| **7 alt** | `shell-repl-fgets.lisp` | VM REPL on **fgets + stdin addr**; in shell-ci, dual bootstrap, rs-gate smoke. |
| **7b** | C `nano_main.c` no-arg + file embed | Source `cmd_shell_noarg`; `archive/c/embed/shell-script.lbin` (280 B, hash-match rs embed); host-cc `shell.mode=embedded-lbin`. Release COM pin unchanged. Smoke: `nano-jit-c-shell-noarg-smoke.sh`. Promote prep: `nano-jit-c-shell-promote-smoke.sh` (skip if no cosmocc). |

**Still open**: C release rebake (factory embed in COM blob), dual-smoke flip when pinned C COM ships shell UX, C fgets opcode parity.

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
| Gate inclusion | **c-gate** → `nano-jit-c-shell-noarg-smoke.sh` | **rs-gate** → shell-ci, repl-vm, dual, fgets, **repl-fgets** |
| Dual-gate (`nanolisp-dual-gate.sh`) | ✅ nested via c-gate · audit `nanolisp.dual-gate.shell=c-track *` | ✅ nested via rs-gate · audit `nanolisp.dual-gate.shell=rs-track *` (incl. repl-fgets) |

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

## Percent rubric (~90%)

| Slice | % | Rationale |
|-------|---|-----------|
| Rust ladder proof (Ph 0–7, REPL, fgets, repl-fgets, shell-ci 22-step) | **98%** | All rs-gate smokes green; shell-ci includes fgets + repl-fgets |
| Dual-track parity (Ph 6–7, 7b source + file embed) | **85%** | Host-cc embedded-lbin; C release no-arg + fgets opcode gap |
| Product / release (slim COM, wave SSOT) | **58%** | No C embed in release pin; cosmocc promote pending |
| **Weighted overall** | **~90%** | 0.45×98 + 0.35×85 + 0.20×58 ≈ 90 |

---

## Recommended next 3 steps (priority)

| Priority | Item | Status |
|----------|------|--------|
| **P0** | C no-arg **release** embed — `nano-jit-c-shell-promote-smoke.sh` + cosmocc rebake; dual-smoke flip hook ready | ⬜ file embed + source done; promote skip (no cosmocc in CI) |
| **P1** | Gate wiring — shell regression on daily dual path | **✅ done** |
| **P2** | Release + docs convergence — conditional C COM assert when release ships | **partial** — dual-smoke `NANO_C_RELEASE_HAS_SHELL` hook; shell-ci still Rust-only no-arg assert |

---

## Wave 2 reflection (2026-06-04)

Post-integrate + wave-2 subagent merges:

| Item | Status |
|------|--------|
| **shell-ci Phase 7** | ✅ fgets + repl-fgets in plan (22 steps); smoke greps `piped-fgets-line`, `nanolisp-shell-ci-repl-fgets` |
| **C `archive/c/embed`** | ✅ `shell-script.lbin` 280 B; hash-match rs embed; host-cc no-arg → `shell.mode=embedded-lbin` |
| **C promote prep** | ✅ `nano-jit-c-shell-promote-smoke.sh` (skip cosmocc_missing); dual-smoke flip hook |
| **P0 / P1 / P2** | P0 cosmocc promote · P1 gate **done** · P2 conditional assert **partial** |

---

## Related

- [`SHELL-RUNNER.md`](SHELL-RUNNER.md) — commands, smokes, roadmap table
- [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md) — cross-track % rollup
- [`REFLECTION.md`](REFLECTION.md) — v4.5 wave narrative (wave60/67 shell-retire is CI infra, not this ladder)
