# ape-v2 binary header (slice 1)

Minimal native header before concatenated ELF slices. v1 comment manifest remains valid; `inspect-ape` and future native loaders read v2 first when present.

## File layout

Shell stub (optional v1 `# nano.manifest.*` for stub/`run-ape`), then payload region:

**Mode A (compat):** `__NANO_APE_PAYLOAD_BELOW__\n` → v2 header → `<x86_64 ELF><aarch64 ELF>`

**Mode B (native):** v2 header replaces the marker line → `<x86_64 ELF><aarch64 ELF>`

`payload_start` = first byte after the marker line (mode A), or first byte of the v2 header (mode B).  
`payload_base` = `payload_start + header_bytes`. Slice `offset`/`size`/`hash` are relative to `payload_base` (x86_64 offset 0; aarch64 offset = x86_64 size).

## v2 header (little-endian)

| Off | Size | Field |
|-----|------|-------|
| 0 | 8 | magic = `\x7fNANOape` |
| 8 | 4 | `version` = **2** |
| 12 | 2 | `slice_count` (≥1) |
| 14 | 2 | `header_bytes` = 16 + `slice_count` × 28 |
| 16 | 28×N | payload table (one row per slice) |

**Payload table row**

| Off | Size | Field |
|-----|------|-------|
| 0 | 1 | `arch_id`: **1**=x86_64, **2**=aarch64 |
| 1 | 1 | `os_id`: **1**=linux · **2**=macOS (planned) · **3**=Windows (planned) |
| 2 | 2 | reserved (0) |
| 4 | 8 | `offset` u64 |
| 12 | 8 | `size` u64 |
| 20 | 8 | `hash` u64 FNV-1a64; **0** = optional (skip verify) |

Rows SHOULD be sorted by `(arch_id, os_id)`. Default pack: two rows (x86_64/linux, aarch64/linux).

## `inspect-ape` detection

1. Locate `payload_start` (marker line+1, or scan stub tail for v2 magic at line start in mode B).
2. If `magic` + `version==2` at `payload_start` → parse v2 table; set `container=ape-v2`.
3. Else → v1 path: require marker + `# nano.manifest.*` with `nano.container=ape-v1`.

Validation (both paths): bounds, ELF magic at each slice, hash if non-zero. v2 also rejects `header_bytes` mismatch, unknown `arch_id`/`os_id`, or truncated table.

## `inspect-ape` exit codes (reuse 2–5)

| Code | v1 | v2 |
|------|----|----|
| 2 | manifest or marker missing | marker/header region missing, or truncated header |
| 3 | bad/missing `nano.container` | bad magic or `version` ≠ 2 |
| 4 | bad offset/size, OOB, non-ELF | same + bad `header_bytes` / unknown ids |
| 5 | FNV-1a64 mismatch | same |

Success prints include `inspect-ape.container=ape-v2`, `inspect-ape.header_bytes=…`, and per-slice `arch_id`, `os_id`, `offset`, `size`, `hash`.

## Loader (100% scoped)

- **Primary (native):** `nano-jit run-ape container.com [arch]` reads the v2 table in-process when magic is present; otherwise the v1 comment manifest (`ape-v1`).
- **Linux ELF slices (v1 + v2):** `run-ape` always tries `memfd_create` + `write` + `fork`/`exec` via `/proc/self/fd/N` first (`run-ape.loader=memfd`). Only if that path fails (no `memfd_create`, arch mismatch on host, or write/exec error) does it fall back to a `/tmp` extract (`run-ape.loader=tmpfile`). Cross-arch on x86_64 (e.g. forced `aarch64` + QEMU) uses the tmpfile path.
- **`pack-ape` shell stub:** `# nano.loader=run-ape-cli` — if `NANO_JIT` is set, `exec "${NANO_JIT}" run-ape "$0" "$@"` (no runtime `dd`); else if `nano-lisp-jit` is on `PATH`, `exec nano-lisp-jit run-ape …`; else `# nano.loader.fallback=dd-extract` (manifest offsets + `dd` + `exec`). When a runner is configured, the stub never reaches the `dd` path.
- **Mode B (bare):** `pack-ape-bare` — v2 header at offset 0, no shell; execution is `run-ape` only (same Linux memfd-first rule).
- **`NANO_PACK_APE_MODE` (v2.5 default strategy):** `pack-ape` reads `NANO_PACK_APE_MODE` before building. **`stub`** (default, unset or explicit) — Mode A shell + marker + v2 payload (compat). **`bare`** — same output as `pack-ape-bare` (header at offset 0). `pack-ape-bare` remains an explicit alias; both call the same bare builder in `nano_ape.c`.

## Scope (slice 1)

- Spec + `pack-ape` / `inspect-ape` / bootstrap negative fixtures; v1-only containers (`ape-v1-legacy.com`) still inspect/run via manifest fallback.

Fixtures: extend `make_ape_fixtures.py`; see [APE-v1.md](APE-v1.md) for v1 keys and `run-ape` behavior (unchanged until native loader lands).
