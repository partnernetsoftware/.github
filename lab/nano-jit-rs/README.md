# nano-jit-rs — Rust rewrite of nano-jit.com

`.lisp` compiles to portable `.lbin` bytecode (LBIN01 wire format) — same role as
`.java` → `.class`. Runtime execution only needs the `.lbin`; source is not required.

Rust crate splits **compiler** (`compile`) and **VM** (`run` / `dump` / …).

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
$RS compile lab/nano-lisp-jit/lisp/core/arithmetic.lisp /tmp/arithmetic.lbin
$RS run /tmp/arithmetic.lbin

$RS compile lab/nano-lisp-jit/lisp/core/strlen.lisp /tmp/strlen.lbin
$RS run /tmp/strlen.lbin
```

## CLI

| Command | Role | Status |
|---------|------|--------|
| `compile` `.lisp` → `.lbin` | compiler frontend | ✅ Phase 2b (bootstrap-smoke) |
| `run` `.lbin` | VM backend | ✅ |
| `dump` / `hash` / `resolve-quiet` | bytecode introspection | ✅ |
| `inspect-ape` | COM container probe | ✅ |
| `pack-ape` / `pack-ape-bare` | dual-ELF → APE v2 | ✅ byte parity vs C |
| `run-ape` / `run-ape-expect-exit` | execute COM slice | ✅ v2 memfd |

## Migration phases

1. **Done** — VM + CLI on x86_64/aarch64 Linux
2. **Done (2b)** — bootstrap-smoke 8 程序 compile hash 与 C COM 一致
3. **Done (4a)** — pack-ape + run-ape v2 (memfd)
4. **Next** — AOT multi-arch + replace `release/nano-lisp.com`

See `lab/nano-lisp-jit/v4.5/RUST-MIGRATION.md`.
