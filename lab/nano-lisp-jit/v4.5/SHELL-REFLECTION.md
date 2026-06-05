# Shell runner — reflection (Phases 0–8 merged)

**Updated**: 2026-06-05 · Wave 7 closure (scoped **100%** ladder lock)  
**SSOT ladder**: [`SHELL-RUNNER.md`](SHELL-RUNNER.md) · **closure**: [`SHELL-CLOSURE.md`](SHELL-CLOSURE.md) · **product tracks**: [`PRODUCT-TRACKS.md`](PRODUCT-TRACKS.md) · **rollup %**: [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md)

## Executive summary

Phases **0–9** (Rust ladder + C host-cc / opcode / **release pin**) are merged and gated. **Waves 1–6** delivered shell-ci, fgets, shell-full, readonly promote, and **Wave 6** C **release** rebake (**863 001 B** `nano-lisp.com` per [`manifest.txt`](../release/manifest.txt)). **Scoped 100%** = Ph 0–9 + **dual-gate** + **C release pin** + **probe `embedded`** — see [`SHELL-CLOSURE.md`](SHELL-CLOSURE.md) for definition, timeline, cheat sheet, and phase→artifact matrix.

**Not in scoped 100%**: wave-default COM, slim/158KB path, pure-Lisp codegen — cross-track GAP with links in closure doc.

**Honest overall**: **100% scoped** shell ladder; product shell slice **~85%**; cross-track SOTA **out of scope** for this track.

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
| **7** | `libc:fgets` via stdin addr | Rust + **C host-cc** VM `ptr(ptr,i32,ptr)`; smokes: `nano-jit-rs-shell-fgets-smoke.sh`, `nano-jit-c-shell-fgets-smoke.sh` (c-gate). **Wave 6 done** — opcode in pinned COM (**863 001 B**). |
| **7 alt** | `shell-repl-fgets.lisp` | VM REPL on **fgets + stdin addr**; in shell-ci, dual bootstrap, rs-gate smoke. |
| **7b** | C `nano_main.c` no-arg + file embed | Source + **release** `cmd_shell_noarg`; `archive/c/embed/shell-script.lbin` (280 B, hash-match rs embed); pinned COM `shell.mode=embedded-lbin` after Wave 6 promote. Smokes: `nano-jit-c-shell-noarg-smoke.sh`, `nano-jit-c-shell-promote-smoke.sh`, `nano-jit-c-shell-release-promote.sh`. |
| **8** | `bootstrap-v45-shell-full.lisp` + `shell-full` | One plan (~29 steps); `nanolisp shell-full` CLI + rs-gate smoke. |

**Still open**: wave scripts default COM; user daily = COM + plan only; Rust APE size parity — see product SOTA table below.

---

## Dual-track honest GAP

| Capability | C `nano-lisp.com` (wave SSOT) | Rust `nanolisp.com` (parity candidate) |
|------------|-------------------------------|----------------------------------------|
| CLI `spawn-wait` / `read-file` | ✅ | ✅ |
| `.lbin` `libc:system` compile/run | ✅ | ✅ |
| `nanolisp shell` / `shell-repl` / `shell-ci` / **shell-full** | ⬜ **Phase 8b** — no C `shell-full` subcommand; **`$COM run-bootstrap-plan …/bootstrap-v45-shell-full-c.lisp`** (c-gate ~21 steps) | ✅ (`nanolisp shell-full` + rs-gate smoke) |
| No-arg `$COM` → shell | ✅ **release** `shell.mode=embedded-lbin` (Wave 6 pin) · ✅ source | ✅ embedded `shell-script.lbin` |
| `libc:stdin` addr in VM | ✅ (pinned release) | ✅ |
| `libc:fgets` via stdin addr | ✅ Phase 7 opcode (`nano-jit-c-shell-fgets-smoke.sh`, c-gate) | ✅ Phase 7 |
| Dual bootstrap plan | ✅ compile/run v0 via C COM | ✅ plan driver on Rust |
| shell-ci / shell-full C track | ✅ embed cmp + COM compile/run + no-arg pin in plan | ✅ Rust subcommands |
| Gate inclusion | **c-gate** → shell-noarg, fgets, **shell-full-c** | **rs-gate** → shell-ci, **shell-full**, repl-vm, dual, fgets, repl-fgets |
| Dual-gate (`nanolisp-dual-gate.sh`) | ✅ nested via c-gate · audit `nanolisp.dual-gate.shell=c-track *` | ✅ nested via rs-gate · audit `nanolisp.dual-gate.shell=rs-track *` (incl. shell-full) |
| P2 release assert | ✅ **auto-probe** sets `NANO_C_RELEASE_HAS_SHELL` | N/A |

