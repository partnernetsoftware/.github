# ape-v1 manifest (v1.5)

Minimal Nano APE container: shell stub + comment manifest + concatenated ELF slices.
Written by `pack-ape`; validated by `inspect-ape`; executed by shell stub or `run-ape`.

## Layout

Shell stub, then `# nano.manifest.begin` … `# nano.manifest.end`, marker `__NANO_APE_PAYLOAD_BELOW__`, then `<x86_64 ELF><aarch64 ELF>`. Slice offsets are from the byte after the marker; x86_64 offset is 0, aarch64 offset equals x86_64 size.

## Manifest keys

| Key | Notes |
|-----|-------|
| `nano.container` | Must be `ape-v1` |
| `nano.slice.x86_64.offset` / `.size` / `.hash` | x86_64 payload (hash = FNV-1a64 hex, optional) |
| `nano.slice.aarch64.offset` / `.size` / `.hash` | aarch64 payload (hash optional) |

## `inspect-ape` exit codes (2–5)

| Code | Meaning |
|------|---------|
| 2 | Manifest or `__NANO_APE_PAYLOAD_BELOW__` marker missing |
| 3 | Bad/missing `nano.container` (not `ape-v1`) |
| 4 | Bad offset/size, out-of-bounds, or slice not ELF |
| 5 | Slice FNV-1a64 hash mismatch |

Fixtures: `samples/bootstrap-ape-negative.lisp`, `make_ape_fixtures.py`.

## `run-ape` arch selection

Default: `uname -m` picks the slice — `x86_64`/`amd64` → x86_64, `aarch64`/`arm64` → aarch64; other hosts exit **126**. Reads manifest, extracts slice to temp file, forks, returns child exit. Does not use the shell stub.

**Optional cross-arch:** `run-ape path aarch64` on a non-aarch64 host forces the aarch64 slice. Requires **`qemu-aarch64-static`** on `PATH` (exit **126** if missing). Slice must be a real aarch64 ELF (e.g. cosmocc `nano-jit.aarch64`); `emit-elf64-exit` smoke ELFs are x86_64-only even when packed as the second slice.

## v1 scope vs v2 loader

v1.5 acceptance = manifest + inspect/run CLI + shell stub loader. Full nano-native loader (header magic, payload table, arch selection without shell) is **v2 slice 1** — see `ROADMAP.md`.
