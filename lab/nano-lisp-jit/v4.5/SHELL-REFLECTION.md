# Shell runner — reflection (Phases 0–6 merged)

**Updated**: 2026-06-04 · Phases 0–7 Rust merged; C source no-arg wired  
**SSOT ladder**: [`SHELL-RUNNER.md`](SHELL-RUNNER.md) · **product tracks**: [`PRODUCT-TRACKS.md`](PRODUCT-TRACKS.md) · **rollup %**: [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md)

## Executive summary

Phases **0–7 (Rust)** and **C source no-arg** are merged and gated. C **release** `nano-lisp.com` pin still usage-on-no-arg until cosmocc promote.

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
| **7** | `libc:fgets` via stdin addr | Rust VM `ptr(ptr,i32,ptr)`; C opcode parity pending. |
| **7b** | C `nano_main.c` no-arg | Source `cmd_shell_noarg`; release COM pin unchanged until promote. |

**Still open**: C release rebake, `nanolisp-dual-gate.sh` shell wiring, factory embed slice.

---

## Dual-track honest GAP

| Capability | C `nano-lisp.com` (wave SSOT) | Rust `nanolisp.com` (parity candidate) |
|------------|-------------------------------|----------------------------------------|
| CLI `spawn-wait` / `read-file` | ✅ | ✅ |
| `.lbin` `libc:system` compile/run | ✅ | ✅ |
| `nanolisp shell` / `shell-repl` / `shell-ci` subcommands | ❌ (C CLI differs) | ✅ |
| No-arg `$COM` → shell | ❌ **`usage:` exit 2** | ✅ embedded `shell-script.lbin` |
| `libc:stdin` addr in VM | ✅ (pinned release) | ✅ |
| Dual bootstrap plan | ✅ compile/run v0 via C COM | ✅ plan driver on Rust |
| Gate inclusion | C gate only | RS gate only; **shell-dual not in dual-gate** |

The dual smoke **expects** the asymmetry today: Rust no-arg must print `shell.mode=embedded-lbin`; C no-arg must print `usage:` (`nano-jit-shell-dual-smoke.sh` lines 37–48). That is honest regression coverage, not parity.

---

## What “done” means vs product SOTA

| Criterion | Practice ladder (Ph 0–6) | Product SOTA |
|-----------|--------------------------|--------------|
| Lisp shell dogfood in `lisp/shell/` | ✅ | ✅ |
| Bootstrap plans replace granular smokes | ✅ shell-ci | ⬜ shell-ci not in dual-gate |
| `$COM` no-arg is a shell | ✅ Rust only | ⬜ C wave SSOT still usage |
| Slim COM (~327 KiB) carries shell | N/A (Rust ~2.8 MiB full) | ⬜ embed not in C release pin |
| Wave scripts default COM | C `nano-lisp.com` | ⬜ unchanged |
| User daily = COM + plan only | ✅ for shell-ci path | ⬜ factory regenesis for C embed pending |

**Done for engineering proof** ≠ **done for shipping**: wave SSOT and pinned `manifest.txt` still describe a C COM without no-arg shell dispatch. Rust release promote proves the UX on the candidate artifact only.

---

## Percent rubric (~82%)

| Slice | % | Rationale |
|-------|---|-----------|
| Rust ladder proof (Ph 0–4, 2/5 REPL) | **95%** | All smokes green; embed hash-match in shell-ci |
| Dual-track parity (Ph 6) | **70%** | Compile/run parity; C no-arg + CLI subcommands missing |
| Product / release (slim COM, wave SSOT) | **55%** | No C embed; shell-dual outside dual-gate |
| **Weighted overall** | **~82%** | 0.45×95 + 0.35×70 + 0.20×55 ≈ 82 |

Previous **~85%** overweighted Rust-only ladder completion; **~82%** reflects the C no-arg and gate/release gaps explicitly.

---

## Recommended next 3 steps (priority)

1. **P0 — Phase 7: C no-arg embed** — Mirror Rust `argc==1 → run shell.lbin` in `nano_main.c` / factory rebake; dual smoke flips C expectation from `usage:` to `shell.mode=embedded-lbin` (or track-specific marker). Unblocks wave SSOT shell UX parity.
2. **P1 — Gate wiring** — Add `nano-jit-shell-dual-smoke.sh` (or `shell-ci` subset) to `nanolisp-dual-gate.sh` or `nano-jit-rs-gate.sh` so shell regression rides the daily dual gate.
3. **P2 — Release + docs convergence** — Rebake `release/nano-lisp.com` pin when C embed lands; refresh [`PRODUCT-TRACKS.md`](PRODUCT-TRACKS.md) shell row; extend shell-ci Phase 3 check to assert C COM no-arg when available.

---

## Related

- [`SHELL-RUNNER.md`](SHELL-RUNNER.md) — commands, smokes, roadmap table
- [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md) — cross-track % rollup
- [`REFLECTION.md`](REFLECTION.md) — v4.5 wave narrative (wave60/67 shell-retire is CI infra, not this ladder)
