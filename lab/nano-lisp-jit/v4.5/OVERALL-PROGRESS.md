# Overall progress — nanolisp commercial SOTA

**Updated**: gate snapshot on `main`. SSOT tracks: [`PRODUCT-TRACKS.md`](PRODUCT-TRACKS.md) · parity matrix: [`RUST-MIGRATION.md`](RUST-MIGRATION.md).

## Executive summary

| Track | Overall | Gate | Release artifact |
|-------|---------|------|------------------|
| **C `nano-lisp.com`** | **95%** shipping-ready | `nanolisp.c-gate=ok` | 334 537 B · wave SSOT |
| **Rust `nanolisp.com`** | **99%** feature parity | `nanolisp.gate=ok` | 2 959 413 B · full CLI APE |
| **Rust slim pathfinder** | **40%** | slim smoke | `nanolisp-slim.com` ~161 KiB (genesis-pin pack) |
| **Migration (Rust replaces C)** | **~86%** | dual gate | C maintained until slim + parity complete |
| **Shell runner ladder** | **~45%** | shell smokes | Phase 0–3 done; wave embed pending |

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

## Milestone checklist

- [x] PRODUCT-TRACKS + dual gate
- [x] C gate (`nano-jit-c-gate.sh`)
- [x] Rust gate (`nano-jit-rs-gate.sh`) — 18 unit tests
- [x] compose-15link build-slice + semantic + hybrid + genesis-pin
- [x] aarch64 VM/AOT build-slice-lisp (min/ir pure-blob)
- [x] nano_cc build-slice path
- [x] `nanolisp-slim.com` genesis-pin release pathfinder
- [x] shell-v0 — `libc:system` .lbin + CLI `spawn-wait`/`read-file`
- [x] shell Phase 1 — `shell-script.lisp` + `nanolisp shell` / `shell-repl` + bootstrap chain
- [x] shell Phase 3 — no-arg → embedded `shell-script.lbin` in APE
- [ ] Rust APE size ≈ C COM with runnable full CLI
- [ ] C/Rust zero host-cc 158KB codegen
- [ ] v45-wave default → `nanolisp.com`
