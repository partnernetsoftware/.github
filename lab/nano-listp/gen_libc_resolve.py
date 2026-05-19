#!/usr/bin/env python3
import re
import subprocess
import sys
from pathlib import Path


def default_libc() -> str:
    try:
        out = subprocess.check_output(["ldconfig", "-p"], text=True, stderr=subprocess.DEVNULL)
        for line in out.splitlines():
            if "libc.so.6" in line and "=>" in line:
                return line.rsplit("=>", 1)[1].strip()
    except Exception:
        pass
    return "/lib/x86_64-linux-gnu/libc.so.6"


def ident(name: str, index: int) -> str:
    safe = re.sub(r"[^A-Za-z0-9_]", "_", name)
    if not safe or safe[0].isdigit():
        safe = f"sym_{safe}"
    return f"{safe}_{index}"


def exported_symbols(libc: str) -> list[str]:
    out = subprocess.check_output(["nm", "-D", "--defined-only", libc], text=True)
    symbols: list[str] = []
    seen: set[str] = set()
    for line in out.splitlines():
        parts = line.split()
        if len(parts) < 3:
            continue
        raw = parts[-1]
        if "@" in raw and "@@" not in raw:
            continue
        sym = raw.split("@", 1)[0]
        if sym.startswith(("GLIBC_", "GCC_")):
            continue
        if not sym or sym in seen:
            continue
        seen.add(sym)
        symbols.append(sym)
    symbols.sort()
    return symbols


def main() -> int:
    args = sys.argv[1:]
    if len(args) == 1:
        libc = default_libc()
        out_path = Path(args[0])
    elif len(args) >= 2:
        libc = args[0] if args[0] else default_libc()
        out_path = Path(args[1])
    else:
        libc = default_libc()
        out_path = Path("libc-resolve.lisp")
    symbols = exported_symbols(libc)
    with out_path.open("w", encoding="utf-8") as f:
        f.write("; Generated resolver manifest. It resolves exported libc symbols as addresses only.\n")
        f.write("(module\n")
        names = []
        for i, sym in enumerate(symbols):
            name = ident(sym, i)
            names.append(name)
            f.write(f'  (import {name} "libc" "{sym}" "addr")\n')
        f.write("  (main\n")
        for name in names:
            f.write(f"    (resolve {name})\n")
        f.write("  ))\n")
    print(f"libc.path={libc}")
    print(f"symbols={len(symbols)}")
    print(f"output={out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