After Wave 6 promote, dual smoke **expects** parity on both tracks: Rust and pinned C COM no-arg print `shell.mode=embedded-lbin` (`nano-jit-shell-dual-smoke.sh` + `nanolisp-c-release-shell-probe.sh`). Host-cc path remains the fast pre-promote proof in `nano-jit-c-shell-noarg-smoke.sh`.

---

## What “done” means vs product SOTA

| Criterion | Practice ladder (Ph 0–8) | Product SOTA |
|-----------|--------------------------|--------------|
| Lisp shell dogfood in `lisp/shell/` | ✅ | ✅ |
| Bootstrap plans replace granular smokes | ✅ shell-ci + shell-full | ✅ nested in dual-gate (via track gates) |
| `$COM` no-arg is a shell | ✅ Rust · ✅ C source · ✅ C release pin | ✅ Wave 6 promote |
| Pinned COM (**863 001 B**) carries shell | N/A (Rust ~2.8 MiB full) | ✅ embed in pinned `release/nano-lisp.com` |
| Wave scripts default COM | C `nano-lisp.com` | ⬜ unchanged |
| User daily = COM + plan only | ✅ shell-ci / shell-full path | ⬜ wave SSOT still C COM; Rust not default |
| P2 conditional release assert | ✅ auto-probe + manual override | ✅ probe `embedded` after pin |

**Done for engineering proof** ≈ **release shell UX shipped** on C pin; remaining product GAP is wave-default COM, slim-size parity, and pure-Lisp 158KB codegen — not no-arg dispatch.

---

## Percent rubric (closure lock — Wave 7)

