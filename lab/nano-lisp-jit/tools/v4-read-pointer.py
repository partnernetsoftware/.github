#!/usr/bin/env python3
"""Parse v4/LONG-RUN-TODO.md current pointer. Usage: v4-read-pointer.py [key]"""
from __future__ import annotations
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TODO = ROOT / "v4" / "LONG-RUN-TODO.md"


def parse() -> dict[str, str]:
    t = TODO.read_text()
    m = re.search(r"下一波 \| \*\*(\d+)\*\*", t)
    wave = int(m.group(1)) if m else 86
    m = re.search(r"下一 add \| \*\*(\d+)\*\*", t)
    add = int(m.group(1)) if m else wave - 5 + 17
    m = re.search(r"tests\.pass=(\d+)", t)
    tests = m.group(1) if m else "0"
    m = re.search(r"终局粗估 \| \*\*([^*]+)\*\*", t)
    terminal = m.group(1).strip() if m else "15–22%"
    return {
        "next_wave": str(wave),
        "next_add": str(add),
        "tests_pass": tests,
        "terminal_pct": terminal,
        "batch_hi": str(wave + 2),
    }


if __name__ == "__main__":
    d = parse()
    key = sys.argv[1] if len(sys.argv) > 1 else None
    if key:
        print(d.get(key, ""))
    else:
        for k, v in d.items():
            print(f"{k}={v}")
