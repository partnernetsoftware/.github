#!/usr/bin/env python3
"""Bump LONG-RUN-TODO after successful batch. Usage: v4-bump-pointer.py LO HI TESTS_PASS"""
from __future__ import annotations
import re
import sys
from pathlib import Path

TODO = Path(__file__).resolve().parents[1] / "v4" / "LONG-RUN-TODO.md"


def main() -> None:
    lo, hi = int(sys.argv[1]), int(sys.argv[2])
    tp = sys.argv[3] if len(sys.argv) > 3 else ""
    nw = hi + 1
    t = TODO.read_text()
    m = re.search(r"下一 add \| \*\*(\d+)\*\*", t)
    na = int(m.group(1)) + (hi - lo + 1) if m else nw - 5 + 17
    t = re.sub(r"下一波 \| \*\*\d+\*\*", f"下一波 | **{nw}**", t, count=1)
    t = re.sub(r"下一 add \| \*\*\d+\*\*", f"下一 add | **{na}**", t, count=1)
    if tp:
        t = re.sub(r"tests\.pass=\d+", f"tests.pass={tp}", t, count=1)
    mark = f"- [x] **wave{lo}–{hi}**"
    if mark not in t:
        t = re.sub(
            r"(- \[ \] wave\d+\+.*)",
            f"{mark} · loop batch\n\\1",
            t,
            count=1,
        )
    TODO.write_text(t)
    print(f"next_wave={nw} next_add={na} tests.pass={tp}")


if __name__ == "__main__":
    main()
