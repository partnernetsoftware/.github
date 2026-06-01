#!/usr/bin/env python3
"""Wave104: APE v2 6-row six-face probe — Linux ELF + macOS/Windows placeholder rows."""

from __future__ import annotations

import struct
import sys
from pathlib import Path

V2_MAGIC = b"\x7fNANOape"
VERSION = 2
FIXED_HDR = 16
ROW_BYTES = 28

ARCH_X86 = 1
ARCH_A64 = 2
OS_LINUX = 1
OS_MACOS = 2
OS_WINDOWS = 3

FNV_OFFSET = 1469598103934665603  # matches lispjit.c fnv1a64 (nano-jit runner)
FNV_PRIME = 1099511628211


def fnv1a64(data: bytes) -> int:
    h = FNV_OFFSET
    for b in data:
        h ^= b
        h = (h * FNV_PRIME) & 0xFFFFFFFFFFFFFFFF
    return h


def emit_header(rows: list[tuple[int, int, int, int, int, int]]) -> bytes:
    n = len(rows)
    hdr_bytes = FIXED_HDR + n * ROW_BYTES
    out = bytearray(hdr_bytes)
    out[0:8] = V2_MAGIC
    struct.pack_into("<I", out, 8, VERSION)
    struct.pack_into("<H", out, 12, n)
    struct.pack_into("<H", out, 14, hdr_bytes)
    for i, (arch, os_id, reserved, offset, size, hash_v) in enumerate(rows):
        base = FIXED_HDR + i * ROW_BYTES
        out[base] = arch
        out[base + 1] = os_id
        struct.pack_into("<H", out, base + 2, reserved)
        struct.pack_into("<Q", out, base + 4, offset)
        struct.pack_into("<Q", out, base + 12, size)
        struct.pack_into("<Q", out, base + 20, hash_v)
    return bytes(out)


def build_probe(x86: bytes, arm: bytes) -> bytes:
    if len(x86) < 4 or x86[:4] != b"\x7fELF":
        raise SystemExit("x86 input is not ELF")
    if len(arm) < 4 or arm[:4] != b"\x7fELF":
        raise SystemExit("aarch64 input is not ELF")
    x86_h = fnv1a64(x86)
    arm_h = fnv1a64(arm)
    payload_end = len(x86) + len(arm)
    rows = [
        (ARCH_X86, OS_LINUX, 0, 0, len(x86), x86_h),
        (ARCH_A64, OS_LINUX, 0, len(x86), len(arm), arm_h),
        (ARCH_X86, OS_MACOS, 0, payload_end, 0, 0),
        (ARCH_A64, OS_MACOS, 0, payload_end, 0, 0),
        (ARCH_X86, OS_WINDOWS, 0, payload_end, 0, 0),
        (ARCH_A64, OS_WINDOWS, 0, payload_end, 0, 0),
    ]
    return emit_header(rows) + x86 + arm


def main() -> int:
    if len(sys.argv) != 4:
        print(f"usage: {sys.argv[0]} <x86.elf> <aarch64.elf> <out.com>", file=sys.stderr)
        return 1
    x86_p, arm_p, out_p = map(Path, sys.argv[1:4])
    x86 = x86_p.read_bytes()
    arm = arm_p.read_bytes()
    probe = build_probe(x86, arm)
    out_p.parent.mkdir(parents=True, exist_ok=True)
    out_p.write_bytes(probe)
    print(f"ape.six_face.probe.output={out_p}")
    print(f"ape.six_face.probe.bytes={len(probe)}")
    print(f"ape.six_face.probe.slice_count=6")
    print(f"ape.six_face.probe.macos_rows=2")
    print(f"ape.six_face.probe.windows_rows=2")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
