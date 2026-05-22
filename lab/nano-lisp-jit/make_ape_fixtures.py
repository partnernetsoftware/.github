#!/usr/bin/env python3
"""Build corrupt nano APE fixtures from a valid bootstrap-ape.com."""

from __future__ import annotations

import sys
from pathlib import Path


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


def replace_once(data: bytes, old: bytes, new: bytes, label: str) -> bytes:
    if old not in data:
        raise SystemExit(f"missing pattern for {label}: {old!r}")
    return data.replace(old, new, 1)


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
    write_bytes(out_dir / "ape-no-manifest.com", strip_manifest(base))
    write_bytes(
        out_dir / "ape-bad-container.com",
        replace_once(base, b"ape-v1", b"bad-v9", "bad-container"),
    )
    write_bytes(
        out_dir / "ape-bad-offset.com",
        replace_once(
            base,
            b"nano.slice.x86_64.offset=0",
            b"nano.slice.x86_64.offset=999999999",
            "bad-offset",
        ),
    )

    hash_lines: list[bytes] = []
    for line in base.split(b"\n"):
        if b"nano.slice.x86_64.hash=" in line:
            hash_lines.append(b"# nano.slice.x86_64.hash=0000000000000000")
        else:
            hash_lines.append(line)
    write_bytes(out_dir / "ape-bad-hash.com", b"\n".join(hash_lines) + b"\n")
    print(f"ape.fixtures.dir={out_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
