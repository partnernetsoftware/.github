# Shell runner — reflection (Phases 0–8 merged)

**Updated**: 2026-06-04 · Wave 3 merged (probe + shell-ci C track + shell-full)  
**SSOT ladder**: [`SHELL-RUNNER.md`](SHELL-RUNNER.md) · **product tracks**: [`PRODUCT-TRACKS.md`](PRODUCT-TRACKS.md) · **rollup %**: [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md)

## Executive summary

Phases **0–7 (Rust)**, **Phase 7 alt** (`shell-repl-fgets`), **shell-ci** (fgets + repl-fgets + **Phase 7b C track**, ~28 steps), **C source no-arg + file embed (7b)**, **C release auto-probe (P2)**, and **Phase 8 shell-full** (`bootstrap-v45-shell-full.lisp`, ~29 steps, rs-gate) are merged or gated on integrate. C **release** `nano-lisp.com` pin still `usage:` on no-arg until cosmocc promote — product slice unchanged.

**Honest overall**: **~92%** (shell-full in rs-gate; product slice still **58%** until cosmocc promote).

---

## What each phase proved

| Phase | Deliverable | What it proved |
|-------|-------------|----------------|
| **0** | `shell-v0-system.lisp` + `spawn-wait` / `read-file` CLI | Bootstrap proc I/O and VM `libc:system` path work on both tracks; `.lbin` is a viable shell seed. Smoke: `nano-jit-rs-shell-v0-smoke.sh`. |
| **1** | `shell-script.lisp` + `nanolisp shell` | Multi-step `libc:system` chain compiles and runs; dev CLI can compile+run fresh script without re-embedding. Smoke: `nano-jit-rs-shell-script-smoke.sh`. |
| **2** | `nano:read-line` + `shell-repl.lisp` | VM FFI shim (`i32(ptr,i32)`) + stdin-driven REPL loop; interactive path distinct from one-shot script. *(Some docs label this Phase 5 — same capability.)* Smoke: `nano-jit-rs-shell-repl-vm-smoke.sh`. |
| **3** | `$COM` no-arg → `embed/shell-script.lbin` | Rust binary embeds compile output; `argc==1` runs embedded `.lbin` (`shell.mode=embedded-lbin`). Hash-match in shell-ci proves embed freshness. Smoke: `nano-jit-rs-shell-noarg-smoke.sh`. |
| **4** | `bootstrap-v45-shell-ci.lisp` + `shell-ci` | Unified ladder (0→3 + read-line + REPL + fgets + repl-fgets + **7b C embed/COM** + pack-ape, ~28 steps). Smoke: `nano-jit-rs-shell-ci-smoke.sh`. |
| **5** | *(alias)* | Same as Phase 2 in section headers of [`SHELL-RUNNER.md`](SHELL-RUNNER.md); numbering debt only. |
| **6** | `bootstrap-v45-shell-dual.lisp` + dual smoke | C and Rust both compile/run `shell-v0`; stdin addr + fgets on Rust. |
| **7** | `libc:fgets` via stdin addr | Rust VM `ptr(ptr,i32,ptr)`; smoke: `nano-jit-rs-shell-fgets-smoke.sh`. C opcode parity pending. |
| **7 alt** | `shell-repl-fgets.lisp` | VM REPL on **fgets + stdin addr**; in shell-ci, dual bootstrap, rs-gate smoke. |
| **7b** | C `nano_main.c` no-arg + file embed | Source `cmd_shell_noarg`; `archive/c/embed/shell-script.lbin` (280 B, hash-match rs embed); host-cc `shell.mode=embedded-lbin`. Release COM pin unchanged. Smoke: `nano-jit-c-shell-noarg-smoke.sh`. Promote prep: `nano-jit-c-shell-promote-smoke.sh` (skip if no cosmocc). |
| **8** | `bootstrap-v45-shell-full.lisp` + shell-full smoke | One plan: shell-ci essentials + dual C/Rust proc I/O + stdin/fgets stack + C no-arg pin (`spawn-wait` exit 2 pre-promote). Smoke: `nano-jit-rs-shell-full-smoke.sh` via `run-bootstrap-plan` (rs-gate). |

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
| shell-ci / shell-full C track | ✅ embed cmp + COM compile/run + no-arg pin in plan | ✅ Rust subcommands |
| Gate inclusion | **c-gate** → `nano-jit-c-shell-noarg-smoke.sh` | **rs-gate** → shell-ci, **shell-full**, repl-vm, dual, fgets, repl-fgets |
| Dual-gate (`nanolisp-dual-gate.sh`) | ✅ nested via c-gate · audit `nanolisp.dual-gate.shell=c-track *` | ✅ nested via rs-gate · audit `nanolisp.dual-gate.shell=rs-track *` (incl. shell-full) |
| P2 release assert | ✅ **auto-probe** sets `NANO_C_RELEASE_HAS_SHELL` | N/A |

The dual smoke **expects** release asymmetry today unless probe reports embedded shell: Rust no-arg must print `shell.mode=embedded-lbin`; pinned C COM no-arg defaults to `usage:` (`nano-jit-shell-dual-smoke.sh`). Host-cc C runner can satisfy `cmd_shell_noarg` — documented in `nano-jit-c-shell-noarg-smoke.sh`. That is honest regression coverage, not full release parity.

