# nano-jit-rs — Rust rewrite of nano-jit.com

Portable `.lbin` VM + multi-target CLI. Replaces C runner incrementally.

## Build

```bash
bash lab/nano-lisp-jit/build_nano_jit_rs.sh
# → lab/nano-lisp-jit/.build/nano-jit-rs/nano-jit
```

Cross-compile aarch64 (once target installed):

```bash
rustup target add aarch64-unknown-linux-gnu
bash lab/nano-lisp-jit/build_nano_jit_rs.sh
```

## Smoke

```bash
RS=lab/nano-lisp-jit/.build/nano-jit-rs/nano-jit
COM=lab/nano-lisp-jit/release/nano-lisp.com
$COM compile lab/nano-lisp-jit/lisp/core/arithmetic.lisp /tmp/arithmetic.lbin
$RS run /tmp/arithmetic.lbin

$COM compile lab/nano-lisp-jit/lisp/core/strlen.lisp /tmp/strlen.lbin
$RS run /tmp/strlen.lbin
```

## CLI (Phase 1)

| Command | Status |
|---------|--------|
| `run` `.lbin` | ✅ Rust VM |
| `dump` / `hash` / `resolve-quiet` | ✅ |
| `inspect-ape` | ✅ v2 subset |
| `compile` `.lisp` | 🔗 bridges `NANO_JIT_LEGACY` COM |

## Migration phases

1. **Now** — VM + CLI on x86_64/aarch64 Linux
2. **Next** — Rust `.lisp` → `.lbin` compiler
3. **Then** — AOT multi-arch (Cranelift / object crate)
4. **Last** — APE pack/run-ape, replace `release/nano-lisp.com`

See `lab/nano-lisp-jit/v4.5/RUST-MIGRATION.md`.
