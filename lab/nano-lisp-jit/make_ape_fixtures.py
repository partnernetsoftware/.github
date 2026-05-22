#!/usr/bin/env python3
"""Build corrupt nano APE fixtures from a valid bootstrap-ape.com (ape-v2 payload)."""

from __future__ import annotations

import re
import struct
import sys
from pathlib import Path

MARKER = b"__NANO_APE_PAYLOAD_BELOW__\n"
V2_MAGIC = b"\x7fNANOape"
ROW0_OFF = 16 + 4  # fixed header + arch/os/reserved + offset field in row 0
ROW0_HASH_OFF = 16 + 20


def read_bytes(path: Path) -> bytes:
    return path.read_bytes()


def write_bytes(path: Path, data: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)


def strip_manifest(data: bytes) -> bytes:
    lines = data.split(b"\n")
    out: list[bytes] = []
    skip = False
    for line in lines:
        if b"# nano.manifest.begin" in line:
            skip = True
            continue
        if b"# nano.manifest.end" in line:
            skip = False
            continue
        if not skip:
            out.append(line)
    return b"\n".join(out) + b"\n"


def payload_start(data: bytes) -> int:
    idx = data.find(MARKER)
    if idx >= 0:
        return idx + len(MARKER)
    last: int | None = None
    i = 0
    while i + len(V2_MAGIC) <= len(data):
        if i == 0 or data[i - 1] == 0x0A:
            if data[i : i + len(V2_MAGIC)] == V2_MAGIC:
                last = i
        i += 1
    if last is None:
        raise SystemExit("missing ape payload (marker or v2 magic)")
    return last


def patch_at(data: bytes, off: int, chunk: bytes) -> bytes:
    if off < 0 or off + len(chunk) > len(data):
        raise SystemExit(f"patch out of range off={off} len={len(chunk)} file={len(data)}")
    return data[:off] + chunk + data[off + len(chunk) :]


def corrupt_v2_magic(data: bytes) -> bytes:
    ps = payload_start(data)
    if data[ps : ps + len(V2_MAGIC)] != V2_MAGIC:
        raise SystemExit("missing ape-v2 magic at payload_start")
    return patch_at(data, ps, b"\x7fBADApe\x00")


def corrupt_v2_version(data: bytes) -> bytes:
    ps = payload_start(data) + 8
    return patch_at(data, ps, struct.pack("<I", 9))


def corrupt_v2_row0_offset(data: bytes, value: int = 999999999) -> bytes:
    ps = payload_start(data) + ROW0_OFF
    return patch_at(data, ps, struct.pack("<Q", value))


def corrupt_v2_row0_hash(data: bytes) -> bytes:
    ps = payload_start(data) + ROW0_HASH_OFF
    return patch_at(data, ps, struct.pack("<Q", 1))


def v1_legacy_from_v2_pack(data: bytes) -> bytes:
    """Drop v2 binary header and rewind v1 manifest/stub offsets to payload-relative 0."""
    ps = payload_start(data)
    if data[ps : ps + len(V2_MAGIC)] != V2_MAGIC:
        raise SystemExit("v1_legacy: missing ape-v2 magic")
    header_bytes = struct.unpack_from("<H", data, ps + 14)[0]
    row0 = ps + 16
    x86_size = struct.unpack_from("<Q", data, row0 + 12)[0]
    head = data[:ps]
    payload = data[ps + header_bytes :]
    head = re.sub(rb"(nano\.slice\.x86_64\.offset=)\d+", rb"\g<1>0", head, count=1)
    head = re.sub(
        rb"(nano\.slice\.aarch64\.offset=)\d+",
        b"\\g<1>" + str(x86_size).encode(),
        head,
        count=1,
    )
    head = re.sub(rb"(x86_64\|amd64\) off=)\d+;", rb"\g<1>0;", head, count=1)
    head = re.sub(
        rb"(aarch64\|arm64\) off=)\d+;",
        b"\\g<1>" + str(x86_size).encode() + b";",
        head,
        count=1,
    )
    return head + payload


def bare_from_v2_pack(data: bytes) -> bytes:
    """Mode B: v2 header + ELF slices only (no shell stub / marker)."""
    ps = payload_start(data)
    if data[ps : ps + len(V2_MAGIC)] != V2_MAGIC:
        raise SystemExit("bare: missing ape-v2 magic at payload_start")
    header_bytes = struct.unpack_from("<H", data, ps + 14)[0]
    return data[ps : ps + header_bytes] + data[ps + header_bytes :]


def write_v2_fixtures(base: bytes, out_dir: Path, prefix: str) -> None:
    no_manifest = strip_manifest(base)
    write_bytes(out_dir / f"{prefix}no-manifest.com", corrupt_v2_magic(no_manifest))
    write_bytes(out_dir / f"{prefix}bad-container.com", corrupt_v2_version(base))
    write_bytes(out_dir / f"{prefix}bad-offset.com", corrupt_v2_row0_offset(base))
    write_bytes(out_dir / f"{prefix}bad-hash.com", corrupt_v2_row0_hash(base))


def main() -> int:
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} <src.com> <out-dir>", file=sys.stderr)
        return 1
    src = Path(sys.argv[1])
    out_dir = Path(sys.argv[2])
    if not src.is_file():
        print(f"missing source: {src}", file=sys.stderr)
        return 1

    base = read_bytes(src)
    write_v2_fixtures(base, out_dir, "ape-")
    write_v2_fixtures(base, out_dir, "ape-v2-")
    bare = bare_from_v2_pack(base)
    write_bytes(out_dir / "ape-v2-bare.com", bare)
    write_v2_fixtures(bare, out_dir, "ape-v2-bare-")
    write_bytes(out_dir / "ape-v1-legacy.com", v1_legacy_from_v2_pack(base))
    print(f"ape.fixtures.dir={out_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
