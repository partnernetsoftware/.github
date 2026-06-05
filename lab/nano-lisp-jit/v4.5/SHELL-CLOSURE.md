# Shell runner ladder — scoped 100% closure

**Updated**: 2026-06-05 · closure wave 7 on `cursor/nanolisp-shell-closure-fc19`  
**SSOT ladder**: [`SHELL-RUNNER.md`](SHELL-RUNNER.md) · **reflection**: [`SHELL-REFLECTION.md`](SHELL-REFLECTION.md) · **rollup**: [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md)

## Definition — scoped 100%

**Scoped 100%** means the **practice shell runner ladder** is complete and gated:

| In scope (100%) | Out of scope (cross-track GAP) |
|-----------------|--------------------------------|
| Phases **0–9** (Rust ladder + C host-cc / opcode / release pin) | **Wave-default COM** — v45-wave scripts still promote `nano-lisp.com` as SSOT, not `nanolisp.com` → [`PRODUCT-TRACKS.md`](PRODUCT-TRACKS.md) |
| **Dual-gate** nested shell smokes (`nanolisp-dual-gate.sh`) | **Slim / 158KB** product path — `nanolisp-slim.com` genesis-pin, pure Lisp 158KB codegen → [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md#honest-remaining-gap-priority) · [`RUST-MIGRATION.md`](RUST-MIGRATION.md) |
| **C release pin** — `nano-jit-c-shell-release-promote.sh` → `release/nano-lisp.com` | **Rust APE ≈ C COM size** — full Rust ~3.0 MiB vs pinned C **863 001 B** |
| **Probe embedded** — `nanolisp-c-release-shell-probe.sh` → `nanolisp.c-release-shell=embedded` | **User daily = COM + plan only** as wave SSOT (engineering proof done; product habit open) |

**Not** “wave-default / slim / 158KB SOTA” — those are **cross-track** concerns, linked above, not shell-ladder blockers.

---

## Timeline — Waves 1–6 + closure wave 7

| Wave | Branch / theme | Ladder deliverables | Pin / gate |
|------|----------------|---------------------|------------|
| **1** | integrate — Ph 0–3 baseline | `shell-v0` / `shell-script` / no-arg Rust embed; CLI `spawn-wait` / `read-file` / `nanolisp shell` | rs-gate v0/script/noarg smokes |
| **2** | `cursor/nanolisp-shell-integrate-fc19` | shell-ci **Phase 7** (fgets + repl-fgets); C `archive/c/embed` hash-match; promote prep smoke | P0 cosmocc promote open |
| **3** | integrate | C release **auto-probe**; shell-ci **Phase 7b** C track; **Phase 8** `bootstrap-v45-shell-full.lisp` | ~91–92% headline |
| **4** | integrate | C **fgets opcode** + `nano-jit-c-shell-fgets-smoke.sh`; shell-full rs path; host-cc promote smoke | ~93% headline |
| **5** | `cursor/nanolisp-shell-reflection-wave5-fc19` | Gate **readonly promote**; `bootstrap-cosmocc.sh`; **Phase 9** `bootstrap-v45-shell-promote.lisp` | Product slice held until pin |
| **6** | `cursor/nanolisp-shell-reflection-wave6-fc19` | **P0** `nano-jit-c-shell-release-promote.sh` + `v45-manifest-pin.sh`; dual-smoke C/Rust `shell.mode=embedded-lbin` | Probe `embedded` on **863 001 B** pin |
| **7 (closure)** | `cursor/nanolisp-shell-closure-fc19` | **Scoped 100%** doc + rubric lock; byte SSOT **863 001**; executive links | Ladder **100%** · product shell slice **~85%** |

---

## Command cheat sheet

### Dual-gate (daily shell regression umbrella)

```bash
bash lab/nano-lisp-jit/retired/scripts/nanolisp-dual-gate.sh
```

Optional heavy C release rebake (writes `release/` — not c-gate auto-pin):

```bash
NANO_C_SHELL_RELEASE_PROMOTE=1 bash lab/nano-lisp-jit/retired/scripts/nanolisp-dual-gate.sh
```

### Release promote (C shell embed pin)

```bash
bash lab/nano-lisp-jit/retired/scripts/nano-jit-c-shell-release-promote.sh
bash lab/nano-lisp-jit/retired/scripts/nanolisp-c-release-shell-probe.sh
# expect: nanolisp.c-release-shell=embedded
```

Prep only (host-cc when cosmocc missing; no release write):

```bash
bash lab/nano-lisp-jit/retired/scripts/nano-jit-c-shell-promote-smoke.sh
```

### Ladder-smoke (ordered proof without full wave chain)

Rust full ladder (~29 steps):

```bash
bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-full-smoke.sh
```

Dual-track parity (C + Rust no-arg + fgets path):

```bash
bash lab/nano-lisp-jit/retired/scripts/nano-jit-shell-dual-smoke.sh
```

Promote plan slice (~12 steps; cosmocc external):

```bash
bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-promote-smoke.sh
```

Per-phase smokes: see [`SHELL-RUNNER.md`](SHELL-RUNNER.md) phase sections (`nano-jit-rs-shell-*` / `nano-jit-c-shell-*`).

---

## Rubric (closure lock)

| Slice | Closure % | Rationale |
|-------|-----------|-----------|
| **Shell ladder** (Ph 0–9, dual-gate, C release pin, probe `embedded`) | **100%** scoped | All phases merged; smokes nested in c-gate / rs-gate / dual-gate |
| **Product shell slice** (slim COM embed, wave SSOT default, daily COM-only habit) | **~85%** | Release pin + probe green; wave-default + slim parity still open |
| **Cross-track** (wave-default, slim, 158KB codegen, Rust size parity) | **out of scope** | Tracked in [`PRODUCT-TRACKS.md`](PRODUCT-TRACKS.md) · [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md) — not shell-ladder % |

**Headline for shell track**: **100% scoped** (not 100% commercial SOTA across all product tracks).

---

## 梳理 — file map

### `lisp/shell/` (dogfood sources)

| File | Phase | Role |
|------|-------|------|
| `shell-v0-system.lisp` | 0 | `libc:system` one-shot |
| `shell-script.lisp` | 1 | chained `libc:system` |
| `shell-repl.lisp` | 2 | VM `nano:read-line` REPL |
| `shell-readline-smoke.lisp` | 2 | read-line smoke helper |
| `shell-fgets-smoke.lisp` | 7 | stdin addr + `libc:fgets` |
| `shell-repl-fgets.lisp` | 7 alt | fgets REPL loop |
| `shell-stdin-smoke.lisp` | 6 | stdin addr smoke |

Embedded artifact (Rust + C source): `lab/nano-jit-rs/embed/shell-script.lbin` · C path `archive/c/embed/shell-script.lbin` (wired in source; rebake via promote).

### Bootstrap plans (`lisp/bootstrap/`)

| Plan | Phase | Smoke |
|------|-------|-------|
| `bootstrap-v45-shell-v0-smoke.lisp` | 0 | (granular / CI helpers) |
| `bootstrap-v45-shell-script-smoke.lisp` | 1 | script chain |
| `bootstrap-v45-shell-c-noarg.lisp` | 3 / 7b | C no-arg ladder |
| `bootstrap-v45-shell-ci.lisp` | 4 | `nano-jit-rs-shell-ci-smoke.sh` |
| `bootstrap-v45-shell-dual.lisp` | 6 | `nano-jit-shell-dual-smoke.sh` |
| `bootstrap-v45-shell-full.lisp` | 8 | `nano-jit-rs-shell-full-smoke.sh` |
| `bootstrap-v45-shell-promote.lisp` | 9 | `nano-jit-rs-shell-promote-smoke.sh` |

### Smokes (`retired/scripts/`)

| Script | Track | Gate |
|--------|-------|------|
| `nano-jit-rs-shell-v0-smoke.sh` | Rust | manual / plan |
| `nano-jit-rs-shell-script-smoke.sh` | Rust | manual |
| `nano-jit-rs-shell-repl-vm-smoke.sh` | Rust | rs-gate |
| `nano-jit-rs-shell-noarg-smoke.sh` | Rust | rs-gate |
| `nano-jit-rs-shell-ci-smoke.sh` | Rust | rs-gate |
| `nano-jit-rs-shell-fgets-smoke.sh` | Rust | rs-gate |
| `nano-jit-rs-shell-repl-fgets-smoke.sh` | Rust | rs-gate |
| `nano-jit-rs-shell-full-smoke.sh` | Rust | rs-gate |
| `nano-jit-rs-shell-promote-smoke.sh` | Rust | rs-gate |
| `nano-jit-shell-dual-smoke.sh` | dual | dual-gate |
| `nano-jit-c-shell-noarg-smoke.sh` | C | c-gate |
| `nano-jit-c-shell-fgets-smoke.sh` | C | c-gate |
| `nano-jit-c-shell-promote-smoke.sh` | C | dual-gate prep |
| `nano-jit-c-shell-release-promote.sh` | C | manual / `NANO_C_SHELL_RELEASE_PROMOTE=1` |
| `nanolisp-c-release-shell-probe.sh` | C | sourced by smokes |
| `nanolisp-dual-gate.sh` | both | product dual-gate |

Orchestration SSOT: [`SHELL-RUNNER.md` § C release shell promote](SHELL-RUNNER.md#c-release-shell-promote-wave-6).

---

## Phase → artifact matrix

| Ph | Lisp / plan | CLI / COM behavior | Primary smoke |
|----|-------------|-------------------|---------------|
| **0** | `shell-v0-system.lisp` | `spawn-wait` / compile+run | `nano-jit-rs-shell-v0-smoke.sh` |
| **1** | `shell-script.lisp` | `nanolisp shell` | `nano-jit-rs-shell-script-smoke.sh` |
| **2** | `shell-repl.lisp` | `nanolisp shell-repl` | `nano-jit-rs-shell-repl-vm-smoke.sh` |
| **3** | embed `shell-script.lbin` | `$COM` / `$RS` no-arg → embedded-lbin | rs + c noarg smokes |
| **4** | `bootstrap-v45-shell-ci.lisp` | `shell-ci` (~28 steps) | `nano-jit-rs-shell-ci-smoke.sh` |
| **5** | *(alias of Ph 2 in docs)* | numbering debt only | — |
| **6** | `bootstrap-v45-shell-dual.lisp` | dual C/Rust v0 + stdin/fgets | `nano-jit-shell-dual-smoke.sh` |
| **7** | `shell-fgets-smoke.lisp` | `libc:fgets` + stdin addr | rs + c fgets smokes |
| **7 alt** | `shell-repl-fgets.lisp` | fgets REPL | `nano-jit-rs-shell-repl-fgets-smoke.sh` |
| **7b** | `bootstrap-v45-shell-c-noarg.lisp` | C `cmd_shell_noarg` + release embed | c noarg + promote + release-promote |
| **8** | `bootstrap-v45-shell-full.lisp` | full ladder ~29 steps | `nano-jit-rs-shell-full-smoke.sh` |
| **9** | `bootstrap-v45-shell-promote.lisp` | promote ladder ~12 steps | `nano-jit-rs-shell-promote-smoke.sh` |
| **pin** | factory cosmocc → `release/nano-lisp.com` | manifest **863 001 B** | `nano-jit-c-shell-release-promote.sh` + probe |
| **gate** | — | dual-gate audit markers | `nanolisp-dual-gate.sh` |

---

## Related

- [`SHELL-REFLECTION.md`](SHELL-REFLECTION.md) — wave narrative · Wave 7 closure section
- [`PRODUCT-TRACKS.md`](PRODUCT-TRACKS.md) — C vs Rust release SSOT
- [`../release/manifest.txt`](../release/manifest.txt) — pinned `nano-lisp.com.bytes=863001`
