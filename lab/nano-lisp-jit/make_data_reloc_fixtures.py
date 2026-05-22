#!/usr/bin/env python3
"""Build corrupt ELF64 objects for nano-jit data relocation negative tests."""

from __future__ import annotations

import struct
import sys
from pathlib import Path

ELF64_EHDR_SIZE = 64
ELF64_SHDR_SIZE = 64
ELF64_RELA_SIZE = 24


def rd16(data: bytes, off: int) -> int:
    return struct.unpack_from("<H", data, off)[0]


def rd32(data: bytes, off: int) -> int:
    return struct.unpack_from("<I", data, off)[0]


def rd64(data: bytes, off: int) -> int:
    return struct.unpack_from("<Q", data, off)[0]


def wr32(buf: bytearray, off: int, val: int) -> None:
    struct.pack_into("<I", buf, off, val & 0xFFFFFFFF)


def section_name(data: bytes, shstr_off: int, shstr_size: int, name_off: int) -> str | None:
    if name_off >= shstr_size:
        return None
    end = data.find(b"\0", shstr_off + name_off, shstr_off + shstr_size)
    if end < 0:
        return None
    return data[shstr_off + name_off : end].decode("ascii", errors="replace")


def find_rela_data(data: bytes) -> tuple[int, int]:
    if data[:4] != b"\x7fELF":
        raise SystemExit("not ELF")
    shoff = rd64(data, 40)
    shentsize = rd16(data, 58)
    shnum = rd16(data, 60)
    shstrndx = rd16(data, 62)
    if shentsize < ELF64_SHDR_SIZE or shstrndx >= shnum:
        raise SystemExit("bad ELF shdr")
    shstr = data[shoff + shstrndx * shentsize : shoff + (shstrndx + 1) * shentsize]
    shstr_off = rd64(shstr, 24)
    shstr_size = rd64(shstr, 32)
    for i in range(1, shnum):
        sh = data[shoff + i * shentsize : shoff + (i + 1) * shentsize]
        name = section_name(data, shstr_off, shstr_size, rd32(sh, 0))
        if name == ".rela.data":
            off = rd64(sh, 24)
            size = rd64(sh, 32)
            return off, size
    raise SystemExit("missing .rela.data")


def patch_first_rela_type(data: bytearray, rela_off: int, rela_size: int, new_type: int) -> None:
    if rela_size < ELF64_RELA_SIZE:
        raise SystemExit("empty .rela.data")
    info_off = rela_off + 8
    info = rd64(data, info_off)
    sym_idx = info >> 32
    wr32(data, info_off, (sym_idx << 32) | (new_type & 0xFFFFFFFF))


def patch_first_rela_sym(data: bytearray, rela_off: int, rela_size: int, new_sym: int) -> None:
    if rela_size < ELF64_RELA_SIZE:
        raise SystemExit("empty .rela.data")
    info_off = rela_off + 8
    info = rd64(data, info_off)
    typ = info & 0xFFFFFFFF
    struct.pack_into("<Q", data, info_off, ((new_sym & 0xFFFFFFFF) << 32) | typ)


def main() -> int:
    if len(sys.argv) != 4:
        print(
            f"usage: {sys.argv[0]} good.o bad-reloc-type.o bad-reloc-sym.o",
            file=sys.stderr,
        )
        return 1
    good = Path(sys.argv[1]).read_bytes()
    rela_off, rela_size = find_rela_data(good)
    bad_type = bytearray(good)
    patch_first_rela_type(bad_type, rela_off, rela_size, 99)
    Path(sys.argv[2]).write_bytes(bad_type)
    bad_sym = bytearray(good)
    patch_first_rela_sym(bad_sym, rela_off, rela_size, 99)
    Path(sys.argv[3]).write_bytes(bad_sym)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
