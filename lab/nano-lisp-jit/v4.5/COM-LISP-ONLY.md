# COM + Lisp only — user path north star

**Goal**: daily use requires only **`release/nano-lisp.com`** and **`*.lisp`** (plans + dogfood sources). No `.sh` steps in plan, no `archive/c` inputs, no Rust binary, no on-disk embed artifacts.

**SSOT daily plan**:

```bash
COM=lab/nano-lisp-jit/release/nano-lisp.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-com-lisp-only-daily.lisp
```

**Portable flat bundle** (same deps — copy `nano-lisp.com`, `bootstrap/`, `lisp/` to one directory):

```bash
./nano-lisp.com run-bootstrap-plan bootstrap/bootstrap-v45-com-lisp-only-bundle-daily.lisp
```

**Smoke**:

```bash
bash lab/nano-lisp-jit/retired/scripts/nano-jit-com-lisp-only-smoke.sh
```

## In scope (user path)

| Allowed | Examples |
|---------|----------|
| Pinned COM | `release/nano-lisp.com` or flat `nano-lisp.com` |
| Bootstrap plans | `lisp/bootstrap/bootstrap-v45-*.lisp` or flat `bootstrap/*.lisp` |
| Dogfood / core Lisp | `lisp/shell/*.lisp`, `lisp/core/*.lisp` |
| Ephemeral `.lbin` | COM `compile` output under `.build/` |
| Bootstrap DSL | `compile`, `run`, `run-stdin`, `compare`, `spawn-wait`, `file-size`, … |

## Out of scope (factory / dual-track — not user daily)

| Still required elsewhere | Notes |
|--------------------------|-------|
| `cosmocc` / host `cc` | Rebake COM · 158KB codegen |
| `retired/scripts/*.sh` | c-gate / dual-gate CI |
| `archive/c/embed/*.lbin` | superseded by COM **rodata** embed for no-arg |
| `nanolisp` Rust binary | dual-track rs-gate · not com-only daily |
| `manifest.txt` / mindmap json | release audit · optional read in some legacy plans |

## Honest remaining (com-only %)

**口径**：「用户 daily」= 已有 pin 的 COM + plan 内无 `.sh`/`.c`/Rust；**≠** 从纯 Lisp 重造 COM（158KB codegen 另轨）。

| Slice | % | Blocker |
|-------|---|---------|
| **Shell com-only plan** | **100%** | plan 内无 `/bin/sh` |
| **Daily com+lisp（用 pin）** | **100%** | release pin 含 `run-stdin`；运行时 OS libc |
| **Portable flat bundle** | **100%** | flat bundle daily plan |
| **从 *.lisp 重造 COM** | **0%** | pure Lisp 158KB codegen — [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md) |
| **Factory zero toolchain** | **0%** | cosmocc 重打 867KB COM |

## Related

- [`HONEST-REMAINING.md`](HONEST-REMAINING.md) — physical / factory honesty
- [`SHELL-CLOSURE.md`](SHELL-CLOSURE.md) — shell ladder scoped 100%
- [`OVERALL-PROGRESS.md`](OVERALL-PROGRESS.md) — cross-track rollup
