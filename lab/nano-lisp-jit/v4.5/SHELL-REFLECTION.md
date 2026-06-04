# Shell runner — reflection (Phases 0–7 merged)

**Updated**: 2026-06-04 · Wave 2 reflection (post `nanolisp-shell-integrate`)  
**SSOT ladder**: [`SHELL-RUNNER.md`](SHELL-RUNNER.md) · **product tracks**: [`PRODUCT-TRACKS.md`](PRODUCT-TRACKS.md) · **rollup %**: [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md)

## Executive summary

Phases **0–7 (Rust)**, **Phase 7 alt** (`shell-repl-fgets` VM loop), and **C source no-arg (7b)** are merged and gated. C **release** `nano-lisp.com` pin still `usage:` on no-arg until cosmocc promote. **`bootstrap-v45-shell-ci.lisp`** unchanged (no fgets/repl-fgets steps yet).

**Honest overall**: **~89%** (see [percent rubric](#percent-rubric) below). **~90%** reserved for shell-ci plan extension + C embed slice.

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
| **7 alt** | `shell-repl-fgets.lisp` | VM REPL loop on **fgets + stdin addr** (distinct from Phase 2 `nano:read-line` REPL). In `bootstrap-v45-shell-dual.lisp` + `nano-jit-rs-shell-repl-fgets-smoke.sh` (rs-gate); **not** in shell-ci plan yet. |
| **7b** | C `nano_main.c` no-arg | Source `cmd_shell_noarg` wired (`nano_shell_cli.c`); host-cc path green; release COM pin unchanged until promote. Smoke: `nano-jit-c-shell-noarg-smoke.sh` (in `nano-jit-c-gate.sh`). Embed candidate path `archive/c/embed/shell-script.lbin` — **directory absent** on branch (next slice). |

**Still open**: C release rebake (`nano-lisp.com` no-arg embed), `archive/c/embed/` populate + factory regenesis, shell-ci fgets/repl-fgets steps, dual-smoke expectation flip when C COM ships shell UX.

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

## Percent rubric (~89%)

| Slice | % | Rationale |
|-------|---|-----------|
| Rust ladder proof (Ph 0–7, REPL, fgets, **7 alt repl-fgets**) | **97%** | rs-gate smokes green incl. `nano-jit-rs-shell-repl-fgets-smoke.sh`; embed hash-match in shell-ci; **shell-ci plan still stops at read-line REPL** (no fgets steps) |
| Dual-track parity (Ph 6–7, 7b source) | **82%** | Compile/run parity; C release no-arg + fgets opcode gap; `archive/c/embed/` not populated |
| Product / release (slim COM, wave SSOT) | **58%** | No C embed in pin; factory rebake pending |
| **Weighted overall** | **~89%** | +1 vs ~88% for repl-fgets gate/dual proof only — **not ~90%** until shell-ci extends |

Previous **~88%** credited Phase 7 fgets + nested dual-gate markers. **~89%** adds **7 alt** without inflating product slice. Target **~90%** when `bootstrap-v45-shell-ci.lisp` gains fgets/repl-fgets steps and C embed path exists on disk.

---

## Recommended next 3 steps (priority)

| Priority | Item | Status |
|----------|------|--------|
| **P0** | C no-arg **release** embed — cosmocc promote / rebake `nano-lisp.com`; dual smoke flips C expectation from `usage:` to `shell.mode=embedded-lbin` | ⬜ source done (7b); promote pending |
| **P1** | Gate wiring — shell regression on daily dual path | **✅ done** — `nanolisp-dual-gate.sh` nests c-gate + rs-gate; `nanolisp.dual-gate.shell=*` audit markers document smokes (no duplicate shell block) |
| **P2** | Release + docs convergence — manifest pin; **conditional** shell-ci / dual asserts for C COM no-arg when release ships; populate `archive/c/embed/` | ⬜ prep only — dual plan already `spawn-wait 2` on pinned C COM; shell-ci has no C no-arg assert today |

---

## Wave 2 reflection (2026-06-04)

Post-integrate branch (`cursor/nanolisp-shell-integrate-fc19`) state after merge:

| Item | Status |
|------|--------|
| **shell-repl-fgets** (Phase 7 alt) | ✅ `shell-repl-fgets.lisp`, rs-gate smoke, dual bootstrap compile/run; no `nanolisp shell-repl-fgets` CLI (run `.lbin` via `run` / plan) |
| **Dual-gate audit markers** | ✅ `nanolisp.dual-gate.shell=c-track` / `rs-track` lines in `nanolisp-dual-gate.sh`; rs-track lists repl-fgets |
| **C `archive/c/embed`** | ⬜ `nano_shell_cli.c` defines `SHELL_EMBED_C` → `lab/nano-lisp-jit/archive/c/embed/shell-script.lbin`; repo has `archive/c/README.md` only — active C TU under `retired/archive-c/runner/` |
| **shell-ci extension** | ⬜ `bootstrap-v45-shell-ci.lisp` still Ph 0–3 + read-line + VM REPL + pack-ape (~15 steps); fgets / repl-fgets belong in next slice for ~90% |
| **P0 / P1 / P2** | P0 cosmocc promote · P1 gate wiring **done** · P2 conditional C assert + embed path **prep** |

---

## Related

- [`SHELL-RUNNER.md`](SHELL-RUNNER.md) — commands, smokes, roadmap table
- [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md) — cross-track % rollup
- [`REFLECTION.md`](REFLECTION.md) — v4.5 wave narrative (wave60/67 shell-retire is CI infra, not this ladder)
