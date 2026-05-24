#!/usr/bin/env python3
"""Read longrun pointer — SSOT is v4/longrun-state.json."""
from __future__ import annotations
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
STATE = ROOT / "v4" / "longrun-state.json"
TODO = ROOT / "v4" / "LONG-RUN-TODO.md"


def load() -> dict:
    if STATE.exists():
        return json.loads(STATE.read_text())
    t = TODO.read_text() if TODO.exists() else ""
    m = re.search(r"下一波 \| \*\*(\d+)\*\*", t)
    w = int(m.group(1)) if m else 86
    m = re.search(r"下一 add \| \*\*(\d+)\*\*", t)
    a = int(m.group(1)) if m else 81
    m = re.search(r"tests\.pass=(\d+)", t)
    tp = int(m.group(1)) if m else 0
    return {"next_wave": w, "next_add": a, "last_tests_pass": tp}


def main() -> None:
    st = load()
    key = sys.argv[1] if len(sys.argv) > 1 else None
    if key == "batch_hi":
        print(st["next_wave"] + 2)
    elif key:
        print(st.get(key, ""))
    else:
        for k in ("next_wave", "next_add", "last_tests_pass"):
            print(f"{k}={st.get(k, '')}")


if __name__ == "__main__":
    main()