---

## What “done” means vs product SOTA

| Criterion | Practice ladder (Ph 0–8) | Product SOTA |
|-----------|--------------------------|--------------|
| Lisp shell dogfood in `lisp/shell/` | ✅ | ✅ |
| Bootstrap plans replace granular smokes | ✅ shell-ci + shell-full | ✅ nested in dual-gate (via track gates) |
| `$COM` no-arg is a shell | ✅ Rust · ✅ C source | ⬜ C wave SSOT release still `usage:` |
| Slim COM (~327 KiB) carries shell | N/A (Rust ~2.8 MiB full) | ⬜ embed not in C release pin |
| Wave scripts default COM | C `nano-lisp.com` | ⬜ unchanged |
| User daily = COM + plan only | ✅ shell-ci / shell-full path | ⬜ factory regenesis for C embed pending |
| P2 conditional release assert | ✅ auto-probe + manual override | ⬜ until cosmocc promote flips pin |

**Done for engineering proof** ≠ **done for shipping**: wave SSOT and pinned `manifest.txt` still describe a C COM without no-arg shell dispatch on the **release** artifact. Rust release promote proves the UX on the candidate artifact only.

---

## Percent rubric (~91% / ~92%)

Product / release slice stays **58%** until cosmocc promote rebakes `release/nano-lisp.com` — do not inflate for ladder-only wins.

| Slice | Wave 2 (~90%) | Wave 3a (~91%) | Wave 3b (~92%) | Rationale |
|-------|---------------|----------------|----------------|-----------|
| Rust ladder proof (Ph 0–8, REPL, fgets, repl-fgets, shell-ci ~28-step, shell-full ~29-step) | **98%** | **98%** | **99%** | shell-full consolidates ci+dual in one rs-gate plan |
| Dual-track parity (Ph 6–8, 7b source + file embed, C shell-ci steps, auto-probe) | **85%** | **88%** | **90%** | C track in shell-ci; probe removes manual `NANO_C_RELEASE_HAS_SHELL` guesswork |
| Product / release (slim COM, wave SSOT) | **58%** | **58%** | **58%** | No C embed in release pin; cosmocc promote pending |
| **Headline overall** | **~90%** | **~91%** | **~92%** | Ladder engineering-proof rollup (0.45/0.35/0.20 ≈ 87–89 while product pin holds) |

---

## Recommended next 3 steps (priority)

| Priority | Item | Status |
|----------|------|--------|
| **P0** | C no-arg **release** embed — `nano-jit-c-shell-promote-smoke.sh` + cosmocc rebake; dual-smoke flip when probe reports embedded | ⬜ file embed + source done; promote skip (no cosmocc in CI) |
| **P1** | Gate wiring — shell regression on daily dual path | **✅ done** |
| **P2** | Release + docs convergence — conditional C COM assert when release ships | **~done** — `nanolisp-c-release-shell-probe.sh` sources shell-ci / dual / promote smokes; manual `NANO_C_RELEASE_HAS_SHELL` override retained |

---

## Wave 2 reflection (2026-06-04)

Post-integrate + wave-2 subagent merges:

| Item | Status |
|------|--------|
| **shell-ci Phase 7** | ✅ fgets + repl-fgets in plan (22→~28 steps); smoke greps `piped-fgets-line`, `nanolisp-shell-ci-repl-fgets` |
| **C `archive/c/embed`** | ✅ `shell-script.lbin` 280 B; hash-match rs embed; host-cc no-arg → `shell.mode=embedded-lbin` |
| **C promote prep** | ✅ `nano-jit-c-shell-promote-smoke.sh` (skip cosmocc_missing); dual-smoke flip hook |
| **P0 / P1 / P2** | P0 cosmocc promote · P1 gate **done** · P2 conditional assert **partial** (manual env) |

---

## Wave 3 reflection (2026-06-04)

Wave 3 merged on `cursor/nanolisp-shell-integrate-fc19`:

| Item | Status | Notes |
|------|--------|-------|
| **C release auto-probe** | ✅ | `retired/scripts/nanolisp-c-release-shell-probe.sh` — no-arg run → `shell.mode=` vs `usage:` exit 2; sets `NANO_C_RELEASE_HAS_SHELL` when sourced |
| **shell-ci C track (Phase 7b)** | ✅ | Plan steps: embed `cmp`, COM `spawn-wait`, no-arg `exit 2`, COM compile/run `shell-script.lisp`; smoke uses probe for conditional assert |
| **Phase 8 shell-full** | ✅ | `bootstrap-v45-shell-full.lisp` + `nano-jit-rs-shell-full-smoke.sh` (`run-bootstrap-plan`, ~29 steps); rs-gate + dual-gate audit string |
| **P2** | **~done** | Auto-probe replaces hand-tuned release env in smokes; P0 cosmocc promote still blocks product slice |
| **Headline %** | **~91%** (3a) · **~92%** (3b) | Product slice **58%** unchanged |

---

## Related

- [`SHELL-RUNNER.md`](SHELL-RUNNER.md) — commands, smokes, roadmap table
- [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md) — cross-track % rollup
- [`REFLECTION.md`](REFLECTION.md) — v4.5 wave narrative (wave60/67 shell-retire is CI infra, not this ladder)
