# COM + Lisp only — user path north star

**Goal**: daily use requires only **`release/nano-lisp.com`** and **`*.lisp`** (plans + dogfood sources). No `.sh` steps in plan, no `archive/c` inputs, no Rust binary, no on-disk embed artifacts.

**SSOT daily plan**:

```bash
COM=lab/nano-lisp-jit/release/nano-lisp.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-com-lisp-only-daily.lisp
```

**Smoke**:

```bash
bash lab/nano-lisp-jit/retired/scripts/nano-jit-com-lisp-only-smoke.sh
```

## In scope (user path)

| Allowed | Examples |
|---------|----------|
| Pinned COM | `release/nano-lisp.com` |
| Bootstrap plans | `lisp/bootstrap/bootstrap-v45-*.lisp` |
| Dogfood / core Lisp | `lisp/shell/*.lisp`, `lisp/core/*.lisp` |
| Ephemeral `.lbin` | COM `compile` output under `.build/` |

## Out of scope (factory / dual-track — not user daily)

| Still required elsewhere | Notes |
|--------------------------|-------|
| `cosmocc` / host `cc` | Rebake COM · 158KB codegen |
| `retired/scripts/*.sh` | c-gate / dual-gate CI |
| `archive/c/embed/*.lbin` | superseded by COM **rodata** embed for no-arg |
| `nanolisp` Rust binary | dual-track rs-gate · not com-only daily |
| `manifest.txt` / mindmap json | release audit · optional read in some legacy plans |

## Honest remaining (com-only %)

| Slice | % | Blocker |
|-------|---|---------|
| **Shell com-only plan** | **100%** | `bootstrap-v45-shell-com-only.lisp` |
| **Daily com+lisp** | **~90%** | piped fgets still uses OS `/bin/sh` one-liner |
| **Portable tree** | **~70%** | plans use repo-relative `lab/nano-lisp-jit/…` paths |
| **Factory zero toolchain** | **0%** | cosmocc/host-cc for COM regen |

## Related

- [`HONEST-REMAINING.md`](HONEST-REMAINING.md) — physical / factory honesty
- [`SHELL-CLOSURE.md`](SHELL-CLOSURE.md) — shell ladder scoped 100%
- [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md) — cross-track rollup
