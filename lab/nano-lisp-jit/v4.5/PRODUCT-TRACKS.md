# Product tracks — C `nano-lisp.com` vs Rust `nanolisp.com`

**SSOT** for which release artifact to run, where source lives, and how gates promote. Detail migration matrix: [`RUST-MIGRATION.md`](RUST-MIGRATION.md). Pinned bytes: [`../release/manifest.txt`](../release/manifest.txt).

## At a glance

| | **C track (legacy)** | **Rust track (candidate)** |
|---|----------------------|----------------------------|
| **Product file** | `release/nano-lisp.com` | `release/nanolisp.com` |
| **Brand / CLI** | `nano-lisp` runner inside COM | `nanolisp` (`nanolisp.com=0.1.0`) |
| **Pinned size** | **334 537 B** (~327 KiB) | **2 959 413 B** (~2.82 MiB) |
| **APE** | v2 · **2×166 592 B** ELF slices (x86_64 + aarch64) | v2 · dual-arch `nanolisp` CLI packed |
| **Engine** | C runner (`lispjit` + Cosmo slice factory) | Rust `lab/nano-jit-rs/` |
| **Maturity** | **Production SSOT** for v4.5 wave convergence | **~99%** feature parity; gate-promoted release |
| **Default gate** | `retired/scripts/v45-wave*.sh` + factory regenesis | `retired/scripts/nano-jit-rs-gate.sh` |
| **Release promote** | `v45-wave91-release-promote-converge.sh` (native factory → `release/`) | `retired/scripts/nano-jit-rs-release-promote.sh` |

Also pinned: `v45-selfhost-next.com` (334 537 B, same hash as `nano-lisp.com` today) · bare `nanolisp.ape` (2 958 136 B) · **`nanolisp-slim.com`** (~161 KiB genesis-pin pathfinder).

**Progress assessment**: [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md) · **Dual gate**: `bash lab/nano-lisp-jit/retired/scripts/nanolisp-dual-gate.sh`

## Source paths

| Track | Code | Notes |
|-------|------|-------|
| **C** | [`retired/archive-c/runner/`](../retired/archive-c/runner/) — `lispjit.c`, `nano_main.c`, `ape_v2.c`, … | Factory waves under `retired/archive-c/factory/`. No active `archive/c/` tree in repo; history lives in `archive-c`. |
| **Rust** | [`lab/nano-jit-rs/`](../../nano-jit-rs/) | Crate name `nano-jit-rs`; binary `nanolisp`. Build: `lab/nano-lisp-jit/build_nano_jit_rs.sh` → `.build/nano-jit-rs/`. |

Shared Lisp/bootstrap: `lab/nano-lisp-jit/lisp/`.

## Gates & promote (by track)

### C — `nano-lisp.com`

- **Daily / wave convergence**: `bash lab/nano-lisp-jit/retired/scripts/v45-wave<N>-*.sh` (chain ends ~wave105 factory-build-lisp-only).
- **Release promote** (cosmocc factory regenesis → git `release/`): `v45-wave91-release-promote-converge.sh` after proc-io / matrix green.
- **Smoke on pinned COM**: e.g. `v45-proc-io-smoke.sh`, semantic 8k–154k converge scripts — all use `COM=…/release/nano-lisp.com`.

### Rust — `nanolisp.com`

- **Product gate (one command)**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-gate.sh` — build + all `nano-jit-rs-*-smoke.sh` + `cargo test`.
- **Release promote**: `bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-release-promote.sh` — packs x86_64+aarch64 into `release/nanolisp.com` + `nanolisp.ape`, rewrites `manifest.txt` (sets `nanolisp.com.engine=rust`).
- **Bootstrap on Rust COM**: most `nano-jit-rs-bootstrap-*.sh` use `COM=…/release/nanolisp.com`.

## Honest GAP (do not blur tracks)

| Area | C track | Rust track |
|------|---------|------------|
| **Binary size** | ~327 KiB — shipping constraint met | ~2.8 MiB full CLI · **~161 KiB** `nanolisp-slim.com` genesis pathfinder |
| **v4.5 wave SSOT** | `nano-lisp.com` is what wave scripts promote & pin | Parity proven; **not** the default COM in `v45-wave*.sh` |
| **Factory / regenesis** | Native C slice compiler still seeds some factory paths | `run-bootstrap-plan` + build-slice paths largely green on Rust |
| **AOT / compose** | Full 15-link semantic ladder on C COM | aarch64 compose-15link on release APE still **待补** (see RUST-MIGRATION) |
| **End state** | Maintain until Rust release fully replaces | Target: single `nanolisp.com` product; C runner retired |

## When to use which

| Use **C `nano-lisp.com`** when… | Use **Rust `nanolisp.com`** when… |
|----------------------------------|-----------------------------------|
| Running v4.5 wave / factory convergence gates | Running `nano-jit-rs-gate.sh` or Rust parity smokes |
| Need smallest portable APE (~327 KiB) | Developing compiler, VM, APE pack, NLCap, bootstrap plans |
| Reproducing pinned `manifest.txt` legacy hashes | Promoting or testing gate-passed Rust release candidate |
| `v45-selfhost-next.com` matrix / selfhost experiments | `version` / `inspect-ape` / `run-bootstrap-plan` on Rust engine |

Quick check:

```bash
# C legacy (~327 KiB, 2×166592 slices)
lab/nano-lisp-jit/release/nano-lisp.com inspect-ape lab/nano-lisp-jit/release/nano-lisp.com

# Rust candidate (~2.8 MiB)
lab/nano-lisp-jit/release/nanolisp.com version
```

| **Shell runner** | bootstrap spawn-wait | **Phase 0** `.lbin` system + CLI parity | pending REPL / embed COM |

## Related docs

- [`SHELL-RUNNER.md`](SHELL-RUNNER.md) — shell.lisp practice ladder · embed `.com` plan
- [`../release/README.md`](../release/README.md) — artifact table + manifest link
- [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md) — quantified % assessment · dual gate
- [`RUST-MIGRATION.md`](RUST-MIGRATION.md) — component parity matrix & smoke index
- [`REFLECTION.md`](REFLECTION.md) — v4.5 narrative / wave history