SSOT: [`SHELL-CLOSURE.md` § Rubric](SHELL-CLOSURE.md#rubric-closure-lock).

| Slice | Wave 6 (~95%) | Wave 7 closure | Rationale |
|-------|---------------|----------------|-----------|
| **Shell ladder** (Ph 0–9, dual-gate, pin, probe) | **~95%** | **100%** scoped | All phases + gates documented and green on pin |
| **Product shell slice** (slim embed, wave SSOT, daily COM-only) | **~75%+** | **~85%** | Release pin + probe; wave-default + slim still open |
| **Cross-track** (wave-default, slim, 158KB) | — | **out of scope** | [`PRODUCT-TRACKS.md`](PRODUCT-TRACKS.md) · [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md) |
| **Headline (shell track)** | **~95%** | **100% scoped** | Not commercial SOTA across all tracks |

---

## Recommended next 3 steps (priority)

| Priority | Item | Status |
|----------|------|--------|
| **P0** | C no-arg **release** embed — see [P0 checklist](#p0-checklist-wave-6) | **✅ done** (Wave 6 `nano-jit-c-shell-release-promote.sh` → pin; probe `embedded`) |
| **P1** | Gate wiring — shell regression on daily dual path | **✅ done** |
| **P2** | Release + docs convergence — conditional C COM assert when release ships | **✅ done** — probe defaults `NANO_C_RELEASE_HAS_SHELL=1` on pinned COM after Wave 6 |

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

## Wave 4 reflection (2026-06-04)

Wave 4 merged on `cursor/nanolisp-shell-integrate-fc19`:

| Item | Status | Notes |
|------|--------|-------|
| **Phase 7 C fgets opcode** | ✅ | `OP_CALL_IMPORT_CONST_IMM_PTR` + `SIG_PTR_PTR_I32_PTR`; `nano-jit-c-shell-fgets-smoke.sh` in c-gate |
| **shell-full CLI** | ✅ | `nanolisp shell-full` → `bootstrap-v45-shell-full.lisp`; rs-gate smoke |
| **host-cc factory promote** | ✅ | promote smoke runs host-cc path when cosmocc missing |
| **P0** | ⬜ product | Release pin unchanged; cosmocc rebake still required |
| **Headline %** | **~93%** | Product slice **58%** until release pin |

---

## Wave 5 reflection (2026-06-04)

Wave 5 on `cursor/nanolisp-shell-reflection-wave5-fc19` — **docs/plan slice** on integrate base; ladder % held until release pin rebakes.

| Item | Status | Notes |
|------|--------|-------|
| **Gate readonly promote** | ✅ | `nano-jit-c-gate.sh`: manifest **parity only** on pinned `release/nano-lisp.com`; smokes never auto-pin factory into `release/` |
| **cosmocc bootstrap script** | ✅ | `bootstrap-cosmocc.sh` — symlink `third_party/cosmocc` → `/opt/cosmocc` (dev container per `AGENTS.md`) |
| **Phase 9 shell-promote plan** | ✅ | `bootstrap-v45-shell-promote.lisp` + rs-gate smoke; c-gate via dual-gate promote prep |
| **P0 checklist** | ⬜ | See Wave 5 table (superseded by Wave 6) |
| **Headline %** | **~93%** | Product slice **58%** until release pin rebake |

### P0 checklist (Wave 5 — historical)

| Step | Action | Owner |
|------|--------|-------|
| 1 | Run **`bootstrap-cosmocc.sh`** so `third_party/cosmocc/bin/` resolves | Agent / dev container |
| 2 | `NANO_C_SHELL_PROMOTE_BUILD=1 bash retired/scripts/nano-jit-c-shell-promote-smoke.sh` — factory asserts `shell.mode=embedded-lbin` | CI optional / manual |
| 3 | **Manual** `bash retired/scripts/v45-manifest-pin.sh <factory-com>` | Human promote — **not** c-gate auto-pin |

---

## Wave 6 reflection (2026-06-04)

Wave 6 on `cursor/nanolisp-shell-reflection-wave6-fc19` — **docs slice** assuming C release promote lands on integrate.

| Item | Status | Notes |
|------|--------|-------|
| **P0 release embed** | ✅ | `nano-jit-c-shell-release-promote.sh`: cosmocc bootstrap → factory → install + **`v45-manifest-pin.sh`**; c-gate pass on new pin |
| **cosmocc bootstrap** | ✅ | `bootstrap-cosmocc.sh` / dev container `/opt/cosmocc` |
| **Gate readonly promote** | ✅ | Smokes + c-gate never auto-pin; orchestrator owns `release/` write |
| **Phase 9 shell-promote** | ✅ | Plan + rs-gate; dual-smoke C/Rust no-arg parity |
| **Dual-smoke parity** | ✅ | `shell.mode=embedded-lbin` on both tracks when probe `embedded` |
| **Headline %** | **~95%** | Product slice **~75%+** |

### P0 checklist (Wave 6)

| Step | Action | Status |
|------|--------|--------|
| 1 | **`bootstrap-cosmocc.sh`** — `third_party/cosmocc/bin/` resolves | ✅ |
| 2 | **`nano-jit-c-shell-release-promote.sh`** — factory `shell.mode=embedded-lbin` | ✅ |
| 3 | **`v45-manifest-pin.sh`** — probe `nanolisp.c-release-shell=embedded` | ✅ |

Orchestrator SSOT: [`SHELL-RUNNER.md` § C release shell promote (Wave 6)](SHELL-RUNNER.md#c-release-shell-promote-wave-6).

---

## Wave 7 closure (2026-06-05)

Wave 7 merges `cursor/nanolisp-shell-closure-fc19`, `cursor/nanolisp-shell-full-c-fc19`, `cursor/nanolisp-shell-ladder-smoke-fc19`, `cursor/nanolisp-shell-docs-sync-fc19` — **scoped 100% lock** + last C ladder slice.

| Item | Status | Notes |
|------|--------|-------|
| **Scoped 100% definition** | ✅ | [`SHELL-CLOSURE.md`](SHELL-CLOSURE.md) — Ph 0–9 + dual-gate + pin + probe; excludes wave-default / slim / 158KB |
| **Phase 8b C full plan** | ✅ | `bootstrap-v45-shell-full-c.lisp` (~21 steps) + `nano-jit-c-shell-full-c-smoke.sh` in c-gate |
| **Ladder meta smoke** | ✅ | `nano-jit-shell-ladder-smoke.sh` — probe → c-noarg → rs-ci/full/promote → dual (manual; not daily dual-gate) |
| **Timeline Waves 1–7** | ✅ | Closure table + phase→artifact matrix |
| **Command cheat sheet** | ✅ | dual-gate · release-promote · ladder-smoke |
| **Rubric lock** | ✅ | Ladder **100%** · product shell **~85%** · cross-track out of scope |
| **Byte SSOT** | ✅ | C `nano-lisp.com` **863 001 B** per `manifest.txt` (not legacy 334 537 B) |
| **P0 / P1 / P2** | ✅ | Unchanged from Wave 6 — probe `embedded`, gates nested |
| **Hygiene pass** | ✅ | `release/README.md` pin sync · `nano-jit-shell-hygiene.sh` · merged branch prune doc |
| **Rodata embed (Wave 8)** | ✅ | `nano_shell_embed.c` + `gen-shell-embed-c.sh`; isolated `$COM` no-arg · pin **867 097 B** |

---

## Related

- [`SHELL-CLOSURE.md`](SHELL-CLOSURE.md) — scoped 100% closure SSOT
- [`SHELL-RUNNER.md`](SHELL-RUNNER.md) — commands, smokes, roadmap table
- [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md) — cross-track % rollup
- [`REFLECTION.md`](REFLECTION.md) — v4.5 wave narrative (wave60/67 shell-retire is CI infra, not this ladder)
